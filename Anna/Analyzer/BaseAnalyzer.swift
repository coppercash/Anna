//
//  BaseAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

class
    IdentityContext
{
    let
    manager :Manager,
    parentID :NodeID?,
    identifier :NodeID,
    suffix :NodeID
    init(
        manager :Manager,
        parentID :NodeID?,
        identifier :NodeID,
        suffix :NodeID
        ) {
        self.manager = manager
        self.parentID = parentID
        self.identifier = identifier
        self.suffix = suffix
    }
}

protocol
    IdentityContextResolving : class
{
    var
    resolvedContext :IdentityContext? { get }
    typealias
        Callback = (IdentityContext) throws -> Void
    func
        resolveContext(
        then callback : @escaping Callback
    ) throws
    typealias
        Notify = () -> Void
    func
        notifyAfterContextReset(
        _ notify : @escaping Notify
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
   
    deinit {
        self.notifyContextReset()
        try? self.deregisterIdentityNodes()
    }
    
    // MARK: - Identity Context
    
    var
    resolvedContext :IdentityContext? = nil {
        didSet {
            guard let _ = oldValue, self.resolvedContext == nil
                else { return }
            self.notifyContextReset()
        }
    }
    var
    contextResetingNotifications :[IdentityContextResolving.Notify] = []
    func
        notifyAfterContextReset(_ notify : @escaping IdentityContextResolving.Notify) {
        self.contextResetingNotifications.append(notify)
    }
    func
        notifyContextReset() {
        for notify in self.contextResetingNotifications {
            notify()
        }
        self.contextResetingNotifications.removeAll()
    }
    func
        deregisterIdentityNodes() throws {
        guard let
            contextResolver = self as? IdentityContextResolving,
            let
            manager = contextResolver.resolvedContext?.manager
            else { throw ContextError.unresolvedManager }
        let
        id = NodeID(owner: self)
        try manager.deregisterNodes(by: id)
    }

    // MARK: - Event Recording
    
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
        contextResolver = self as! IdentityContextResolving,
        expressable = properties?.toJSExpressable() ?? [:]
        
        try! contextResolver.resolveContext { (context) in
            let
            manager = context.manager
            try manager.recordEvent(
                named: name,
                with: expressable,
                onNodeBy: context.identifier
            )
        }
    }
    var
    tokens :[Reporting] = []
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
    public func
        detach() {
        self.tokens.removeAll()
    }

    // MARK: - Child Analyzer
    
    var
    childAnalyzer :[AnyHashable : IdentityContextResolving] = [:]
    /*
    func
        resolvedChildAnalyzer(
        named name :String,
        with identifier :AnyHashable
        ) ->IdentityContextResolving
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
 */
}

extension
    BaseAnalyzer : FocusPathConstituting, AnalyzerReadable
{
    public var
    analyzer: Analyzing? { return self }
    public func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
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
    ContextError : Error
{
    case unresolvedManager
    case unsetupAnalysisObject(description :String)
}
extension
    ContextError : LocalizedError
{
    public var
    errorDescription: String? {
        switch self {
        case .unresolvedManager:
            return "Cannot find a resolved manager in context."
        case .unsetupAnalysisObject(description: let description):
            return "Unsetup analysis object \(description)."
        }
    }
}

enum
    ParentError : Error
{
    case abstractMethod(name :String)
    case noDelegate(name :String)
    case brokenChain(breaking :String)
    case tooManyDeferredContextRequirings(node :String)
    case unresolvedParenthood
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
        case .unresolvedParenthood:
            return "Unexpected unresolved parenthood."
        }
    }
}
