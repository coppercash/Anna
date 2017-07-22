//
//  EventBuilder.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

public protocol
EasyEventBeing {
    subscript(key :AnyHashable) ->Any? { get }
}

public protocol
EasyEventSeedBuilding {
    typealias
        Buildup = (EasyEventSeedBuilding)->Void
    @discardableResult func
        set(_ key :AnyHashable, _ value :Any?) ->Self
}

protocol
EasyEventDispatching {
    typealias
        Seed = EasyPayloadCarrier & EasyPointMatchable & EasyRegisteringCarrying
    func
        dispatchEvent(with seed: Seed)
}

protocol
EasyPayloadCarrier : class {
    typealias
        Payload = Dictionary<AnyHashable, Any>
    var
    payload :Payload? { get }
}

protocol
EasyTrackerCarrier {
    typealias
        Tracker = EasyTracker
    var
    trackers :[Tracker]? { get }
    var
    overridesTrackers :Bool { get }
}

class
    EasyEventSeed :
    EasyPointMatchable,
    EasyPayloadCarrier,
    EasyRegisteringCarrying
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

class
EasyEvent : EasyEventBeing
{
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
                payload = points.updated(with: seeds)
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

class
EasyEventSeedBuilder : EasyEventSeedBuilding {
    var
    cls :Result.Registrant.Type? = nil
    var
    method :Result.Method? = nil
    typealias
        Buffer = DictionaryBuilder<AnyHashable, Any>
    let
    buffer = Buffer()
    
    required
    init() {}
    
    @discardableResult func
        set(_ key :AnyHashable, _ value :Any?) ->Self {
        buffer.set(key, value)
        return self
    }
    
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
    
}

extension
EasyEventSeedBuilder : Builder {
    public typealias
        Buildup = (EasyEventSeedBuilder)->Void
    typealias
        Result = EasyEventSeed
    func
        build() throws -> Result { return try event() }
    func
        _build() throws -> Any { return try build() }
}
