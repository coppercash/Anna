//
//  Prefix.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public protocol
EasyPrefixing {
    typealias
        Method = String
    func
    analyze(method :Method)
    typealias
        SeedBuilder = Anna.EventSeedBuilding
    func
        event(_ buildup :SeedBuilder.Buildup) ->Self
}

public class
EasyPrefix : EasyPrefixing {
    typealias
        Target = EasyAnalyzable
    unowned let
    target :Target
    init(target :Target) {
        self.target = target
    }
    
    typealias
        SeedBuilder = EasyEventSeedBuilder
    var
    event :SeedBuilder? = nil
    public func
        event(_ buildup :EasyPrefixing.SeedBuilder.Buildup) ->Self {
        let
        builder = SeedBuilder()
        buildup(builder)
        event = builder
        return self
    }
    
    public func
        analyze(method :EasyPrefixing.Method = #function) {
        let
        event = self.event ?? SeedBuilder()
        event.cls = type(of: target)
        event.method = method
        target.analyticsManager.dispatchEvent(with: try! event.event())
    }
}
