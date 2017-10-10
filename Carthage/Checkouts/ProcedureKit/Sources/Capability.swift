//
//  ProcedureKit
//
//  Copyright © 2016 ProcedureKit. All rights reserved.
//

/**
 Defines the authorization status of a capability. Typically
 this will be an enum, like CLAuthorizationStatus. Note
 that it is itself generic over the Requirement. This allows
 for another (or existing) types to be used to define granular
 levels of permissions. Use Void if not needed.
 */
public protocol AuthorizationStatus {

    /// A generic type for the requirement
    associatedtype Requirement

    /**
     Given the current authorization status (i.e. self)
     this function should determine whether or not the
     provided Requirement has been met or not. Therefore
     this function should consider the overall authorization
     state, and if *authorized* - whether the authorization
     is enough for the Requirement.

     - parameter requirement: the necessary Requirement
     - returns: a Bool indicating whether or not the requirements are met.
     */
    func meets(requirement: Requirement?) -> Bool
}

/**
 This is the high level definition for device/user/system
 capabilities which typically would require the user's
 permission to access. For example, location, calendars,
 photos, health kit etc.

 However, it can also be used to abstract the business
 logic of custom login/auth too.
 */
public protocol CapabilityProtocol {

    associatedtype Status: AuthorizationStatus

    /**
     A requirement of the capability. E.g. for Location this
     might be acces "when in use" or "always"

     - returns: the necessary Status.Requirement
    */
    var requirement: Status.Requirement? { get }

    /**
     Query the capability to see if it's available on the device.

     - returns: true Bool value if the capability is available.
     */
    func isAvailable() -> Bool

    /**
     Get the current authorization status of the capability. This
     can be performed asynchronously. The status is returns as the
     argument to a completion block.

     - parameter completion: a (Status) -> Void closure.
     */
    func getAuthorizationStatus(_ completion: @escaping (Status) -> Void)

    /**
     Request authorization with the requirement of the capability.

     Again, this is designed to be performed asynchronously. More than
     likely the registrar will present a dialog and wait for the user.
     When control is returned, the completion block should be called.

     - parameter completion: a () -> Void closure.
     */
    func requestAuthorization(withCompletion completion: @escaping () -> Void)
}

/**
 Capability is a namespace to nest as aliases the
 various device capability types.
 */
public struct Capability { }

extension Capability {

    /**
     A capability might not have the need for
     an authorization level, but still might not be available. For example
     PassKit. In which case, use VoidStatus as the nested Status type.
     */
    public struct VoidStatus: AuthorizationStatus, Equatable {

        public static func == (_: VoidStatus, _: VoidStatus) -> Bool {
            return true
        }

        /// - returns: true, VoidStatus cannot fail to meet requirements.
        public func meets(requirement: Void?) -> Bool {
            return true
        }
    }
}


// MARK: - AnyCapability

internal class AnyCapabilityBox_<Status: AuthorizationStatus>: CapabilityProtocol {
    var requirement: Status.Requirement? { _abstractMethod(); return nil }
    func isAvailable() -> Bool { _abstractMethod(); return false }
    func getAuthorizationStatus(_ completion: @escaping (Status) -> Void) { _abstractMethod() }
    func requestAuthorization(withCompletion completion: @escaping () -> Void) { _abstractMethod() }
}

internal class AnyCapabilityBox<Base: CapabilityProtocol>: AnyCapabilityBox_<Base.Status> {

    private var base: Base

    init(_ base: Base) {
        self.base = base
    }

    override var requirement: Base.Status.Requirement? { return base.requirement }
    override func isAvailable() -> Bool {
        return base.isAvailable()
    }
    override func getAuthorizationStatus(_ completion: @escaping (Base.Status) -> Void) {
        base.getAuthorizationStatus(completion)
    }
    override func requestAuthorization(withCompletion completion: @escaping () -> Void) {
        base.requestAuthorization(withCompletion: completion)
    }
}

public struct AnyCapability<Status: AuthorizationStatus>: CapabilityProtocol {
    private typealias Erased = AnyCapabilityBox_<Status>

