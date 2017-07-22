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
        EventSeedBuilder = EasyEventSeedBuilding
    func
        event(_ buildup :EventSeedBuilder.Buildup) ->Self
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
        EventSeedBuilder = EasyEventSeedBuilder
    var
    event :EventSeedBuilder? = nil
    public func
        event(_ buildup :EasyPrefixing.EventSeedBuilder.Buildup) ->Self {
        let
        builder = EventSeedBuilder()
        buildup(builder)
        event = builder
        return self
    }
    
    public func
        analyze(method :EasyPrefixing.Method = #function) {
        let
        event = self.event ?? EventSeedBuilder()
        event.cls = type(of: target)
        event.method = method
        target.analyticsManager.dispatchEvent(with: try! event.event())
    }
}
