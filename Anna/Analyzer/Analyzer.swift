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
    Analyzer : BaseAnalyzer, FocusHandling
{
    public typealias
        Delegate = FocusPathConstituting
    weak var
    delegate :Delegate?
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
    
    // MARK: - Node Identity
    
    var
    manager :Manager? = nil
    override func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) throws {
        
        // Cache hit
        //
        self.deferResolution(callback)
        if let
            manager = self.manager,
            let
            nodeID = self.nodeID
        {
            try self.flushResolutions(
                with: manager,
                nodeID
            )
            return
        }
        
        guard
            let
            makeContext = self.makeContext,
            let
            parent = self.parent ?? self.parentByLookingUp()
            else { return }
        try parent.resolveIdentity {
            [weak self] (manager, parentID) in
            guard let
                analyzer = self
                else { return }
            let
            context = makeContext(manager, parentID)
            try analyzer.bindNode(
                with: context
            )
            try analyzer.flushResolutions(
                with: context.manager,
                context.identifier
            )
        }
        /*
        let
        makeContext = {
           (manager, parentID) in
        }
        
        if let
            parent = self.parent,
            let
            name = self.key
        {
            let
            index = self.index
            try parent.resolveIdentity {
                [weak self] (manager, parentID) in
                guard let
                    analyzer = self
                    else { return }
                let
                nodeID = parentID.keyPath.length == 0 ?
                    NodeID(owner: analyzer) :
                    parentID.appended(with: name, index),
                context = IdentityContext(
                    manager: manager,
                    parentID: parentID,
                    identifier: nodeID,
                    name: name,
                    index: index
                )
                try analyzer.bindNode(
                    with: context
                )
                try analyzer.flushResolutions(
                    with: manager,
                    nodeID
                )
            }
        }
        else if let
            parent = self.parentByLookingUp(),
            let
            name = self.conextlessName
        {
            try parent.resolveIdentity {
                [weak self] (manager, parentID) in
                guard let
                    analyzer = self
                    else { return }
                let
                nodeID = NodeID(owner: analyzer),
                context = IdentityContext(
                    manager: manager,
                    parentID: parentID,
                    identifier: nodeID,
                    name: name,
                    index: nil
                )
                try analyzer.bindNode(
                    with: context
                )
                try analyzer.flushResolutions(
                    with: manager,
                    nodeID
                )
            }
        }
 */
    }
    override func
        bindNode(
        with context :IdentityContext
        ) throws {
        let
        manager = context.manager,
        nodeID = context.identifier
        if self.manager == nil {
            self.manager = manager
        }
        if self.nodeID == nil {
            self.nodeID = nodeID
            try manager.registerNode(
                by: nodeID,
                under: context.parentID,
                name: context.name,
                index: context.index
            )
        }
    }
    override func
        unbindNode() throws {
        guard let
            nodeID = self.nodeID
            else { return }
        if let
            manager = self.manager,
            nodeID.isOwned(by: self)
        {
            try manager.deregisterNodes(by: nodeID)
        }
        self.nodeID = nil
    }
    
    var
    deferred :[IdentityResolving.Callback] = []
    func
        deferResolution(
        _ callback : @escaping IdentityResolving.Callback
        ) {
        self.deferred.append(callback)
    }
    func
        flushResolutions(
        with manager :Manager,
        _ nodeID :NodeID
        ) throws {
        for
            callback in self.deferred
        {
            try callback(manager, nodeID)
        }
        self.deferred.removeAll()
    }
    
    // MARK: - Even Handling
    
    var
    tokens :[Reporting] = []
    
    // MARK: - Enable

    var
    isEnabled = false,
    parentlessName :String? = nil
    public func
        enable(
        with name :String
        ) {
        self.parentlessName = name
        try! self.enable(
            under: nil,
            key: name,
            index: nil
        )
    }
    func
        enable(
        under parent :BaseAnalyzer?,
        key :String,
        index :Int?
        ) throws {
        guard self.isEnabled == false
            else { return }
        self.isEnabled = true
        try self.activate(
            under: parent,
            key: key,
            index: index,
            nodeIDKeyPath: nil
        )
        if let
            delegate = self.delegate as? Hookable
        {
            self.hook(owner: delegate)
        }
    }
    public func
        setSubAnalyzer(
        _ sub :Analyzing,
        for key:String
        ) {
        try! self.setSubAnalyzer(
            sub,
            for: key,
            index: nil
        )
    }
    public func
        setSubAnalyzers(
        _ subs: [Analyzing],
        for key: String
        ) {
        for (i, sub) in subs.enumerated() {
            try! self.setSubAnalyzer(
                sub,
                for: key,
                index: i
            )
        }
    }
    func
        setSubAnalyzer(
        _ sub :Analyzing,
        for key :String,
        index :Int?
        ) throws {
        guard let
            sub = sub as? Analyzer
            else { return }
        if self.isEnabled {
            try sub.enable(
                under: self,
                key: key,
                index: index
            )
            return
        }
        try self.resolveIdentity {
            [weak self, weak sub] (manager, nodeID) in
            guard let
                analyzer = self,
                let
                sub = sub
                else { return }
            try sub.enable(
                under: analyzer,
                key: key,
                index: index
            )
        }
    }

    // MARK: - Activate
    
    weak var
    parent :BaseAnalyzer? = nil {
        willSet {
            self.parent?.removeNodeIDObserver(self)
        }
        didSet {
            self.parent?.addNodeIDObserver(self) {
                (parent, analyzer) in
                analyzer.nodeID = nil
            }
        }
    }
    typealias
    ContextMaker = (Manager, NodeID) -> IdentityContext
    var
    makeContext :ContextMaker? = nil
    func
        activate(
        under parent :BaseAnalyzer?,
        key :String,
        index :Int?,
        nodeIDKeyPath :[String]?
        ) throws {
        self.parent = parent
        let
        isParentless = parent == nil,
        parentlessID = NodeID.owned(by: self)
        self.makeContext = {
            (manager, parentID) in
            let
            nodeID :NodeID
            if
                isParentless
            {
                nodeID = parentlessID
            }
            else {
                if let
                    keyPath = nodeIDKeyPath
                {
                    nodeID = parentID.appended(keyPath)
                }
                else if
                    parentID.containsKeyPath
                {
                    nodeID = parentID.appended(key: key, index: index)
                }
                else {
                    nodeID = parentlessID
                }
            }
            return IdentityContext(
                manager: manager,
                parentID: parentID,
                identifier: nodeID,
                name: key,
                index: index
            )
        }
        try self.resolveIdentity { (_, _) in }
    }
    func
        deactivate() throws {
        self.parent = nil
        self.makeContext = nil
        try self.unbindNode()
        //
        // Every event happen after, will go into deferred buffer
    }

    // MARK: - Focus Path
   /*
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
        resolvedParent() -> BaseAnalyzer? {
        if let
            parent = self.parent
        { return parent }
        guard self.isEnabled
            else { return nil }
        let
        parent = self.parenthoodByLookingUp()?.0
        self.parent = parent
        return parent
    }
 */
    func
        parentByLookingUp() -> BaseAnalyzer? {
        return self.parenthoodByLookingUp()?.0
    }
    func
        parenthoodByLookingUp() -> (BaseAnalyzer, Bool)? {
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
                owner = current as? AnalyzerReadable,
                let
                parent = owner.analyzer as? BaseAnalyzer
            {
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
/*
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
            (parent, isParentOwning) = self.parenthoodByLookingUp()
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

    // MARK: - Identity Context
    
    var
    context :IdentityContext? = nil
    func
        resolveContext(
        then callback : @escaping IdentityContextResolving.Callback
        ) throws {
        try self.deferContextResolution(callback)
     
        guard let
            parent = self.resolvedParent()
            else { return }
        try parent.resolveIdentity {
            [weak self] (manager, parentID) in
            guard let
                analyzer = self,
                analyzer.context == nil,
                name = analzyer.contextlessName
                else { return }
            let
            context = IdentityContext(
                manager: manager,
                parentID: parentID,
                identifier: NodeID(owner: analyzer),
                name: name,
                index: nil
            )
            analyzer.flushDeferredResolutions(with: context)
        }
    }
    
    var
    deferredContextResolutions :[IdentityContextResolving.Callback] = []
    func
        deferContextResolution(
        _ callback : @escaping IdentityContextResolving.Callback
        ) throws {
        // Context may come from
        // 1. that parent set in
        // 2. looking up through responder chain, and cached
        //
        if let
            context = self.context
        {
            return try callback(context)
        }
        self.deferredContextResolutions.append(callback)
    }
    func
        flushDeferredResolutions(with context :IdentityContext) throws {
        self.context = context
        for
            callback in self.deferredContextResolutions
        {
            try callback(context)
        }
        self.deferredParenthoodResolutions.removeAll()
    }
    
/*
    func
        resolveContext(
        then callback : @escaping IdentityContextResolving.Callback
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
 */
     */
    
    // MARK: - Focus
    
    weak var
    latestFocusedObject :FocusHandling.Object? = nil
    func
        handleFocused(_ object :FocusHandling.Object) {
        self.latestFocusedObject = object
        guard let
            handler = self.parent as? FocusHandling
            else { return }
        handler.handleFocused(object)
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
    public func
        markFocused() {
        guard let object = self.delegate as? FocusHandling.Object
            else { return }
        self.handleFocused(object)
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

