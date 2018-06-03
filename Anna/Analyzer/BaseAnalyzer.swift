//
//  BaseAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

struct
    IdentityContext : Equatable
{
    let
    manager :Manager,
    parentID :NodeID?,
    identifier :NodeID,
    name :String,
    index :Int?
    static func
        == (
        lhs: IdentityContext,
        rhs: IdentityContext
        ) -> Bool {
        return lhs.manager === rhs.manager &&
            lhs.parentID == rhs.parentID &&
            lhs.identifier == rhs.identifier &&
            lhs.name == rhs.name &&
            lhs.index == rhs.index
    }
}

protocol
    IdentityResolving : class
{
    typealias
        Callback = (Manager, NodeID) throws -> Void
    func
        resolveIdentity(
        then callback : @escaping Callback
    ) throws -> Void
}

public class
    BaseAnalyzer :
    NSObject,
    Recording,
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
        fatalError("Overidding needed.")
    }
    func
        unbindNode() throws {
        fatalError("Overidding needed.")
    }
    var
    nodeID :NodeID? = nil {
        didSet {
            for
                key in self.nodeIDObservations.keyEnumerator()
            {
                guard
                    let
                    observer = key as? BaseAnalyzer,
                    let
                    observation = self.nodeIDObservations.object(forKey: observer)
                    else { continue }
                observation.callback(self, observer)
            }
        }
    }
    class
    NodeIDObservation<Observee : BaseAnalyzer> {
        typealias
            Callback = (BaseAnalyzer, Observee) -> Void
        let
        callback :Callback
        init(_ callback : @escaping Callback) {
            self.callback = callback
        }
    }
    var
    nodeIDObservations :NSMapTable<
        BaseAnalyzer,
        NodeIDObservation<BaseAnalyzer>
        > = NSMapTable.weakToStrongObjects()
    func
        addNodeIDObserver(
        _ observer: BaseAnalyzer,
        callback : @escaping (BaseAnalyzer, BaseAnalyzer) -> Void
        ) {
        self.nodeIDObservations.setObject(
            NodeIDObservation(callback),
            forKey: observer
        )
    }
    func
        removeNodeIDObserver(
        _ observer :BaseAnalyzer
        ) {
        self.nodeIDObservations.removeObject(
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
    public func
        recordEventOnPath(
        named name :String,
        with properties :Properties? = nil
        ) {
        let
        identityResolver = self
        try! identityResolver.resolveIdentity {
            (manager, nodeID) in
            try manager.recordEvent(
                named: name,
                with: properties,
                onNodeBy: nodeID
            )
        }
    }

    // MARK: - Child Analyzer
    
    var
    childAnalyzer :[AnyHashable : BaseAnalyzer] = [:]
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
