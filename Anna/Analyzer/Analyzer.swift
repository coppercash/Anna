//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, IdentityContextResolving
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
    }

    // MARK: - Focus Path
    
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
                    else { throw ContextError.unsetupAnalysisObject }
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
            else { return analyzer.deferredParenthoodResolutions.append(callback) }
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
            try parent.resolveContext { [weak analyzer, weak parent] pContext in
                let
                (manager, parentID, suffix) = (
                    pContext.manager,
                    pContext.identifier,
                    pContext.suffix
                )
                let
                identifier = isOwning ?
                    NodeID(owner: child) + suffix :
                    NodeID(owner: child)
                manager.registerNode(
                    by: identifier,
                    named: name,
                    under: parentID
                )
                
                let
                context = IdentityContext(
                    manager: manager,
                    parentID: parentID,
                    identifier: identifier,
                    suffix: (isOwning ? suffix : NodeID.empty())
                )
                analyzer?.resolvedContext = context
                parent?.notifyOnResetingContext { [weak analyzer] in
                    analyzer?.resolvedContext = nil
                }
                
                try callback(context)
            }
        }
    }
}
