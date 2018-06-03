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
        self.namespace = String(describing: type(of: delegate))
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