    private var box: Erased

    init<Base: CapabilityProtocol>(_ base: Base) where Status == Base.Status {
        box = AnyCapabilityBox(base)
    }

    public var requirement: Status.Requirement? { return box.requirement }
    public func isAvailable() -> Bool {
        return box.isAvailable()
    }
    public func getAuthorizationStatus(_ completion: @escaping (Status) -> Void) {
        return box.getAuthorizationStatus(completion)
    }
    public func requestAuthorization(withCompletion completion: @escaping () -> Void) {
        box.requestAuthorization(withCompletion: completion)
    }
}

// MARK: - Procedures

/**
 A generic procedure which will get the current authorization
 status for AnyCapability<Status>.
 */
public class GetAuthorizationStatusProcedure<Status: AuthorizationStatus>: Procedure, OutputProcedure {

    /// the StatusResponse is a tuple for the capabilities availability and status
    public typealias StatusResponse = (Bool, Status)

    /// the Completion is a closure which receives a StatusResponse
    public typealias Completion = (StatusResponse) -> Void

    /**
     After the procedure has executed, this property will be set
     to the result.

     - returns: a StatusResponse
     */
    public var output: Pending<ProcedureResult<StatusResponse>> = .pending

    fileprivate let capability: AnyCapability<Status>
    fileprivate let completion: Completion?

    /**
     Initialize the operation with a base type which conforms to CapabilityProtocol
     and an optional completion block.

     - parameter capability: the Capability.
     - parameter completion: an optional Completion closure.
     */
    public init<Base>(_ base: Base, completion block: Completion? = nil) where Base: CapabilityProtocol, Status == Base.Status {
        capability = AnyCapability(base)
        completion = block
        super.init()
    }

    public override func execute() {
        determineStatus { status in
            self.output = .ready(.success(status))
            self.completion?(status)
            self.finish()
        }
    }

    func determineStatus(completion: @escaping Completion) {
        let isAvailable = capability.isAvailable()
        capability.getAuthorizationStatus { status in
            completion((isAvailable, status))
        }
    }
}

/// A generic procedure which will authorize a capability
public class AuthorizeCapabilityProcedure<Status: AuthorizationStatus>: GetAuthorizationStatusProcedure<Status> {

    /**
     Initialize the operation with a base type which conforms to CapabilityProtocol
     and an optional completion block. This operation is mutually exclusive with itself

     - parameter capability: the Capability.
     - parameter completion: an optional Completion closure.
     */
    public override init<Base>(_ base: Base, completion block: Completion? = nil) where Base: CapabilityProtocol, Status == Base.Status {
        super.init(base, completion: block)
    }

    public override func execute() {
        capability.requestAuthorization {
            super.execute()
        }
    }
}

/**
 This is a Condition which can be used to allow or
 deny procedures to execute depending on the authorization status of a
 capability and its requirements.

 By default, the condition will add an Authorize operation as a dependency
 which means that potentially the user will be prompted to grant
 authorization. Suppress this from happening with SilentCondition.
 */
public class AuthorizedFor<Status: AuthorizationStatus>: Condition {

    fileprivate let capability: AnyCapability<Status>

    public init<Base>(_ base: Base, category: String? = nil) where Base: CapabilityProtocol, Status == Base.Status {
        capability = AnyCapability(base)
        super.init()
        mutuallyExclusiveCategory = category ?? String(describing: type(of: base))
        add(dependency: AuthorizeCapabilityProcedure(base))
    }

    public override func evaluate(procedure: Procedure, completion: @escaping (ConditionResult) -> Void) {
        guard capability.isAvailable() else {
            completion(.failure(ProcedureKitError.capabilityUnavailable())); return
        }

        capability.getAuthorizationStatus { [requirement = self.capability.requirement] status in
            if status.meets(requirement: requirement) {
                completion(.success(true))
            }
            else {
                completion(.failure(ProcedureKitError.capabilityUnauthorized()))
            }
        }
    }
}
