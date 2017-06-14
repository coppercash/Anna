//
//  Buildup.swift
//  Anna
//
//  Created by William on 31/05/2017.
//
//

import Foundation

enum BuilderError : Error {
    case missedProperty(name :String, result :String)
}
// TODO: missingProperty with more detail

// Why Builder is needed?
//   + We need to cast to some type responds to build

protocol _Builder {
    func _build() throws ->Any
}

protocol Builder : _Builder {
    associatedtype
    Result
    typealias
        Buildup = (Self)->Void
    init()
    func
        build() throws ->Result
}

public class ArrayBuilder<Element>
{
    var buffer = Array<Any>()
    
    required
    public init() {}
    
    @discardableResult
    func add(_ element :Element) ->Self {
        buffer.append(element)
        return self
    }

    @discardableResult
    func add<ElementBuilder>(_ buildup :ElementBuilder.Buildup) ->Self
        where ElementBuilder : Builder, ElementBuilder.Result == Element
    {
        let builder = ElementBuilder()
        buildup(builder)
        buffer.append(builder)
        return self
    }
    
    func array() throws ->Array<Element> {
        var array = [Element]()
        array.reserveCapacity(buffer.count)
        for item in buffer {
            if let builder = item as? _Builder {
                let element = try builder._build() as! Element
                array.append(element)
            }
            else if let element = item as? Element {
                array.append(element)
            }
        }
        return array
    }
    
    func elements<Type>() ->AnyIterator<Type> {
        var index = 0
        return AnyIterator {
            while
                index < self.buffer.count,
                self.buffer[index] is Type == false
            {
                index += 1
            }
            
            guard index < self.buffer.count else { return nil }
            let element :Type = self.buffer[index] as! Type
            
            index += 1
            return element
        }
    }
    
    var count :Int {
        return buffer.count
    }
}

extension ArrayBuilder : Builder {
    typealias
        Result = [Element]
    
    func build() throws ->Result {
        return try array()
    }
    
    func _build() throws -> Any {
        return try build()
    }
}

public class DictionaryBuilder<Key, Value>
    where Key : Hashable
{
    required
    public init() {}

    var buffer = Dictionary<Key, Any>()
    
    @discardableResult
    func set(_ key :Key, _ value :Value) ->Self {
        buffer[key] = value
        return self
    }
    
    func get<Ensured>(_ key :Key, _ orCreate : @autoclosure ()->Ensured) ->Ensured
    {
        if let value = buffer[key] as? Ensured { return value }
        let value = orCreate()
        buffer[key] = value as? Value
        return value
    }
    
    func dictionary() throws ->Dictionary<Key, Value> {
        var
        dictionary = [Key:Value]()
        for (key, value) in buffer {
            if let
                builder = value as? _Builder {
                let
                value = try builder._build() as! Value
                dictionary[key] = value
            }
            else if let
                value = value as? Value {
                dictionary[key] = value
            }
        }
        return dictionary
    }
}

extension DictionaryBuilder {
    subscript(key :Key) ->Any? {
        get { return buffer[key] }
        set { self.buffer[key] = newValue }
    }
}

extension DictionaryBuilder : Builder {
    typealias Result = Dictionary<Key, Value>
    
    func build() throws -> Dictionary<Key, Value> {
        return try dictionary()
    }
    
    func _build() throws -> Any {
        return try build()
    }
}
