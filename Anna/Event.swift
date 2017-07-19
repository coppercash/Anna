//
//  EventBuilder.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

protocol
EasyEventDispatching {
    typealias
        Seed = EasyPayloadCarrier & EasyPointMatchable & EasyRegistrantCarrying
    func
        dispatchEvent(with seed: Seed)
}

public class
    EasyEventSeed :
    EasyPointMatchable,
    EasyPayloadCarrier,
    EasyRegistrantCarrying
{
    var
    cls :EasyPointMatchable.Class { return registrant }
    let
    method :EasyEventSeed.Method
    public let
    payload :EasyPayloadCarrier.Payload?
    let
    registrant: Registrant.Type
    
    init(
        class cls :Registrant.Type,
        method :EasyEventSeed.Method,
        payload :EasyPayloadCarrier.Payload? = nil
        ) {
        self.registrant = cls
        self.method = method
        self.payload = payload
    }
    
    func
        object(to predicate :Predicate) ->Any? {
        guard let
            objects = payload
            else { return nil }
        return objects[predicate.key]
    }
}

enum
EventError : Error {
   case unloadedEvent
}

public class
EasyEvent {
    typealias
        Payload = EasyPayloadCarrier.Payload
    let
    payload :Payload
    init(payload :Payload) {
        self.payload = payload
    }
    
    public
    subscript(key :AnyHashable) ->Any? {
        return payload[key]
    }
    
    convenience
    init(seed :EasyPayloadCarrier, point :EasyPayloadNode) throws {
        guard seed.payload != nil ||
            point.payload != nil
            else { throw EventError.unloadedEvent }
        let payload :Payload
        if let points = point.payload {
            if let seeds = seed.payload {
                payload = points.merged(with: seeds)
            }
            else {
                payload = points
            }
        }
        else {
            payload = seed.payload!
        }
        self.init(payload: payload)
    }
}

public class
EasyEventSeedBuilder {
    var
    cls :Result.Registrant.Type? = nil
    var
    method :Result.Method? = nil
    typealias
        Buffer = DictionaryBuilder<AnyHashable, Any>
    let
    buffer = Buffer()
    
    required public
    init() {}
    
    @discardableResult public func
        set(_ key :AnyHashable, _ value :Any?) ->Self {
        buffer.set(key, value)
        return self
    }
    
    typealias
        Event = EasyEvent
    func
        event() throws ->EasyEventSeed {
        guard let
            cls = self.cls
            else {
                throw BuilderError.missedProperty(
                    name: "class",
                    result: String(describing: type(of: self))
                )
        }
        guard let
            method = self.method
            else {
                throw BuilderError.missedProperty(
                    name: "method",
                    result: String(describing: type(of: self))
                )
        }
        let
        dictionary = try buffer.build()
        let
        event = EasyEventSeed(
            class: cls,
            method: method,
            payload: dictionary
        )
        return event
    }
    
    public typealias
        Buildup = (EasyEventSeedBuilder)->Void
}

extension
EasyEventSeedBuilder : Builder {
    public typealias
        Result = EasyEventSeed
    public func
        build() throws -> Result { return try event() }
    public func
        _build() throws -> Any { return try build() }
}
