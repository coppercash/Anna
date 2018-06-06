//
//  BaseAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

struct
    Identity : Equatable
{
    let
    manager :Manager,
    nodeID :NodeID
    static func
        == (
        lhs :Identity,
        rhs :Identity
        ) -> Bool {
        return lhs.manager === rhs.manager &&
            lhs.nodeID == rhs.nodeID
    }
}

struct
    IdentityContext : Equatable
{
    let
    manager :Manager,
    nodeID :NodeID,
    parentID :NodeID?,
    name :String,
    index :Int?
    static func
        == (
        lhs :IdentityContext,
        rhs :IdentityContext
        ) -> Bool {
        return lhs.manager === rhs.manager &&
            lhs.nodeID == rhs.nodeID &&
            lhs.parentID == rhs.parentID &&
            lhs.name == rhs.name &&
            lhs.index == rhs.index
    }
}

protocol
    IdentityResolving : class
{
    typealias
        Callback = (Identity) throws -> Void
    func
        resolveIdentity(
        then callback : @escaping Callback
    ) throws -> Void
    var
    identity :Identity? { get }
    func
        addIdentityObserver(
        _ observer: BaseAnalyzer,
        callback : @escaping (BaseAnalyzer, BaseAnalyzer) -> Void
    )
    func
        removeIdentityObserver(
        _ observer :BaseAnalyzer
    )
}

public class
    BaseAnalyzer :
    NSObject,
    IdentityResolving
{
    deinit {
        try? self.unbindNode()
    }

    // MARK: - Node Identity
    
    func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) throws {
        fatalError("Overidding needed.")
    }
    func
        bindNode(
        with context :IdentityContext
        ) throws {
        guard self.identity == nil
            else { return }
        self.identity = Identity(
            manager: context.manager,
            nodeID: context.nodeID
        )
        try context.manager.registerNode(
            by: context.nodeID,
            under: context.parentID,
            name: context.name,
            index: context.index
        )
    }
    func
        unbindNode() throws {
        guard let
            identity = self.identity
            else { return }
        let
        manager = identity.manager,
        nodeID = identity.nodeID
        if nodeID.isOwned(by: self) {
            try manager.deregisterNodes(by: nodeID)
        }
        self.identity = nil
    }
    var
    identity :Identity? = nil {
        didSet {
            for
                key in self.identityObservations.keyEnumerator()
            {
                guard
                    let
                    observer = key as? BaseAnalyzer,
                    let
                    observation = self.identityObservations.object(forKey: observer)
                    else { continue }
                observation.callback(self, observer)
            }
        }
    }
    class
    IdentityObservation<Observee : BaseAnalyzer> {
        typealias
            Callback = (BaseAnalyzer, Observee) -> Void
        let
        callback :Callback
        init(_ callback : @escaping Callback) {
            self.callback = callback
        }
    }
    var
    identityObservations :NSMapTable<
        BaseAnalyzer,
        IdentityObservation<BaseAnalyzer>
        > = NSMapTable.weakToStrongObjects()
    func
        addIdentityObserver(
        _ observer: BaseAnalyzer,
        callback : @escaping (BaseAnalyzer, BaseAnalyzer) -> Void
        ) {
        self.identityObservations.setObject(
            IdentityObservation(callback),
            forKey: observer
        )
    }
    func
        removeIdentityObserver(
        _ observer :BaseAnalyzer
        ) {
        self.identityObservations.removeObject(
            forKey: observer
        )
    }

    // MARK: - Event Recording
    
    var
    namespace :String? = nil
    struct
        Event
    {
        typealias
            Properties = NSObject.Propertiez
        let
        name :String,
        properties :Properties?
    }
    func
        recordEventOnPath(
        named name :String,
        with attributes :Manager.Attributes? = nil
        ) throws {
        let
        identityResolver = self
        try identityResolver.resolveIdentity {
            let
            manager = $0.manager,
            nodeID = $0.nodeID
            try manager.recordEvent(
                named: name,
                with: attributes,
                onNodeBy: nodeID
            )
        }
    }
}

extension
    BaseAnalyzer : Recording
{
    public func
        recordEvent(
        named name: String,
        with attributes: Recording.Attributes?
        ) {
        do {
            try self.recordEventOnPath(
                named: name,
                with: attributes
            )
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
}

enum
    ContextError : Error
{
    case unresolvedManager
    case unsetupAnalysisObject(description :String)
    case unresolvedName
}
extension
    ContextError : LocalizedError
{
    public var
    errorDescription: String? {
        switch self {
        case .unresolvedManager:
            return "Cannot find a resolved manager in context."
        case .unresolvedName:
            return "Enable analyzer before analyzing."
        case .unsetupAnalysisObject(description: let description):
            return "Unsetup analysis object \(description)."
        }
    }
}

enum
    ParentError : Error
{
    case abstractMethod(name :String)
    case noDelegate(name :String)
    case brokenChain(breaking :String)
    case tooManyDeferredContextRequirings(node :String)
    case unresolvedParenthood
}
extension
    ParentError : LocalizedError
{
    public var
    errorDescription: String? {
        switch self {
        case .abstractMethod(name: let name):
            return "Must not call abstract method '\(name)'."
        case .noDelegate(name: let name):
            return "Analyzer '\(name)' has no delegate to resolve a parent."
        case .brokenChain(breaking: let breaking):
            return "Path chain is broken, because node '\(breaking)' has no parent."
        case .tooManyDeferredContextRequirings(node: let node):
            return "Too many deferred node context requirings on node '\(node)'."
        case .unresolvedParenthood:
            return "Unexpected unresolved parenthood."
        }
    }
}
