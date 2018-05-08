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
        Recorder = Recording
    weak var
    recorder :Recorder? { get set }
}

@objc(ANARecording)
public protocol
    Recording
{
    typealias
    Properties = NSObject.Propertiez
    func
        recordEventOnPath(
        named name :String,
        with properties :Properties?
    )
}

@objc(ANAHookable)
public protocol
    Hookable
{
    @objc(ana_tokenByAddingObserver)
    func
        tokenByAddingObserver() -> Reporting
    @objc(ana_tokenByAddingOwnedObserver)
    func
        tokenByAddingOwnedObserver() -> Reporting
}

@objc(ANAPathConstituting)
public protocol
PathConstituting
{
    @objc(ana_parentConsititutorForChild:requiredByDescendant:)
    func
        parentConsititutor(
        for child :PathConstituting,
        requiredBy descendant :PathConstituting
        ) -> PathConstituting?
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
    BaseAnalyzer : NSObject, Recording, Analyzing
{
    let
    name :String
    init(
        name :String
        ) {
        self.name = name
    }
    
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
    func
        resolvedNodeLocatorByAppendingPath() throws -> Manager.NodeLocator {
        throw ParentError.abstractMethod(name: #function)
    }
    func
        resolvedManager() throws -> Manager {
        throw ParentError.abstractMethod(name: #function)
    }

    var
    tokens = Array<Reporting>()
    public func
        hook(_ hookee :Hookable) {
        let
        token = hookee.tokenByAddingObserver()
        token.recorder = self
        self.tokens.append(token)
    }
    func
        hook(owner :Hookable) {
        let
        token = owner.tokenByAddingOwnedObserver()
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
    public func
        recordEventOnPath(
        named name :String,
        with properties :Properties? = nil
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
}

@objc(ANARootAnalyzer)
public class
    RootAnalyzer : BaseAnalyzer, AnalyzerParenting
{
    let
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
    RootAnalyzer : PathConstituting, AnalyzerReadable
{
    public var
    analyzer: Analyzing? { return self }
    public func
        parentConsititutor(
        for child :PathConstituting,
        requiredBy descendant :PathConstituting
        ) -> PathConstituting? {
        return self
    }
}

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, AnalyzerParenting
{
    public typealias
        Delegate = PathConstituting
    weak var
    delegate :Delegate?
    @objc(initWithName:delegate:)
    public init
        (
        with name :String,
        delegate :Delegate
        ) {
        self.delegate = delegate
        super.init(name: name)
    }
    deinit {
        try? self.deregisterLastLocator()
    }

    /*
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
 */
    
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
        next = delegate.parentConsititutor(
            for: last,
            requiredBy: delegate
        )
        while true {
            guard let consititutor = next
                else { throw ParentError.brokenChain(breaking: String(describing: type(of: last))) }
            if let
                owner = consititutor as? AnalyzerReadable,
                let
                parent = owner.analyzer as? AnalyzerParenting
            { return parent }
            next = consititutor.parentConsititutor(
                for: last,
                requiredBy: delegate
            )
            last = consititutor
        }
    }
    
    var
    manager :Manager? = nil
    override func
        resolvedManager() throws -> Manager {
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

    override func
        resolvedNodeLocatorByAppendingPath() throws -> Manager.NodeLocator {
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
    Analyzer : PathConstituting, AnalyzerReadable
{
    public var
    analyzer: Analyzing? { return self }
    public func
        parentConsititutor(
        for child :PathConstituting,
        requiredBy descendant :PathConstituting
        ) -> PathConstituting? {
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
    case abstractMethod(name :String)
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
        case .abstractMethod(name: let name):
            return "Must not call abstract method '\(name)'."
        case .noDelegate(name: let name):
            return "Analyzer '\(name)' has no delegate to resolve a parent."
        case .brokenChain(breaking: let breaking):
            return "Path chain is broken, because node '\(breaking)' has no parent."
        case .tooManyDeferredContextRequirings(node: let node):
            return "Too many deferred node context requirings on node '\(node)'."
        }
    }
}
