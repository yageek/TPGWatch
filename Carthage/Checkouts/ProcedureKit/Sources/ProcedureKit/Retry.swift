//
//  ProcedureKit
//
//  Copyright © 2016 ProcedureKit. All rights reserved.
//

import Foundation
import Dispatch

public struct RetryFailureInfo<T: Procedure> {

    /// - returns: the failed operation
    public let operation: T

    /// - returns: the errors the operation finished with
    public let errors: [Error]

    /// - returns: the number of attempts made so far
    public let count: Int

    /**
     This is a block which can be used to add Operation(s)
     to a queue. For example, perhaps it is necessary to
     retrying the task, but only until another operation
     has completed.

     This can be done by creating the operation, setting
     the dependency and adding it using the block.

     - returns: a block which accepts var arg Operation instances
    */
    public let addOperations: (Operation...) -> Void

    /// - returns: a logger (from the RetryProcedure)
    public let log: LoggerProtocol

    /**
     - returns: the block which is used to replace the
     configure block, which in turns configures the
     operation instances.
    */
    public let configure: (T) -> Void
}

public extension RetryFailureInfo {

    var errorCode: Int? {
        return (errors.first as NSError?)?.code
    }
}

internal class RetryIterator<T: Procedure>: IteratorProtocol {
    typealias Payload = RepeatProcedure<T>.Payload
    typealias Handler = RetryProcedure<T>.Handler
    typealias FailureInfo = RetryProcedure<T>.FailureInfo

    internal let handler: Handler
    internal var info: FailureInfo?
    private var iterator: AnyIterator<Payload>

    init<PayloadIterator: IteratorProtocol>(handler: @escaping Handler, iterator base: PayloadIterator) where PayloadIterator.Element == Payload {
        self.handler = handler
        self.iterator = AnyIterator(base)
    }

    func next() -> Payload? {
        guard let payload = iterator.next() else { return nil }
        guard let info = info else { return payload }
        return handler(info, payload)
    }
}

/**
 RetryProcedure is a RepeatProcedure subclass which can be used
 to automatically retry another instance of procedure T if the
 first instance finishes with errors. It is generic over T, a
 `Procedure` subclass.

 To support effective error recovery, in addition to a (T, Delay?)
 iterator, RetryProcedure is initialized with a block. This block
 will receive failure info, in addition to the next result (if not
 nil) of the payload iterator.

 Therefore, consumers can inspect the failure info, and adjust
 the delay, or re-configure the operation before it is retried.

 To exit with the error, this block can return nil.
 */
open class RetryProcedure<T: Procedure>: RepeatProcedure<T> {
    public typealias Handler = (FailureInfo, Payload) -> Payload?
    public typealias FailureInfo = RetryFailureInfo<T>

    let retry: RetryIterator<T>

    public init<PayloadIterator>(dispatchQueue: DispatchQueue? = nil, max: Int? = nil, iterator base: PayloadIterator, retry block: @escaping Handler) where PayloadIterator: IteratorProtocol, PayloadIterator.Element == Payload {
        retry = RetryIterator(handler: block, iterator: base)
        super.init(dispatchQueue: dispatchQueue, max: max, iterator: retry)
    }

    public init<OperationIterator, DelayIterator>(dispatchQueue: DispatchQueue? = nil, max: Int? = nil, delay: DelayIterator, iterator base: OperationIterator, retry block: @escaping Handler) where OperationIterator: IteratorProtocol, DelayIterator: IteratorProtocol, OperationIterator.Element == T, DelayIterator.Element == Delay {
        let payloadIterator = MapIterator(PairIterator(primary: base, secondary: delay)) { Payload(operation: $0.0, delay: $0.1) }
        retry = RetryIterator(handler: block, iterator: payloadIterator)
        super.init(dispatchQueue: dispatchQueue, max: max, iterator: retry)
    }

    public init<OperationIterator>(dispatchQueue: DispatchQueue? = nil, max: Int? = nil, wait: WaitStrategy, iterator base: OperationIterator, retry block: @escaping Handler) where OperationIterator: IteratorProtocol, OperationIterator.Element == T {
        let payloadIterator = MapIterator(PairIterator(primary: base, secondary: Delay.iterator(wait.iterator))) { Payload(operation: $0.0, delay: $0.1) }
        retry = RetryIterator(handler: block, iterator: payloadIterator)
        super.init(dispatchQueue: dispatchQueue, max: max, iterator: retry)
    }

    /// Handle child willFinish event
    ///
    /// This is used by RetryProcedure to trigger adding the next Procedure,
    /// if the current Procedure fails with errors.
    ///
    /// If no further Procedure will be attempted (based on the Retry block / iterator),
    /// it adds the current (last) Procedure's errors to the Group's errors.
    ///
    /// - IMPORTANT: If subclassing RetryProcedure and overriding this method, consider
    /// carefully whether / when / how you should call `super.child(_:willFinishWithErrors:)`.
    open override func child(_ child: Procedure, willFinishWithErrors errors: [Error]) {
        eventQueue.debugAssertIsOnQueue()
        assert(!child.isFinished, "child(_:willFinishWithErrors:) called with a child that has already finished")
        guard child === current else {
            // There may be other Procedures that finish, such as DelayProcedures (between retried
            // Procedures), and Procedures produced onto the Group's internal queue.
            // 
            // These other Procedures do not affect whether the RetryProcedure tries a next
            // Procedure, and their errors (if any) are excluded from the RetryProcedure's
            // errors.
            return
        }
        guard !errors.isEmpty else {
            // The RetryProcedure's current Procedure succeeded - stop retrying.
            return
        }

        var willAttemptAnotherOperation = false
        defer {
            log.notice(message: "\(willAttemptAnotherOperation ? "will attempt" : "will not attempt") recovery from errors: \(errors) in operation: \(child)")
        }
        retry.info = createFailureInfo(for: current, errors: errors)
        willAttemptAnotherOperation = _addNextOperation()
        retry.info = .none
        if !willAttemptAnotherOperation {
            // If no further operation will be attempted, append the errors from this child
            // to the Group's errors.
            append(errors: errors, fromChild: child)
        }
        // Do not call super.child(_:willFinishWithErrors:)
        // To ensure that we do not retry/repeat successful procedures (via RepeatProcedure)
    }

    internal func createFailureInfo(for operation: T, errors: [Error]) -> FailureInfo {
        return FailureInfo(
            operation: operation,
            errors: errors,
            count: count,
            addOperations: { (ops: Operation...) in self.add(children: ops, before: nil); return },
            log: log,
            configure: configure
        )
    }
}
