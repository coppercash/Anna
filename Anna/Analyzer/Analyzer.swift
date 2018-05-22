//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, IdentityContextResolving, FocusHandling
{
    public typealias
        Delegate = FocusPathConstituting
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
        self.resolvedNamespace = String(describing: type(of: delegate))
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
        analyzer = self,
        name = self.name
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
