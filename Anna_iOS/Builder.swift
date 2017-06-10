//
//  Builder.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

extension
ClassPointSetBuilder : StringAnySubscriptable {
    subscript(key :String) ->Any? {
        get { return self.buffer[key] }
        set { self.buffer[key] = newValue }
    }
}

extension
ClassPointSetBuilder : Builder {
    typealias Result = ClassPointSet
    func build() throws -> ClassPointSet { return try pointSet() }
    func _build() throws -> Any { return try build() }
}

extension
ClassPointSetBuilder : StringAnyDictionaryBufferringBuilder {}


protocol
StringAnySubscriptable {
    subscript(key :String) ->Any? { get }
}

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
