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
        ) throws {
        
        if let
            identity = self.identity
        { return try callback(identity) }
        
        try self.target?.resolveIdentity {
            [weak self] (identity) in
            guard let
                analyzer = self
                else { return }
            try analyzer.bindNode(with: IdentityContext(
                manager: identity.manager,
                nodeID: identity.nodeID,
                parentID: nil,
                name: "forwarding",
                index: nil
            ))
            try callback(identity)
        }
    }
    override func
        bindNode(
        with context: IdentityContext
        ) throws {
        guard self.identity == nil
            else { return }
        self.identity = Identity(
            manager: context.manager,
            nodeID: context.nodeID
        )
    }
    override func
        unbindNode() throws {
        guard let
            identity = self.identity
            else { return }
        let
        manager = identity.manager
        try manager.deregisterNodes(by: self.owningID)
        self.identity = nil
    }
    func
        handleFocused(_ object :FocusHandling.Object) {
        self.target?.handleFocused(object)
    }
}
