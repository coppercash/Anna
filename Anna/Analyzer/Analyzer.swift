//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

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
    deinit {
        try? self.deactivate()
        //
        // The observation to parent.nodeID is removed.
    }
    
    // MARK: - Node Identity
    
//    var
//    manager :Manager? = nil
    override func
        resolveIdentity(
        then callback: @escaping IdentityResolving.Callback
        ) throws {
        
        // Cache hit
        //
        self.deferResolution(callback)
        if let
            identity = self.identity
        { return try self.flushResolutions(with: identity) }
        
        guard
            let
            makeContext = self.makeContext,
            let
            parent = self.parent ?? self.parentByLookingUp()
            else { return }
        try parent.resolveIdentity {
            [weak self] (identity) in
            guard let
                analyzer = self
                else { return }
            let
            context = makeContext(identity)
            try analyzer.bindNode(
                with: context
            )
            try analyzer.flushResolutions(with: analyzer.identity!)
        }
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
        with identity :Identity
        ) throws {
        for
            callback in self.deferred
        {
            try callback(identity)
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
    func
        enable(
        under parent :BaseAnalyzer?,
        key :String,
        index :Int?
        ) throws {
        guard self.isEnabled == false
            else { return }
        self.isEnabled = true
        
        if parent == nil {
            self.parentlessName = key
        }
        
        if let
            parent = parent
        {
            try self.activate(
                under: parent,
                key: key,
                index: index
            )
        }
        else {
            try self.activate(
                with: key
            )
        }

        if let
            delegate = self.delegate as? Hookable
        {
            self.hook(owner: delegate)
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
            [weak self, weak sub] (_) in
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
    
    typealias
    Parent = IdentityResolving
    weak var
    parent :Parent? = nil {
        willSet {
            self.parent?.removeIdentityObserver(self)
        }
        didSet {
            self.parent?.addIdentityObserver(self) {
                (parent, analyzer) in
                if parent.identity == nil {
                    analyzer.identity = nil
                }
            }
        }
    }
    typealias
    ContextMaker = (Identity) -> IdentityContext
    var
    makeContext :ContextMaker? = nil
    func
        activate(
        under parent :Parent?,
        contextMaker : @escaping ContextMaker
        ) throws {
        self.parent = parent
        self.makeContext = contextMaker
        try self.resolveIdentity { (_) in }
    }
    func
        activate(
        with name :String
        ) throws {
        let
        nodeID = NodeID.owned(by: self)
        try self.activate(under: nil) {
            let
            manager = $0.manager,
            parentID = $0.nodeID
            return IdentityContext(
                manager: manager,
                nodeID: nodeID,
                parentID: parentID,
                name: name,
                index: nil
            )
        }
    }
    func
        activate(
        under parent :Parent,
        key :String,
        index :Int?
        ) throws {
        let
        atonomicID = NodeID.owned(by: self)
        try self.activate(under: parent) {
            let
            manager = $0.manager,
            parentID = $0.nodeID,
            nodeID = parentID.containsKeyPath ?
                parentID.appended(key: key, index: index) :
            atonomicID
            return IdentityContext(
                manager: manager,
                nodeID: nodeID,
                parentID: parentID,
                name: key,
                index: index
            )
        }
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

    // MARK: - Subordinary
    
    typealias
        SubKey = AnyHashable
    typealias
        SubObject = AnyObject
    var
    subordinaires :[SubKey : SubObject] = [:]
    func
        removeSubordinary(
        for key :SubKey
        ) {
        self.subordinaires[key] = nil
    }
    func
        setSubordinary(
        _ sub :SubObject,
        for key :SubKey
        ) {
        self.subordinaires[key] = sub
    }
    func
        subordinary(
        for key :SubKey
        ) ->SubObject? {
        return self.subordinaires[key]
    }
}

extension
    Analyzer : Analyzing
{
    public func
        enable(
        with name :String
        ) {
        self.parentlessName = name
        do {
            try self.enable(
                under: nil,
                key: name,
                index: nil
            )
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    public func
        setSubAnalyzer(
        _ sub :Analyzing,
        for key:String
        ) {
        do {
            try self.setSubAnalyzer(
                sub,
                for: key,
                index: nil
            )
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    public func
        setSubAnalyzers(
        _ subs: [Analyzing],
        for key: String
        ) {
        do {
            for (i, sub) in subs.enumerated() {
                try self.setSubAnalyzer(
                    sub,
                    for: key,
                    index: i
                )
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
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
        self.recordEvent(
            named: "ana-updated",
            with: properties
        )
    }
    public func
        record(
        _ event: String
        ) {
        self.recordEvent(
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

