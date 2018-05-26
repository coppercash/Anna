//
//  RootAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

@objc(ANARootAnalyzer) @objcMembers
public class
    RootAnalyzer : BaseAnalyzer, IdentityContextResolving
{
    public let
    manager :Manager,
    name :String
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
        manager = self.manager
        if let
            context = analyzer.resolvedContext
        { return try callback(context) }
        let
        identifier = NodeID(owner: self)
        try manager.registerNode(
            by: identifier,
            under: nil,
            name: analyzer.name
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
}

extension
    RootAnalyzer : Analyzing
{
    public func
        observe(
        owner :NSObject,
        for keyPath :String
        ) { }
    public func observe(_ observee: NSObject, for keyPath: String) { }
    
    public func hook(_ hookee: Hookable) { }
    
    public func detach() { }
    
    public func update(_ value: Any?, for keyPath: String) { }
    
    public func record(_ event: String) { }
    
    public func enable(with key: String) { }
    
    public func setSubAnalyzer(_ sub: Analyzing, for key: String) { }
    
    public func setSubAnalyzers(_ subs: [Analyzing], for key: String) { }
}

