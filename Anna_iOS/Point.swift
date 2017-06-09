//
//  Point.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

public class
Point {
    let
    trackers :[Tracker],
    predicates :[Predicate]?
    public let
    payload :Any?
    
    public
    init(trackers :[Tracker], predicates :[Predicate]?, payload :Any?) {
        self.trackers = trackers
        self.predicates = predicates
        self.payload = payload
    }
    
    func matches(_ event :Event) ->Bool {
        guard let
            predicates = self.predicates
            else { return true }
        for predicate in predicates {
            let
            object = event.object(to: predicate)
            guard
                predicate.evaluate(with: object)
                else { return false }
        }
        return true
    }
}

public class
PointBuilder {
    
    let
    buffer = DictionaryBuilder<String, Any>()
    
    required public
    init() {}
    
    @discardableResult public func
        method(_ name :String) ->Self {
        buffer.set(#function, name)
        return self
    }
    
    @discardableResult public func
        set(_ key :String, _ value :Any) ->Self {
        buffer.set(key, value)
        return self
    }
    
    typealias
    Predicates = ArrayBuilder<Predicate>
    @discardableResult public func
        when<Value>(_ key :String, equal expectedValue :Value)
        ->Self where Value : Equatable
    {
        let
        predicate = EqualPredicate(key: key, expectedValue: expectedValue),
        predicates = buffer.get("predicates", Predicates())
        predicates.add(predicate)
        return self
    }
    
    func
        point() throws ->Point {
        let
        dictionary = try buffer.build(),
        defaults = dictionary["defaults"] as? PointDefaults
        
        guard let
            trackers = (dictionary["trackers"] as? [Tracker]) ?? defaults?.trackers
            else {
                throw BuilderError.missedProperty(
                    name: "trackers",
                    result: String(describing: Result.self)
                )
        }
        
        let
            predicates = (dictionary["predicates"] as? [Predicate]) ?? defaults?.predicates
        
        let
        payload = try self.payload(from: dictionary)
        return Point(
            trackers: trackers,
            predicates: predicates,
            payload: payload
        )
    }
    
    internal func
        payload(from buffer:[String:Any]) throws ->[String:Any]? {
        return buffer
    }
}

extension PointBuilder {
    subscript(key :String) ->Any? {
        get { return buffer[key] }
        set { buffer[key] = newValue }
    }
}

extension
PointBuilder : Builder {
    typealias
        Result = Point
    func
        build() throws -> Point { return try point() }
    func
        _build() throws -> Any { return try build() }
}

public typealias
    PointBuilding = (PointBuilder)->Void
