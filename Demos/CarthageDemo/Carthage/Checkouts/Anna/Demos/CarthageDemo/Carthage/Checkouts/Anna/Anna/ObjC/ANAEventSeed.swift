//
//  ANAEventSeed.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

@objc protocol
ANARegistrantCarrying {
    typealias
        Registrant = ANARegistering
    var
    registrant : Registrant.Type { get }
}

@objc protocol
ANAEventDispatching {
    typealias
        Seed = ANAPointMatchable & ANAPayloadCarrying & ANARegistrantCarrying
    func
        dispatchEvent(with seed :Seed)
}

@objc protocol
ANAPointMatchable {
    var
    cls :AnyClass { get }
    var
    selector :Selector { get }
}

@objc protocol
ANAPayloadCarrying {
    var
    payload :Dictionary<AnyHashable, Any>? { get }
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
        Payload = [AnyHashable : Any]
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

class
    ANAEventSeedBuilder :
    NSObject,
    ANAEventSeedBuilding
{
    typealias
        Result = ANAEventSeed
    var
    cls :Result.Registrant.Type? = nil
    var
    selector :Selector? = nil
    let
    buffer = DictionaryBuilder<AnyHashable, Any>()
    typealias
        Parent = ANAPrefixing & BuilderParenting
    let
    parent :Parent
    init(parent :Parent) {
        self.parent = parent
    }
    
    var
    set: (NSCopying & NSObjectProtocol, Any?) -> ANAEventSeedBuilding {
        return { [unowned self] (key, value) in
            self.buffer.set(key as! NSObject, value)
            return self
        }
    }
    
    var
    `_` :ANAPrefixing {
        parent.close(child: self)
        return parent
    }
    
    func
        eventSeed() throws ->ANAEventSeed {
        guard let cls = self.cls else {
            throw BuilderError.missedProperty(
                name: "class",
                result: String(describing: type(of: self))
            )
        }
        guard let selector = self.selector else {
            throw BuilderError.missedProperty(
                name: "selector",
                result: String(describing: type(of: self))
            )
        }
        let
        dictionary = try buffer.build()
        let
        seed = ANAEventSeed(
            class: cls,
            selector: selector,
            payload: dictionary
        )
        return seed
    }
}

protocol
BuilderParenting {
    func
        close(child :Any)
}
