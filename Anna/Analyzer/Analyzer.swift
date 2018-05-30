//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

class
SubAnalyzerWrapper {
    weak var
    analyzer :Analyzer?
    init(
        _ analyzer :Analyzer
        ) {
        self.analyzer = analyzer
    }
}

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, IdentityContextResolving, FocusHandling
{
    public typealias
        Delegate = FocusPathConstituting
    weak var
    delegate :Delegate?

    /*
    @objc(initWithName:delegate:)
    public init
        (
        with name :String,
        delegate :Delegate
        ) {
        self.delegate = delegate
        super.init(name: name)
        self.resolvedNamespace = String(describing: type(of: delegate))
    }
     */
    
    init(
        delegate :Delegate
        ) {
        super.init()
        self.delegate = delegate
        self.resolvedNamespace = String(describing: type(of: delegate))
    }
    @objc(analyzerWithDelegate:)
    public class func
        analyzer(
        with delegate :Delegate
        ) -> Self {
        return self.init(delegate: delegate)
    }
   
    /*
    var
    resolvedName :String? = nil
    var
    deferredNameResolutions :[NameCallback] = []
    typealias
        NameCallback = (String) throws -> Void
    func
        resolvedName(
        then callback : @escaping NameCallback
        ) throws {
        let
        analyzer = self
        guard let
            name = analyzer.resolvedName
        else { return analyzer.deferredNameResolutions.append(callback); }
        try callback(name)
    }
    func
        flushDeferredNameResolutions() throws {
        guard let
            name = self.resolvedName
            else { throw ContextError.unresolvedName }
        let
        resolutions = self.deferredNameResolutions
        for resolve in resolutions {
            try resolve(name)
        }
        self.deferredNameResolutions.removeAll()
    }
 */

    var
    key :String? = nil,
    index :Int? = nil
    override func
        resolvedAttributes() throws -> Recording.Properties {
        guard let key = self.key else { throw ContextError.unresolvedName  }
        var
        attributes :Properties = [
            "__name__": key
        ]
        if let index = self.index {
            attributes["__index__"] = index
        }
        return attributes
    }
    
    var
    tokens :[Reporting] = []

    var
    isEnabled = false
    func
        enable() {
        guard self.isEnabled == false
            else { return }
        self.isEnabled = true
        if let delegate = self.delegate as? Hookable {
            self.hook(owner: delegate)
        }
        self.flushSubAnalyzerBuffer()
    }
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
            try! sub.flushDeferredResolutions()
        }
        self.subAnalyzerBuffer.removeAll()
    }
    
    public func
        enable(with key :String) {
        self.key = key;
        self.enable()
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

    // MARK: - Focus Path
    
    class
    FocusParenthood {
        let
        parent :IdentityContextResolving,
        child :BaseAnalyzer,
        isOwning :Bool
        init(
            parent :IdentityContextResolving,
            child :BaseAnalyzer,
            isOwning :Bool
            ) {
            self.parent = parent
            self.child = child
            self.isOwning = isOwning
        }
    }

    func
        parenthoodByLookingUp() throws -> (IdentityContextResolving, Bool)? {
        guard let
            delegate = self.delegate
            else { return nil }
        var
        isParentOwning = false,
        next = delegate.parentConstitutor(
            isOwning: &isParentOwning
        )
        while let
            current = next
        {
            if let owner = current as? AnalyzerReadable {
                guard let
                    parent = owner.analyzer as? IdentityContextResolving
                    else
                {
                    throw ContextError.unsetupAnalysisObject(
                        description: String(describing: owner)
                    )
                }
                return (parent, isParentOwning)
            }
            var
            isOwning = false
            next = current.parentConstitutor(
                isOwning: &isOwning
            )
            isParentOwning = isParentOwning && isOwning
        }
        return nil
    }
    
    var
    deferredParenthoodResolutions :[ParenthoodCallback] = []
    weak var
    resolvedParentAnalyzer :IdentityContextResolving? = nil
    var
    resolvedParentship :Bool? = nil
    var
    resolvedParenthood :FocusParenthood? {
        get {
            guard let
                parent = self.resolvedParentAnalyzer,
                let
                parentship = self.resolvedParentship
                else { return nil }
            return FocusParenthood(
                parent: parent,
                child: self,
                isOwning: parentship
            )
        }
        set {
            self.resolvedParentAnalyzer = newValue?.parent
            self.resolvedParentship = newValue?.isOwning
        }
    }
    typealias
        ParenthoodCallback = (FocusParenthood) throws -> Void
    func
        resolveParenthood(then callback : @escaping ParenthoodCallback) throws {
        let
        analyzer = self
        guard analyzer.isEnabled else {
            return analyzer.deferredParenthoodResolutions.append(callback)
        }
        
        if let
            parenthood = analyzer.resolvedParenthood
        { return try callback(parenthood) }
        
        guard let
            (parent, isParentOwning) = try self.parenthoodByLookingUp()
            else {
                return analyzer.deferredParenthoodResolutions.append(callback)
        }
        let
        parenthood = FocusParenthood(
            parent: parent,
            child: analyzer,
            isOwning: isParentOwning
        )
        analyzer.resolvedParenthood = parenthood
        try analyzer.flushDeferredResolutions()
        try callback(parenthood)
    }
    func
        flushDeferredResolutions() throws {
        guard let
            parenthood = self.resolvedParenthood
            else { throw ParentError.unresolvedParenthood }
        let
        resolutions = self.deferredParenthoodResolutions
        for resolve in resolutions {
            try resolve(parenthood)
        }
        self.deferredParenthoodResolutions.removeAll()
    }
    
    weak var
    latestFocusedObject :FocusHandling.Object? = nil
    func
        handleFocused(_ object :FocusHandling.Object) {
        self.latestFocusedObject = object
        try! self.resolveParenthood {
            let
            (parent, isOwning) = ($0.parent, $0.isOwning)
            guard
                isOwning,
                let
                analyzer = parent as? FocusHandling
                else { return }
            analyzer.handleFocused(object)
        }
    }

    public func
        markFocused() {
        guard let object = self.delegate as? FocusHandling.Object
            else { return }
        self.handleFocused(object)
    }

    // MARK: - Identity Context
    
    typealias
        ContextCallback = IdentityContextResolving.Callback
    func
        resolveContext(
        then callback : @escaping ContextCallback
        ) throws {
        let
        analyzer = self,
        namespace = self.resolvedNamespace
        if let
            context = analyzer.resolvedContext
        { return try callback(context) }
        
        try analyzer.resolveParenthood { [weak analyzer] parenthood in
            let
            (parent, child, isOwning) = (
                parenthood.parent,
                parenthood.child,
                parenthood.isOwning
            )
            let
            identifier = NodeID(owner: child)
            try parent.resolveContext { [weak analyzer, weak parent] pContext in
                let
                (manager, parentID, prefix) = (
                    pContext.manager,
                    pContext.identifier,
                    pContext.prefix
                )
                let
                prefixedID = isOwning ? prefix + identifier : identifier
                let
                context = IdentityContext(
                    manager: manager,
                    parentID: parentID,
                    identifier: prefixedID,
                    prefix: (isOwning ? prefix : NodeID.empty())
                )
                guard
                    let
                    analyzer = analyzer,
                    context != analyzer.resolvedContext
                    else { return try callback(context) }
                
                try manager.registerNode(
                    by: prefixedID,
                    under: parentID,
                    name: analyzer.key!,
                    index: analyzer.index,
                    namespace: namespace
                )
                analyzer.resolvedContext = context
                if
                    isOwning,
                    let
                    parent = parent
                {
                    parent.notifyAfterContextReset { [weak analyzer] in
                        analyzer?.resolvedContext = nil
                    }
                }

                try callback(context)
            }
        }
    }
}

extension
    Analyzer : Analyzing
{
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
        _ value :Any?,
        for keyPath :String
        ) {
        var
        properties = [
            "key-path": keyPath as Any
        ]
        if let
            value = value {
            properties["value"] = value
        }
        self.recordEventOnPath(
            named: "ana-updated",
            with: properties
        )
    }
    public func
        record(
        _ event: String
        ) {
        self.recordEventOnPath(
            named: event,
            with: nil
        )
    }
    public func
        detach() {
        self.tokens.removeAll()
    }
}

extension
    Analyzer : FocusPathConstituting, AnalyzerReadable
{
    public var
    analyzer: Analyzing { return self }
    public func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        isOwning.assign(
            repeating: true,
            count: 1
        )
        return self
    }
}

