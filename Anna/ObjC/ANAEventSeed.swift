//
//  ANAEventSeed.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

class
ANAEventSeed :
    NSObject,
    ANAPointMatchableProtocol,
    ANAPayloadCarryingProtocol
{
    let
    cls :AnyClass
    let
    selector :Selector
    typealias
        Payload = [String:Any]
    let
    payload :Payload?
    
    init(
        class cls :AnyClass,
        selector :Selector,
        payload :Payload?
        ) {
        self.cls = cls
        self.selector = selector
        self.payload = payload
    }
}

class
    ObjCEventSeed :
    EasyPointMatchable,
    EasyPayloadCarrier
{
    typealias
        Proto = ANAPayloadCarryingProtocol & ANAPointMatchableProtocol
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }
    
    var
    payload: EasyPayloadCarrier.Payload? {
        return self.proto.payload
    }

    var
    method: EasyPointMatchable.Method {
        return self.proto.selector.methodName
    }

    var
    cls: EasyPointMatchable.Class {
        return self.proto.cls
    }

    func
        object(to predicate: Predicate) -> Any? {
        guard let
            objects = payload
            else { return nil }
        return objects[predicate.key]
    }
}
