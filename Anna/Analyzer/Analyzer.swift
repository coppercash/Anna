//
//  Analyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

@objc(ANAAnalyzer)
public class
    Analyzer : BaseAnalyzer, AnalyzerParenting
{
    public typealias
        Delegate = PathConstituting
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
    deinit {
        try? self.deregisterLastLocator()
    }

    func
        resolvedParent() throws
        -> AnalyzerParenting
    {
        let
        analyzer = self
        let
        parent = try analyzer._resolvedParent()
        analyzer.manager = try parent.resolvedManager()
        return parent
    }
    
    func
        _resolvedParent() throws
        -> AnalyzerParenting
    {
        guard let
            delegate = self.delegate
            else { throw ParentError.noDelegate(name: self.resolvedName()) }
        var
        last = delegate,
        next = delegate.parentConsititutor(
            for: last,
            requiredFrom: delegate
        )
        while true {
            guard let consititutor = next
                else { throw ParentError.brokenChain(breaking: String(describing: type(of: last))) }
            if let
                owner = consititutor as? AnalyzerReadable,
                let
                parent = owner.analyzer as? AnalyzerParenting
            { return parent }
            next = consititutor.parentConsititutor(
                for: last,
                requiredFrom: delegate
            )
            last = consititutor
        }
    }
    
    var
    manager :Manager? = nil
    override func
        resolvedManager() throws -> Manager {
        let
        analyzer = self
        if let manager = analyzer.manager
        { return manager }
        let
        parent = try analyzer.resolvedParent()
        let
        manager = try parent.resolvedManager()
        analyzer.manager = manager
        // TODO: catch nil
        return manager
    }
    
    func
        resolvedName()
        -> String
    {
        return self.name
    }

    override func
        resolvedNodeLocatorByAppendingPath() throws -> Manager.NodeLocator {
        let
        analyzer = self

        // Register node for self if hasn't yet
        //
        if let locator = analyzer.lastRegisteredLocator {
            return locator
        }

        // Notify all ancestors to register themself
        //
        let
        parent = try analyzer.resolvedParent(),
        parentLocator = try parent.resolvedNodeLocatorByAppendingPath()

        // Register self
        //
        let
        manager = try analyzer.resolvedManager(),
        name = analyzer.resolvedName(),
        objID = ObjectIdentifier(analyzer),
        locator = parentLocator.forked(
            with: name,
            ownerID: objID
        )
        manager.registerNode(
            by: locator,
            under: parentLocator
        )
       
        // Mark registered
        //
        analyzer.lastRegisteredLocator = locator
        parent.notifyOnReseting(parentLocator) { [weak analyzer] in
            analyzer?.resetLastRegisteredLocator()
        }

        return locator
    }
    
    override func
        deregisterLastLocator() throws {
        if let locator = self.lastRegisteredLocator {
            let
            manager = try self.resolvedManager()
            manager.deregisterNode(by: locator)
        }
    }
}
