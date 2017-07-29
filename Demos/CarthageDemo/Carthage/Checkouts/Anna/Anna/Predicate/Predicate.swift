//
//  Predicate.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

public protocol Predicate {
    typealias
        Key = String
    var
    key :Key { get }
    
    func
        evaluate(with object :Any?) ->Bool
}

class EqualPredicate<Value> : Predicate where Value : Equatable {
    typealias
    Key = Predicate.Key
    let
    key :Key,
    expectedValue :Value
    init(key :Key, expectedValue :Value) {
        self.key = key
        self.expectedValue = expectedValue
    }
    
    public func
        evaluate(with object: Any?) -> Bool {
        guard let
            nonNil = object,
            let
            cast = nonNil as? Value
            else { return false }
        return cast == expectedValue
    }
}
