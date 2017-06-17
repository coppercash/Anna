//
//  Prefix.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public class
EasyPrefix {
    typealias
        Target = EasyAnalyzable
    let
    target :Target
    init(target :Target) {
        self.target = target
    }
    
    public typealias
        EventBuilder = EasyEventBuilder
    var
    event :EventBuilder? = nil
    public func
        event(_ buildup :EventBuilder.Buildup) ->Self {
        let
        builder = EventBuilder()
        buildup(builder)
        event = builder
        return self
    }
    
    public typealias
        Method = String
    public func
        analyze(method :Method = #function) {
        let
        event = self.event ?? EventBuilder()
        event.cls = type(of: target)
        event.method = method
        manager.receive(try! event.event())
    }
    
    typealias
        Manager = EasyManager
    var
    manager :Manager {
        return target.analysisManager
    }
}
