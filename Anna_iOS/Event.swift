//
//  EventBuilder.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

public class
Event {
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
EventBuilder {
    let
    buffer = DictionaryBuilder<String, Any>()
    
    required public
    init() {}
    
    @discardableResult public func
        set(_ key :String, _ value :Any) ->Self {
        buffer.set(key, value)
        return self
    }
    
    func
        event() throws ->Event {
        let
        dictionary = try buffer.build(),
        cls :Event.Class = try requiredProperty(
            from: dictionary,
            for: "class"),
        method :Event.Method = try requiredProperty(
            from: dictionary,
            for: "method"
        )
        
        let
        event = Event(class: cls, method: method)
        event.payload = dictionary
        return event
    }
}
public typealias
EventBuilding = (EventBuilder)->Void

extension
EventBuilder {
    subscript(key :String) ->Any? {
        get { return buffer[key] }
        set { buffer[key] = newValue }
    }
}

extension
EventBuilder : StringAnyDictionaryBufferringBuilder {
    typealias Result = Event
    func build() throws -> Event { return try event() }
    func _build() throws -> Any { return try build() }
}
