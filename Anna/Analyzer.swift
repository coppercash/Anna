//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

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
    @objc(ana_tokenByAddingObserver) func
        tokenByAddingObserver() -> Reporting
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
    func
        resolvedManager() throws
        -> Manager
    func
        resolvedNodeLocatorByAppendingPath() throws
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
        deregisterLastLocator() throws {
    }
}

@objc(ANARootAnalyzer)
public class
    RootAnalyzer : BaseAnalyzer, AnalyzerParenting, Analyzing
{
    let
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
    }

    func
        resolvedManager()
        -> Manager
    {
        return self.manager
    }
    
    func
        resolvedNodeLocatorByAppendingPath()
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
    
    func
        resolvedSubAnalyzer(named name: String) -> Analyzing {
        return type(of: self).resolvedSubAnalyzer(named: name, under: self)
    }
    
    override func
        deregisterLastLocator() throws {
        if let locator = self.lastRegisteredLocator {
            self.manager.deregisterNode(by: locator)
        }
    }
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
        try? self.deregisterLastLocator()
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
    
    func
        resolvedParent() throws
        -> AnalyzerParenting
    {
        let
        analyzer = self
        let
        parent = try analyzer._resolvedParent()
        analyzer.manager = try parent.resolvedManager()
        return parent
    }
    
    func
        _resolvedParent() throws
        -> AnalyzerParenting
    {
        guard let
            delegate = self.delegate
            else { throw ParentError.noDelegate(name: self.resolvedName()) }
        var
        last = delegate,
        next = delegate.parentConsititutor()
        while true {
            guard let consititutor = next
                else { throw ParentError.brokenChain(breaking: String(describing: type(of: last))) }
            if let
                owner = consititutor as? AnalyzerOwning,
                let
                parent = owner.analyzer as? AnalyzerParenting
            { return parent }
            last = consititutor
            next = consititutor.parentConsititutor()
        }
    }
    
    var
    manager :Manager? = nil
    func
        resolvedManager() throws
        -> Manager
    {
        let
        analyzer = self
        if let manager = analyzer.manager
        { return manager }
        let
        parent = try analyzer.resolvedParent()
        let
        manager = try parent.resolvedManager()
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

    func
        resolvedNodeLocatorByAppendingPath() throws
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
        parent = try analyzer.resolvedParent(),
        parentLocator = try parent.resolvedNodeLocatorByAppendingPath()

        // Register self
        //
        let
        manager = try analyzer.resolvedManager(),
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
        self.tokens.append(token)
    }
    
    public func
        observe(
        _ observee :NSObject,
        for keyPath :String
        ) {
        let
        token = KVObserver(observee, keyPath)
        token.recorder = self
        self.tokens.append(token)
    }
    
    func
        takePlace(of analyzer :Analyzer) {
        if analyzer === self { return }
        for token in analyzer.tokens {
            token.recorder = self
            self.tokens.append(token)
        }
        analyzer.tokens.removeAll()
    }
    
    func
        detach() {
        self.tokens.removeAll()
    }
    
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
        with properties :Event.Properties? = nil
        ) {
        let
        analyzer = self,
        expressable = properties?.toJSExpressable() ?? [:]
        try! analyzer.resolveContext { (manager, locator) in
            manager.recordEvent(
                named: name,
                with: expressable,
                locator: locator
            )
        }
    }
    typealias
        NodeContextResolution = (
        _ manager :Manager,
        _ parent :NodeLocator
        ) -> Void
    var
    deferredNodeContextRequirings :[NodeContextResolution] = []
    func
        resolveContext(
        then : @escaping NodeContextResolution
        ) throws {
        let
        analyzer = self
        analyzer.deferredNodeContextRequirings.append(then)
        guard let
            locator = try? analyzer.resolvedNodeLocatorByAppendingPath(),
            let
            manager = try? analyzer.resolvedManager()
            else
        {
            guard analyzer.deferredNodeContextRequirings.count < 7 else {
                throw ParentError.tooManyDeferredContextRequirings(node: analyzer.name)
            }
            return
        }
        for resolve in analyzer.deferredNodeContextRequirings {
            resolve(manager, locator)
        }
        analyzer.deferredNodeContextRequirings.removeAll()
    }
    
    override func
        deregisterLastLocator() throws {
        if let locator = self.lastRegisteredLocator {
            let
            manager = try self.resolvedManager()
            manager.deregisterNode(by: locator)
        }
    }
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

extension
    Dictionary
    where Key == String, Value : Any
{
    func
        toJSExpressable() -> Manager.Properties {
        return self
    }
}

enum
    ParentError : Error
{
    case noDelegate(name :String)
    case brokenChain(breaking :String)
    case tooManyDeferredContextRequirings(node :String)
}
extension
    ParentError : LocalizedError
{
    public var
    errorDescription: String? {
        switch self {
        case .noDelegate(name: let name):
            return "Analyzer '\(name)' has no delegate to resolve a parent."
        case .brokenChain(breaking: let breaking):
            return "Path chain is broken, because node '\(breaking)' has no parent."
        case .tooManyDeferredContextRequirings(node: let node):
            return "Too many deferred node context requirings on node '\(node)'."
        }
    }
}
