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
    static let
    name :String = "__root__"
    public let
    manager :Manager
    @objc(initWithManager:)
    public
    init(
        manager :Manager
        )
    {
        self.manager = manager
        super.init()
    }

    // MARK: - Node Identity
    
    override func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) throws {
        let
        manager = self.manager
        if let
            identity = self.identity
        { return try callback(identity) }
        let
        nodeID = NodeID.owned(by: self),
        context = IdentityContext(
            manager: manager,
            nodeID: nodeID,
            parentID: nil,
            name: RootAnalyzer.name,
            index: nil
        )
        try self.bindNode(with: context)
        return try callback(self.identity!)
    }
}

extension
    RootAnalyzer : Analyzing
{
    public func markFocused() { }
    
    public func observe(_ observee: NSObject, for keyPath: String) { }
    
    public func hook(_ hookee: Hookable) { }
    
    public func detach() { }
    
    public func update(_ value: Any?, for keyPath: String) { }
    
    public func record(_ event: String, with attributes: Manager.Attributes?) { }
    
    public func enable(naming key: String) { }
    
    public func setSubAnalyzer(_ sub: Analyzing, for key: String) { }
    
    public func setSubAnalyzers(_ subs: [Analyzing], for key: String) { }
}
