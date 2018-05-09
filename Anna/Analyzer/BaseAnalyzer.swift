//
//  BaseAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

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
    childAnalyzer :[AnyHashable : Analyzer] = [:]
    
    func
        resolvedChildAnalyzer(
        named name :String,
        with identifier :AnyHashable
        ) ->Analyzer
    {
        let
        parent = self;
        if let
            child = parent.childAnalyzer[identifier]
        { return child }
        let
        child = Analyzer(
            with: name,
            delegate: parent
        )
        parent.childAnalyzer[identifier] = child
        return child
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
        token = KVObserver(
            keyPath: keyPath,
            observee: observee,
            owned: false
        )
        token.recorder = self
        self.tokens.append(token)
    }
    public func
        observe(
        owner :NSObject,
        for keyPath :String
        ) {
        let
        token = KVObserver(
            keyPath: keyPath,
            observee: owner,
            owned: true
        )
        token.recorder = self
        self.tokens.append(token)
    }
    public func
        update(
        _ value :Any,
        for keyPath :String
        ) {
        self.recordEventOnPath(
            named: "ana-value-updated",
            with: [
                "key-path": keyPath,
                "value": value
            ]
        )
    }
    func
        startForwardingEvents(
        to recorder: Recording
        ) {
        for token in self.tokens {
            token.recorder = recorder
        }
    }
    func
        stopForwardingEvents() {
        for token in self.tokens {
            token.recorder = self
        }
    }
    func
        flushDeferredEvents(
        to another: BaseAnalyzer
        ) {
        let
        analyzer = self
        another.deferredNodeContextRequirings.append(contentsOf: analyzer.deferredNodeContextRequirings)
        analyzer.deferredNodeContextRequirings.removeAll()
    }
    //    func
    //        takePlace(of analyzer :Analyzer) {
    //        if analyzer === self { return }
    //        for token in analyzer.tokens {
    //            token.recorder = self
    //            self.tokens.append(token)
    //        }
    //        analyzer.tokens.removeAll()
    //    }
    //    func
    //        detach() {
    //        self.tokens.removeAll()
    //    }
    
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

extension
    BaseAnalyzer : PathConstituting, AnalyzerReadable
{
    public var
    analyzer: Analyzing? { return self }
    public func
        parentConsititutor(
        for child :PathConstituting,
        requiredFrom descendant :PathConstituting
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
