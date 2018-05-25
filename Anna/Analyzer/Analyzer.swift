//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

class
SubAnalyzerWrapper {
    let
    name :String
    weak var
    analyzer :Analyzer?
    init(
        analyzer :Analyzer,
        name :String
        ) {
        self.name = name
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

    var
    isEnabled = false
    public override func
        enable(with name :String) {
        guard self.isEnabled == false
            else { return }
        self.resolvedName = name;
        if let delegate = self.delegate as? Hookable {
            self.hook(owner: delegate)
        }
        self.isEnabled = true
        try! self.flushDeferredNameResolutions()
        self.flushSubAnalyzerBuffer()
    }
    public override func
        addSubAnalyzer(
        _ sub :Analyzing,
        named name:String
        ) {
        guard let sub = sub as? Analyzer
            else { return }
        self.subAnalyzerBuffer.append(
            SubAnalyzerWrapper(
                analyzer: sub,
                name: name
            )
        )
        if self.isEnabled {
            self.flushSubAnalyzerBuffer()
        }
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
            sub.enable(with: wrapper.name)
        }
        self.subAnalyzerBuffer.removeAll()
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
            if let
                owner = current as? AnalyzerReadable
            {
                guard let
                    parent = owner.analyzer as? IdentityContextResolving
                    else { throw ContextError.unsetupAnalysisObject(description: String(describing: owner)) }
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
        try self.flushDeferredResolutions()
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

    public override func
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
        analyzer = self
        if let
            context = analyzer.resolvedContext
        { return try callback(context) }
        
        try analyzer.resolvedName { [weak analyzer] name in
            try analyzer?.resolveParenthood { [weak analyzer] parenthood in
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
                        context != analyzer?.resolvedContext
                        else { return try callback(context) }
                    
                    try manager.registerNode(
                        by: prefixedID,
                        named: name,
                        under: parentID
                    )
                    analyzer?.resolvedContext = context
                    parent?.notifyAfterContextReset { [weak analyzer] in
                        analyzer?.resolvedContext = nil
                    }
                    
                    try callback(context)
                }
            }
        }
    }
}
