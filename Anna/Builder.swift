//
//  Builder.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

protocol
StringAnySubscriptable {
    associatedtype
        Key : Hashable
    associatedtype
    Value
subscript(key :Key) ->Value? { get }
}
/*
protocol
StringAnyDictionaryBufferringBuilder : Builder {
    func
        property<Value>(
        from dictionary :Dictionary<String, Any>,
        for key :String,
        default :Value
        ) ->Value
    func
        property<Value>(
        from dictionary :StringAnySubscriptable,
        for key :String,
        default :Value
        ) ->Value
    func
        requiredProperty<Value>(
        from dictionary :StringAnySubscriptable,
        for key :String,
        default :Value?,
        propertyPrefix :String?
        ) throws ->Value
    func
        requiredProperty<Value>(
        from dictionary :Dictionary<String, Any>,
        for key :String,
        default :Value?,
        propertyPrefix :String?
        ) throws ->Value
}

extension
StringAnyDictionaryBufferringBuilder {
    func
        property<Value>(
        from dictionary :StringAnySubscriptable,
        for key :String,
        default dft:Value
        ) ->Value {
       return (dictionary[key] as? Value) ?? dft
    }
    func
        property<Value>(
        from dictionary :Dictionary<String, Any>,
        for key :String,
        default dft:Value
        ) ->Value {
       return (dictionary[key] as? Value) ?? dft
    }
    func
        requiredProperty<Value>(
        from dictionary :StringAnySubscriptable,
        for key :String,
        default dft:Value? = nil,
        propertyPrefix :String? = nil
        ) throws ->Value {
        guard let
            property = (dictionary[key] as? Value) ?? dft
            else {
                throw BuilderError.missedProperty(
                    name: propertyPrefix == nil ? key : "\(propertyPrefix).\(key)",
                    result: String(describing: Result.self)
                )
        }
        return property
    }
    func
        requiredProperty<Value>(
        from dictionary :Dictionary<String, Any>,
        for key :String,
        default dft:Value? = nil,
        propertyPrefix :String? = nil
        ) throws ->Value {
        guard let
            property = (dictionary[key] as? Value) ?? dft
            else {
                throw BuilderError.missedProperty(
                    name: propertyPrefix == nil ? key : "\(propertyPrefix).\(key)",
                    result: String(describing: Result.self)
                )
        }
        return property
    }
}
*/

extension
    Dictionary : StringAnySubscriptable
{
    func
        required<Property, Builder>(
        _ key :Key,
        for builder :Builder
        ) throws ->Property {
        guard let value = self[key] as? Property else {
            throw BuilderError.missedProperty(
                name: "\(key)",
                result: String(describing: type(of: builder)
            ))
        }
        return value
    }
}

extension
    StringAnySubscriptable
{
    func
        required<Property, Builder>(
        _ key :Key,
        for builder :Builder
        ) throws ->Property {
        guard let value = self[key] as? Property else {
            throw BuilderError.missedProperty(
                name: "\(key)",
                result: String(describing: type(of: builder)
            ))
        }
        return value
    }
}

extension
DictionaryBuilder 
{
    func removeProperty<Property>(forKey key :Key) ->Property? {
        return buffer.removeValue(forKey: key) as? Property 
    }
}

extension Dictionary {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with another: Dictionary) ->Dictionary {
        var merged = self
        merged.merge(with: another)
        return merged
    }
}

extension Array {
    func merged(with another: Array) ->Array {
        return self + another
    }
}
