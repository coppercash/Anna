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
        Target = EasySender
    let
    target :Target
    init(target :Target) {
        self.target = target
    }
    
    typealias
        EventBuilder = EasyEventBuilder
    var
    event :EventBuilder? = nil
    public func
        event(_ buildup :EasyEventBuilder.Buildup) ->Self {
        let
        builder = EventBuilder()
        buildup(builder)
        event = builder
        return self
    }
    
    public typealias
        Method = StaticString
    public func
        analyze(method :Method = #function) {
        let
        event = self.event ?? EventBuilder()
        event["class"] = type(of: target)
        event["method"] = method
        manager.receive(try! event.event())
    }
    
    typealias
        Manager = EasyManager
    var
    manager :Manager {
        return target.analysisManager
    }
}
