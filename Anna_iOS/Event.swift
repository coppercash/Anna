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
    typealias Class = Registrant.Type
    let cls :Class
    
    typealias Method = String
    let method :String
    
    init(class cls :Class, method :Method) {
        self.cls = cls
        self.method = method
    }
    let payload :Any? = nil
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
        dictionary = try buffer.build()
        guard let
            cls = dictionary["class"] as? Registrant.Type
            else { throw BuilderError.missedProperty( name: "class", result: String(describing: Result.self)) }
        guard let
            method = dictionary["method"] as? String
            else { throw BuilderError.missedProperty( name: "method", result: String(describing: Result.self)) }
        
        return Event(class: cls, method: method)
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
EventBuilder : Builder {
    typealias Result = Event
    func build() throws -> Event { return try event() }
    func _build() throws -> Any { return try build() }
}
