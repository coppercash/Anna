//
//  ANAAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

@objc(ANAAnalyzerOwner)
public protocol
    AnalyzerOwner
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing { get }
}
//
//extension
//    NSObject : AnalyzerOwner
//{
//    public var
//    ana_analyzer: ANAAnalyzer {
//        get {
//            
//        }
//    }
//}

@objc(ANAAnalyzing)
public protocol
Analyzing
{
    typealias
        Manager = ANAManager
    func
        resolvedManager()
        -> Manager
    func
        nodeLocatorByAppendingPath()
        -> Manager.NodeLocator
}

@objc(ANAPathConstituting)
public protocol
PathConstituting
{
    @objc(ana_parentPathNode)
    func
        parentConsititutor() -> PathConstituting?
    @objc(ana_pathNodeName)
    func
        pathNodeName() -> String
}


public class
    BaseAnalyzer : NSObject
{
    public typealias
        Manager = ANAManager
    var
    lastRegisteredLocator :Manager.NodeLocator? = nil
}

@objc(ANARootAnalyzer)
public class
    RootAnalyzer : BaseAnalyzer, Analyzing
{
    var
    manager :Manager
    
    @objc(initWithManager:)
    public
    init(
        manager :Manager
        )
    {
        self.manager = manager
    }
    
    public func
        resolvedManager()
        -> Manager
    {
        return self.manager
    }
    
    func
        resolvedName()
        -> String
    {
        return "root"
    }
    
    public func
        nodeLocatorByAppendingPath()
        -> Manager.NodeLocator
    {
        let
        analyzer = self
        
        // Register node for self if hasn't yet
        //
        if let locator = analyzer.lastRegisteredLocator {
            return locator
        }
        
        // Register self
        let
        manager = analyzer.resolvedManager(),
        name = analyzer.resolvedName(),
        objID = ObjectIdentifier(analyzer),
        locator = manager.nodeLocator(
            with: name,
            ownerID: objID
        )
        manager.registerRootNode(by: locator)
        
        // Mark registered
        //
        analyzer.lastRegisteredLocator = locator
        return locator
    }
}

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, Analyzing
{
    public typealias
        Delegate = PathConstituting
    var
    delegate :Delegate
    @objc(initWithDelegate:)
    public init
        (with delegate: Delegate)
    {
        self.delegate = delegate
    }
    
    public func
        observe()
    {
        
    }
    
    var
    parent :Analyzing? = nil
    func
        resolvedParent()
        -> Analyzing?
    {
        let
        analyzer = self
        
        if let parent = analyzer.parent {
            return parent
        }
        
        let
        parent = analyzer.resolvedParentOwner()?.analyzer
        analyzer.parent = parent
        // TODO: catch nil
        return parent
    }
    
    func
        resolvedParentOwner()
        -> AnalyzerOwner?
    {
        let
        analyzer = self
        var
        next = analyzer.delegate.parentConsititutor()
        while true {
            guard let consititutor = next else {
                return nil
            }
            if let owner = consititutor as? AnalyzerOwner {
                return owner
            }
            next = consititutor.parentConsititutor()
        }
    }
    
    var
    manager :Manager? = nil
    public func
        resolvedManager()
        -> Manager
    {
        let
        analyzer = self
        
        if let manager = analyzer.manager {
            return manager
        }
        let
        parent = analyzer.resolvedParent()!
        // TODO: remove forced unpack
        let
        manager = parent.resolvedManager()
        analyzer.manager = manager
        // TODO: catch nil
        return manager
    }
    
    func
        resolvedName()
        -> String
    {
        return self.delegate.pathNodeName()
    }

    public func
        nodeLocatorByAppendingPath()
        -> Manager.NodeLocator
    {
        let
        analyzer = self

        // Register node for self if hasn't yet
        //
        if let locator = analyzer.lastRegisteredLocator {
            return locator
        }

        // Notify all ancestors to register themself
        //
        let
        parent = analyzer.resolvedParent()!,
        parentLocator = parent.nodeLocatorByAppendingPath()
        // TODO: remove forced unpack

        // Register self
        //
        let
        manager = analyzer.resolvedManager(),
        name = analyzer.resolvedName(),
        objID = ObjectIdentifier(analyzer),
        locator = manager.nodeLocator(
            with: name,
            ownerID: objID
        )
        manager.registerNode(
            by: locator,
            under: parentLocator
        )
       
        // Mark registered
        //
        analyzer.lastRegisteredLocator = locator
        return locator
    }
    
    func
        recordEventOnPath(
        with properties :[String: AnyObject]
        ) {
        let
        analyzer = self
        let
        _ = analyzer.nodeLocatorByAppendingPath()
        let
        manager = analyzer.resolvedManager()
        manager.recordEvent(
            with: properties,
            locator: analyzer.lastRegisteredLocator!
        )
    }
}

@objc(ANAUIControlAnalyzer)
public class
    UIControlAnalyzer : Analyzer
{
    @objc(hookControl:)
    public func
        hook(
        _ control :UIControl
        ) {
        control.addTarget(
            self,
            action: #selector(handle(control:event:)),
            for: .allEvents)
    }
    
    func
        handle(
        control :UIControl,
        event :UIEvent
        ) {
        self.recordEventOnPath(
            with: [
                "uievent-type": NSNumber(value: event.type.rawValue),
                "uievent-subtype": NSNumber(value: event.subtype.rawValue),
            ]
        )
    }
}
