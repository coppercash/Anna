//
//  Builder.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

protocol
BuilderPropertyBuffer {
    associatedtype
    PropertyKey
    associatedtype
    PropertyValue
    subscript
        (key :PropertyKey) ->PropertyValue? { get }
    func
        required<Property, Builder>(
        _ key :PropertyKey,
        for builder :Builder
        ) throws ->Property;
}

extension
    BuilderPropertyBuffer
{
    func
        required<Property, Builder>(
        _ key :PropertyKey,
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
    Dictionary : BuilderPropertyBuffer {
    typealias
        PropertyKey = Key
    typealias
        PropertyValue = Value
}

extension
    DictionaryBuilder : BuilderPropertyBuffer
{
    typealias
        PropertyKey = Key
    typealias
        PropertyValue = Value
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
    mutating func merge(with another: Array) {
        self += another
    }
    
    func merged(with another: Array) ->Array {
        return self + another
    }
}