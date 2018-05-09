//
//  RootAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

@objc(ANARootAnalyzer) @objcMembers
public class
    RootAnalyzer : BaseAnalyzer, AnalyzerParenting
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
    
    override func
        resolvedManager() throws -> Manager {
        return self.manager
    }
    
    override func
        resolvedNodeLocatorByAppendingPath() throws -> Manager.NodeLocator {
        let
        analyzer = self
        
        // Register node for self if hasn't yet
        //
        if let locator = analyzer.lastRegisteredLocator {
            return locator
        }
        
        // Register self
        //
        let
        manager = try analyzer.resolvedManager(),
        objID = ObjectIdentifier(analyzer),
        locator = manager.rootNodeLocator(
            ownerID: objID,
            name: self.name
        )
        manager.registerNode(
            by: locator,
            under: nil
        )
        
        // Mark registered
        //
        analyzer.lastRegisteredLocator = locator
        return locator
    }
    
    override func
        deregisterLastLocator() throws {
        if let locator = self.lastRegisteredLocator {
            self.manager.deregisterNode(by: locator)
        }
    }
}
