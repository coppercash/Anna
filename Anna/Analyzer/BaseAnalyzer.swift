//
//  BaseAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/5/10.
//

import Foundation

class
    IdentityContext : Equatable
{
    let
    manager :Manager,
    parentID :NodeID?,
    identifier :NodeID,
    prefix :NodeID
    init(
        manager :Manager,
        parentID :NodeID?,
        identifier :NodeID,
        prefix :NodeID
        ) {
        self.manager = manager
        self.parentID = parentID
        self.identifier = identifier
        self.prefix = prefix
    }
    static func
        == (
        lhs: IdentityContext,
        rhs: IdentityContext
        ) -> Bool {
        return lhs.manager === rhs.manager &&
            lhs.parentID == rhs.parentID &&
            lhs.identifier == rhs.identifier &&
            lhs.prefix == rhs.prefix
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
    BaseAnalyzer : NSObject, Recording
{
//    let
//    name :String?
//    init(
//        name :String
//        ) {
//        self.name = name
//    }
   
    deinit {
        self.notifyContextReset()
        try? self.deregisterIdentityNodes()
    }
    
    func
        resolvedAttributes() throws -> Properties {
        return [:]
    }
    
    /*
    var
    subAnalyzerBuffer :[SubAnalyzerWrapper] = []
    func
        flushSubAnalyzerBuffer() {
        for wrapper in self.subAnalyzerBuffer {
            guard let
                sub = wrapper.analyzer
                else { continue }
            sub.resolvedParentAnalyzer = self
            sub.resolvedParentship = true
            sub.enable()
        }
        self.subAnalyzerBuffer.removeAll()
    }
    public func
        enable(with key :String) {
    }
    public func
        setSubAnalyzer(
        _ sub :Analyzing,
        for key:String
        ) {
        guard let sub = sub as? Analyzer
            else { return }
        sub.key = key
        self.subAnalyzerBuffer.append(
            SubAnalyzerWrapper(sub)
        )
        if self.isEnabled {
            self.flushSubAnalyzerBuffer()
        }
    }
    public func
        setSubAnalyzers(_ subs: [Analyzing], for key: String) {
        for (i, sub) in subs.enumerated() {
            guard let sub = sub as? Analyzer
                else { continue }
            sub.key = key
            sub.index = i
            self.subAnalyzerBuffer.append(
                SubAnalyzerWrapper(sub)
            )
        }
        if self.isEnabled {
            self.flushSubAnalyzerBuffer()
        }
    }
 */

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
    
    var
    resolvedNamespace :String? = nil
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
    case unresolvedName
}
extension
    ContextError : LocalizedError
{
    public var
    errorDescription: String? {
        switch self {
        case .unresolvedManager:
            return "Cannot find a resolved manager in context."
        case .unresolvedName:
            return "Enable analyzer before analyzing."
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
