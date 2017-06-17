//
//  EventBuilder.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

public class
EasyEventSeed {
    typealias
        Class = EasyAnalyzable.Type
    let
    cls :Class
    
    typealias
        Method = String
    let
    method :String
    
    init(
        class cls :Class,
        method :Method,
        payload :Payload? = nil
        ) {
        self.cls = cls
        self.method = method
        self.payload = payload
    }
    
    public typealias
        Payload = Dictionary<String, Any>
    public let
    payload :Payload?
    
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
        Payload = Dictionary<String, Any>
    let
    payload :Payload
    init(payload :Payload) {
        self.payload = payload
    }
    
    public
    subscript(key :String) ->Any? {
        return payload[key]
    }
    
    convenience
    init(seed :EasyEventSeed, point :EasyPayloadNode) throws {
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
EasyEventBuilder {
    var
    cls :Result.Class? = nil
    var
    method :Result.Method? = nil
    let
    buffer = DictionaryBuilder<String, Any>()
    
    required public
    init() {}
    
    @discardableResult public func
        set(_ key :String, _ value :Any) ->Self {
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
        event = Result(
            class: cls,
            method: method,
            payload: dictionary
        )
        return event
    }
    
    public typealias
        Buildup = (EasyEventBuilder)->Void
}

extension
EasyEventBuilder : Builder {
    public typealias
        Result = EasyEventSeed
    public func
        build() throws -> Result { return try event() }
    public func
        _build() throws -> Any { return try build() }
}
//extension
//EasyEventBuilder {
//    subscript(key :String) ->Any? {
//        get { return buffer[key] }
//        set { buffer[key] = newValue }
//    }
//}
