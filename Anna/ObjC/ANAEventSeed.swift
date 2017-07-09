//
//  ANAEventSeed.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

@objc public protocol
ANARegistrantCarrying : NSObjectProtocol {
    typealias
        Registrant = ANARegistering
    var
    registrant : Registrant.Type { get }
}

class
ANAEventSeed :
    NSObject,
    ANAPointMatchable,
    ANAPayloadCarrying,
    ANARegistrantCarrying
{
    let
    registrant: Registrant.Type
    var
    cls :AnyClass { return registrant }
    let
    selector :Selector
    typealias
        Payload = [String:Any]
    let
    payload :Payload?
    
    init(
        class cls :Registrant.Type,
        selector :Selector,
        payload :Payload?
        ) {
        self.registrant = cls
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
        Proto = ANAPayloadCarrying & ANAPointMatchable
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
