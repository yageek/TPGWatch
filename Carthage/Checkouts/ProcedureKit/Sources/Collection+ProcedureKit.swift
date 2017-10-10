//
//  ProcedureKit
//
//  Copyright © 2016 ProcedureKit. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element: Operation {

    internal var operationsAndProcedures: ([Operation], [Procedure]) {
        return reduce(([], [])) { result, element in
            var (operations, procedures) = result
            if let procedure = element as? Procedure {
                procedures.append(procedure)
            }
            else {
                operations.append(element)
            }
            return (operations, procedures)
        }
    }

    internal var conditions: [Condition] {
        return flatMap { $0 as? Condition }
    }

    internal var userIntent: UserIntent {
        get {
            let (_, procedures) = operationsAndProcedures
            return procedures.map { $0.userIntent }.max { $0.rawValue < $1.rawValue } ?? .none
        }
    }

    internal func forEachProcedure(body: (Procedure) throws -> Void) rethrows {
        try forEach {
            if let procedure = $0 as? Procedure {
                try body(procedure)
            }
        }
    }

    /**
     Add the last operation of the receiver as a dependency of each element
     of the argument sequence. An Array of the receiver extended by the argument is
     returned.
     - parameter operation: the Iterator.Element instance to add
         the receiver as a dependency.
     - returns: an array of all operations operations.
     */
    public func then<S: Sequence>(do sequence: S) -> [Iterator.Element] where S.Iterator.Element == Iterator.Element {
        var operations = Array(self)
        if let last = operations.last {
            assert(!last.isFinished, "Cannot add a finished operation as a dependency.")
            sequence.forEach { $0.add(dependency: last) }
        }
        operations += sequence
        return operations
    }

    /**
     Add the last operation of the receiver as a dependency of each element
     of the argument. An Array of the receiver extended by the argument is
     returned.
     - parameter operations: a variable argument of Iterator.Element instance(s) to
         add the receiver as a dependency.
     - returns: an array of all operations.
     */
    public func then(do operations: Iterator.Element...) -> [Iterator.Element] {
        return then(do: operations)
    }

    /**
     Add the result of a closure onto the receiver.
     - parameter block: a throwing closure which returns an optional element
     - returns: an array of all operations.
     */
    func then(do block: () throws -> Iterator.Element?) rethrows -> [Iterator.Element] {
        guard let operations = try block() else { return Array(self) }
        return then(do: operations)
    }

    /**
     Adds the receiver to a ProcedureQueue.
     - parameter queue: a ProcedureQueue, with a default argument
    */
    func enqueue(on queue: ProcedureQueue = ProcedureQueue()) {
        queue.add(operations: self)
    }
}

// MARK: - OutputProcedure & Gathering

extension Collection where Iterator.Element: ProcedureProtocol, Iterator.Element: OutputProcedure {

    /// Creates a new procedure which will flatmap the non-nil results of the receiver's procedures into a
    /// new array. This new array is available as the result of the returned procedure.
    ///
    /// - Parameter transform: a throwing closure which receives the result from the receiver's procedure.
    /// - Returns: a ResultProcedure<[T]> procedure.
    public func flatMap<T>(transform: @escaping (Self.Iterator.Element.Output) throws -> T?) -> ResultProcedure<[T]> {

        let mapped = ResultProcedure { try self.flatMap { $0.output.success }.flatMap(transform) }

        forEach { mapped.add(dependency: $0) }

        return mapped
    }

    /// Creates a new procedure which will reduce the non-nil results of the receiver's procedures into a single type, using
    /// and initial result, and combining closure.
    ///
    /// - Parameters:
    ///   - initialResult: the initial result
    ///   - nextPartialResult: a closure which receives the partial result, and next element (result) returns the next partial result.
    /// - Returns: a ResultProcedure<ReducedResult> procedure
    public func reduce<ReducedResult>(_ initialResult: ReducedResult, _ nextPartialResult: @escaping (ReducedResult, Self.Iterator.Element.Output) throws -> ReducedResult) -> ResultProcedure<ReducedResult> {

        let result = ResultProcedure { try self.flatMap { $0.output.success }.reduce(initialResult, nextPartialResult) }

        forEach { result.add(dependency: $0) }

        return result
    }

    /// Creates a new procedure which will gather the non-nil results of the receiver's procedures into a single array
    ///
    /// - Returns: a ResultProcedure<[Self.Iterator.Element.Result]> procedur
    public func gathered() -> ResultProcedure<[Self.Iterator.Element.Output]> {
        return flatMap(transform: { $0 })
    }
}
