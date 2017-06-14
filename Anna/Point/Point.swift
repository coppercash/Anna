//
//  Point.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

public class
EasyPoint : EasyBasePoint {
    typealias
        Child = EasyPoint
    let
    children :[Child]?
    typealias
        Parent = EasyPayloadNode
    weak var
    parent :Parent!
    
    init(
        trackers :[Tracker]?,
        payload :Payload?,
        predicates :[Predicate]?,
        children :[Child]?,
        parent :Parent? = nil
        ) {
        self.predicates = predicates
        self.parent = parent
        self.children = children
        super.init(trackers: trackers, payload: payload);
    }
    
    typealias
        Predicate = Anna.Predicate
    let
    predicates :[Predicate]?
}

extension
EasyPoint : EasyEventMatching {
    func points(match event :Event) ->[Point]? {
        guard
            matches(event)
            else { return nil }
        guard
            let children = self.children,
            children.count > 0
            else { return [self] }
        var
        points = Array<EasyEventMatching.Point>()
        for child in children {
            guard
                let childPoints = child.points(match: event)
                else { continue }
            points.append(contentsOf: childPoints)
        }
        return points
    }
    
    func matches(_ event :EasyEventMatching.Event) ->Bool {
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

extension
EasyPoint : EasyPayloadNode {
    public var
    parentNode: EasyPayloadNode? {
        return parent
    }
}

public class
EasyPointBuilder : EasyBasePointBuilder<EasyPoint> {
    
    // MARK:- Children
    
    typealias
        Child = EasyPointBuilder
    typealias
        ChildPoints = ArrayBuilder<Child.Result>
    @discardableResult func
        point(_ buildup :Child.Buildup) ->Self {
        let
        points = buffer.get("children", ChildPoints())
        points.add(buildup)
        return self
    }
    
    // MARK:- Predicates
    
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
    
    // MARK:- Build
    
    typealias
        Point = EasyPoint
    override func
        point() throws -> Point {
        let
        dictionary = try buffer.build(),
        trackers = dictionary["trackers"] as? [Point.Tracker],
        payload = try self.payload(from: dictionary),
        predicates = dictionary["predicates"] as? [Point.Predicate],
        children = dictionary["children"] as? [Point.Child],
        point = Point(
            trackers: trackers,
            payload: payload,
            predicates: predicates,
            children: children
        )
        
        if let children = children {
            for child in children {
                child.parent = point
            }
        }
        
        return point
    }
}
