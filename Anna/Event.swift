//
//  EventBuilder.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

public class
EasyEvent {
    typealias
        Registrant = EasyRegistrant
    typealias
        Class = Registrant.Type
    let
    cls :Class
    
    typealias
        Method = String
    let
    method :String
    
    init(class cls :Class, method :Method) {
        self.cls = cls
        self.method = method
    }
    
    func
        object(to predicate :Predicate) ->Any? {
        guard let
            dictionary = payload as? Dictionary<String, Any>
            else { return nil }
        return dictionary[predicate.key]
    }
    var payload :Any? = nil
}

public class
EasyEventBuilder {
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
        event() throws ->Event {
        let
        dictionary = try buffer.build(),
        cls :Event.Class = try dictionary.required("class", for: self),
        method :Event.Method = try dictionary.required("method", for: self)
        
        let
        event = Event(class: cls, method: method)
        event.payload = dictionary
        return event
    }
    
    public typealias
        Buildup = (EasyEventBuilder)->Void
}

extension
EasyEventBuilder {
    subscript(key :String) ->Any? {
        get { return buffer[key] }
        set { buffer[key] = newValue }
    }
}
/*
extension
EasyEventBuilder : StringAnyDictionaryBufferringBuilder {
    typealias Result = Event
    func build() throws -> Event { return try event() }
    func _build() throws -> Any { return try build() }
}
 */
