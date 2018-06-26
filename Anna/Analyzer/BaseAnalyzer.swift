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
        Callback = (Identity) -> Void
    func
        resolveIdentity(
        then callback : @escaping Callback
    ) -> Void
    var
    identity :Identity? { get }
    typealias
        ObservationToken = Int
    typealias
        ObservationCallback = (BaseAnalyzer) -> Void
    func
        addIdentityObserver(
        callback : @escaping ObservationCallback
        ) -> ObservationToken
    func
        removeIdentityObserver(
        by token :ObservationToken
    )
}

public class
    BaseAnalyzer :
    NSObject,
    IdentityResolving
{
    var
    namespace :String? = nil
    deinit {
        self.unbindNode()
    }

    // MARK: - Node Identity
    
    func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) {
        fatalError("Overidding needed.")
    }
    func
        bindNode(
        with context :IdentityContext
        ) {
        guard self.identity == nil
            else { return }
        self.identity = Identity(
            manager: context.manager,
            nodeID: context.nodeID
        )
        let
        namespace = self.namespace
        context.manager.registerNode(
            by: context.nodeID,
            under: context.parentID,
            name: context.name,
            index: context.index,
            namespace: namespace,
            attributes: nil
        )
    }
    func
        unbindNode() {
        guard let
            identity = self.identity
            else { return }
        let
        manager = identity.manager,
        nodeID = identity.nodeID
        if nodeID.isOwned(by: self) {
            manager.deregisterNodes(by: nodeID)
        }
        self.identity = nil
    }
    var
    identity :Identity? = nil {
        didSet {
            for
                callback in self.identityObservationByToken.values
            {
                callback(self)
            }
        }
    }
    typealias
        ObservationToken = Int
    typealias
        ObservationCallback = (BaseAnalyzer) -> Void
    var
    nextIdentityObservationToken :ObservationToken = 0,
    identityObservationByToken :[ObservationToken : ObservationCallback] = [:]
    func
        addIdentityObserver(
        callback : @escaping ObservationCallback
        ) -> ObservationToken {
        let
        token = self.nextIdentityObservationToken
        self.identityObservationByToken[token] = callback
        self.nextIdentityObservationToken += 1
        return token
    }
    func
        removeIdentityObserver(
        by token :ObservationToken
        ) {
        self.identityObservationByToken[token] = nil
    }


    // MARK: - Event Recording
    
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
        ) {
        let
        identityResolver = self
        identityResolver.resolveIdentity {
            let
            manager = $0.manager,
            nodeID = $0.nodeID
            manager.recordEvent(
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
        self.recordEventOnPath(
            named: name,
            with: attributes
        )
    }
}
