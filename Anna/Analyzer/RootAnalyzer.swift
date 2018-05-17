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
    manager :Manager
    @objc(initWithManager:name:)
    public
    init(
        manager :Manager,
        name :String
        )
    {
        self.manager = manager
        super.init(name: name)
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
        name = self.name,
        manager = self.manager
        if let
            context = analyzer.resolvedContext
        { return try callback(context) }
        let
        identifier = NodeID(owner: self)
        try manager.registerNode(
            by: identifier,
            named: name,
            under: nil
        )
        let
        context = IdentityContext(
            manager: manager,
            parentID: nil,
            identifier: identifier,
            suffix: NodeID.empty()
        )
        
        analyzer.resolvedContext = context
        return try callback(context)
    }
}
