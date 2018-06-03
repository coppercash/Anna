//
//  RootAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

@objc(ANARootAnalyzer) @objcMembers
public class
    RootAnalyzer : BaseAnalyzer
{
    public let
    name :String,
    manager :Manager
    @objc(initWithManager:name:)
    public
    init(
        manager :Manager,
        name :String
        )
    {
        self.manager = manager
        self.name = name
        super.init()
    }
    /*
    override func
        resolvedAttributes() throws -> Recording.Properties {
        return [
            "__name__": self.name,
        ]
    }
   
    // MARK: - Context
    
    typealias
        ContextCallback = IdentityContextResolving.Callback
    func
        resolveContext(
        then callback : @escaping ContextCallback
        ) throws {
        let
        analyzer = self,
        namespace = self.resolvedNamespace,
        manager = self.manager
        if let
            context = analyzer.resolvedContext
        { return try callback(context) }
        let
        identifier = NodeID(owner: self)
        try manager.registerNode(
            by: identifier,
            under: nil,
            name: analyzer.name,
            index: nil,
            namespace: namespace
        )
        let
        context = IdentityContext(
            manager: manager,
            parentID: nil,
            identifier: identifier,
            prefix: NodeID.empty()
        )
        
        analyzer.resolvedContext = context
        return try callback(context)
    }
 */
    
    // MARK: - Node Identity
    
    override func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) throws {
        let
        manager = self.manager
        if let
            nodeID = self.nodeID
        { return try callback(manager, nodeID) }
        let
        nodeID = NodeID.owned(by: self),
        context = IdentityContext(
            manager: manager,
            parentID: nil,
            identifier: nodeID,
            name: self.name,
            index: nil
        )
        try self.bindNode(with: context)
        return try callback(manager, nodeID)
    }
    override func
        bindNode(
        with context: IdentityContext
        ) throws {
        guard self.nodeID == nil
            else { return }
        let
        manager = context.manager,
        nodeID = context.identifier
        self.nodeID = nodeID
        try manager.registerNode(
            by: nodeID,
            under: context.parentID,
            name: context.name,
            index: context.index,
            namespace: nil
        )
    }
    override func
        unbindNode() throws {
        let
        manager = self.manager
        guard let
            nodeID = self.nodeID
            else { return }
        try manager.deregisterNodes(by: nodeID)
        self.nodeID = nil
    }
}

extension
    RootAnalyzer : Analyzing
{
    public func markFocused() { }
    
    public func observe(owner :NSObject, for keyPath :String) { }
    
    public func observe(_ observee: NSObject, for keyPath: String) { }
    
    public func hook(_ hookee: Hookable) { }
    
    public func detach() { }
    
    public func update(_ value: Any?, for keyPath: String) { }
    
    public func record(_ event: String) { }
    
    public func enable(with key: String) { }
    
    public func setSubAnalyzer(_ sub: Analyzing, for key: String) { }
    
    public func setSubAnalyzers(_ subs: [Analyzing], for key: String) { }
}

