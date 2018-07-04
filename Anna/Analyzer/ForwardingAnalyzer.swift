//
//  ForwardingAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/6/5.
//

import Foundation

class
    ForwardingAnalyzer : BaseAnalyzer, FocusHandling
{
    typealias
        Target = Analyzer.Parent & FocusHandling
    
    weak var
    target :Target?
    var
    owningID :NodeID!
    init(
        target :Target
        ) {
        super.init()
        self.target = target
        self.owningID = NodeID.owned(by: self)
    }
    override func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) {
        
        if let
            identity = self.identity
        { return callback(identity) }
        
        self.target?.resolveIdentity {
            [weak self] (identity) in
            guard let
                analyzer = self
                else { return }
            analyzer.bindNode(with: IdentityContext(
                manager: identity.manager,
                nodeID: identity.nodeID,
                parentID: nil,
                name: "forwarding",
                index: nil
            ))
            callback(identity)
        }
    }
    override func
        bindNode(
        with context: IdentityContext
        ) {
        guard self.identity == nil
            else { return }
        self.identity = Identity(
            manager: context.manager,
            nodeID: context.nodeID
        )
    }
    override func
        unbindNode() {
        guard let
            identity = self.identity
            else { return }
        let
        manager = identity.manager
        manager.deregisterNodes(by: self.owningID)
        self.identity = nil
    }
    func
        handleFocused(_ object :FocusHandling.Object) {
        self.target?.handleFocused(object)
    }
}
