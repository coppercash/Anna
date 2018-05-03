//
//  ANAAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

@objc(ANAAnalyzerOwning)
public protocol
    AnalyzerOwning
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing? { get }
}

@objc(ANAAnalyzerHolding)
public protocol
    AnalyzerHolding : AnalyzerOwning
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing? { get set }
}

@objc(ANAReporting)
public protocol
Reporting
{
    typealias
        Recorder = Analyzer
    weak var
    recorder :Recorder? { get set }
}

@objc(ANAHookable)
public protocol
    Hookable
{
    func
        tokenByAddingObserver() -> Reporting
}

@objc(ANAAnalyzing)
public protocol
Analyzing
{
    // Keep this empty
    // no promised action after being registered
    //
}

@objc(ANAPathConstituting)
public protocol
PathConstituting
{
    @objc(ana_parentPathNode)
    func
        parentConsititutor() -> PathConstituting?
}

protocol
    AnalyzerParenting : class
{
    typealias
        Manager = ANAManager
    func
        resolvedManager()
        -> Manager
    func
        nodeLocatorByAppendingPath()
        -> Manager.NodeLocator
    typealias
        Notification = () -> Void
    func
        notifyOnReseting(
        _ locator :NodeLocator,
        byCalling callback : @escaping Notification
    )
}

public class
    BaseAnalyzer : NSObject
{
    public typealias
        Manager = ANAManager
    var
    lastRegisteredLocator :Manager.NodeLocator? = nil
    deinit {
        self.resetLastRegisteredLocator()
    }

    var
    subAnalyzers :[String : Analyzing] = [:]
    
    class func
        resolvedSubAnalyzer(
        named name :String,
        under parent :(BaseAnalyzer & PathConstituting)
        ) ->Analyzing
    {
        if let sub = parent.subAnalyzers[name] {
            return sub
        }
        let
        sub = Analyzer(
            with: name,
            delegate: parent
        )
        parent.subAnalyzers[name] = sub
        return sub
    }
    
    var
    notifications :[AnalyzerParenting.Notification] = []
    func
        notifyLastRegisteredLocatorReset() {
        for note in self.notifications {
            note()
        }
        self.notifications.removeAll()
    }
    
    func
        notifyOnReseting(
        _ locator :NodeLocator,
        byCalling callback : @escaping AnalyzerParenting.Notification
        ) {
        self.notifications.append(callback)
    }
    
    func
        resetLastRegisteredLocator() {
        self.lastRegisteredLocator = nil
        self.notifyLastRegisteredLocatorReset()
    }
    
    func
        deregisterLastLocator() {
    }
}

@objc(ANARootAnalyzer)
public class
    RootAnalyzer : BaseAnalyzer, AnalyzerParenting, Analyzing
{
    let
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
        return "ana-root"
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
        //
        let
        manager = analyzer.resolvedManager(),
        objID = ObjectIdentifier(analyzer),
        locator = manager.rootNodeLocator(
            ownerID: objID
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
    
    public func
        resolvedSubAnalyzer(named name: String) -> Analyzing {
        return type(of: self).resolvedSubAnalyzer(named: name, under: self)
    }
    
    override func
        deregisterLastLocator() {
        if let locator = self.lastRegisteredLocator {
            self.manager.deregisterNode(by: locator)
        }
    }

//    override func
//        resetLastRegisteredLocator() {
//        if let locator = self.lastRegisteredLocator {
//            self.manager.deregisterNode(by: locator)
//        }
//        super.resetLastRegisteredLocator()
//    }
}

extension
    RootAnalyzer : PathConstituting, AnalyzerOwning
{
    public var
    analyzer: Analyzing? {
        return self
    }
    public func
        parentConsititutor() -> PathConstituting? {
        return self
    }
}

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, AnalyzerParenting, Analyzing
{
    public typealias
        Delegate = PathConstituting
    let
    name :String
    weak var
    delegate :Delegate?
    @objc(initWithName:delegate:)
    public init
        (
        with name :String,
        delegate :Delegate
        ) {
        self.name = name
        self.delegate = delegate
    }
    deinit {
        self.deregisterLastLocator()
    }

    @objc(analyzerHookingDelegate:naming:)
    public class func
        hooking(
        delegate :(Delegate & Hookable),
        naming name :String
        ) -> Self {
        let
        analyzer = self.init(
            with: name,
            delegate: delegate
        )
        analyzer.hook(delegate)
        return analyzer
    }
    
//    weak var
//    parent :AnalyzerParenting? = nil
    func
        resolvedParent()
        -> AnalyzerParenting?
    {
        let
        analyzer = self
        
//        if let parent = analyzer.parent {
//            return parent
//        }
        
        // TODO: catch nil, remove casting
        guard let
            parent = analyzer.resolvedParentOwner()?.analyzer as? AnalyzerParenting
            else { return nil }
        analyzer.manager = parent.resolvedManager()
        
        return parent
    }
    
    func
        resolvedParentOwner()
        -> AnalyzerOwning?
    {
        guard let
            delegate = self.delegate
            else { return nil }
        // TODO: throw
        var
        next = delegate.parentConsititutor()
        while true {
            guard let consititutor = next else {
                return nil
            }
            if let owner = consititutor as? AnalyzerOwning {
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
        return self.name
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
        locator = parentLocator.forked(
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
        parent.notifyOnReseting(parentLocator) { [weak analyzer] in
            analyzer?.resetLastRegisteredLocator()
        }

        return locator
    }
    
    @objc(resolvedSubAnalyzerNamed:)
    public func
        resolvedSubAnalyzer(named name: String) -> Analyzing {
        return type(of: self).resolvedSubAnalyzer(named: name, under: self)
    }
    
    var
    tokens = Array<Reporting>()
    public func
        hook(_ hookee : Hookable) {
        let
        token = hookee.tokenByAddingObserver()
        token.recorder = self
        tokens.append(token)
    }
    
    @objc(takePlaceOfAnalyzer:)
    public func
        takePlace(of analyzer :Analyzer) {
        if analyzer === self { return }
        for token in analyzer.tokens {
            token.recorder = self
            self.tokens.append(token)
        }
        analyzer.tokens.removeAll()
    }
    
    public func
        detach() {
        self.tokens.removeAll()
    }
    
    public typealias
        Properties = [String: AnyObject]
    func
        recordEventOnPath(
        named name :String,
        with properties :Properties
        ) {
        let
        analyzer = self
        let
        _ = analyzer.nodeLocatorByAppendingPath()
        let
        manager = analyzer.resolvedManager()
        manager.recordEvent(
            named: name,
            with: properties,
            locator: analyzer.lastRegisteredLocator!
        )
    }
    
    override func
        deregisterLastLocator() {
        if let locator = self.lastRegisteredLocator {
            self.resolvedManager().deregisterNode(by: locator)
        }
    }
//    override func
//        resetLastRegisteredLocator() {
//        if let locator = self.lastRegisteredLocator {
//            self.resolvedManager().deregisterNode(by: locator)
//        }
//        super.resetLastRegisteredLocator()
//    }
}

extension
    Analyzer : PathConstituting, AnalyzerOwning
{
    public var
    analyzer: Analyzing? {
        return self
    }
    public func
        parentConsititutor() -> PathConstituting? {
        return self
    }
}

