//
//  Point.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

public protocol
EasyPointBuilding {
    typealias
        Buildup = (EasyPointBuilding)->Void
    @discardableResult func
        when<Value>(_ key :String, equal expectedValue :Value)
        ->Self where Value : Equatable
    @discardableResult func
        set(_ key :AnyHashable, _ value :Any?) ->Self
    typealias
        ChildBuilder = EasyPointBuilding
    @discardableResult func
        point(_ buildup :ChildBuilder.Buildup) ->Self
    typealias
        Tracker = EasyTracking
    @discardableResult func
        tracker(_ tracker :Tracker) ->Self
    @discardableResult func
        trackers<Trackers>(_ trackers :Trackers) ->Self
        where Trackers : Sequence, Trackers.Iterator.Element == Tracker
    typealias
        Trackers = EasyTrackerCollecting
    var
    trackers :Trackers { get }
}

class
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
        overridesTrackers :Bool,
        payload :Payload?,
        predicates :[Predicate]?,
        children :[Child]?,
        parent :Parent? = nil
        ) {
        self.predicates = predicates
        self.parent = parent
        self.children = children
        super.init(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
            payload: payload
        );
    }
    
    typealias
        Predicate = Anna.Predicate
    let
    predicates :[Predicate]?
}

extension
EasyPoint : EasyPointMatching {
    internal func
        points(match conditions: EasyPointMatching.Conditions) ->[EasyPointMatching.Point]? {
        guard
            matches(conditions)
            else { return nil }
        guard
            let children = self.children,
            children.count > 0
            else { return [self] }
        var
        points = Array<EasyPointMatching.Point>()
        for child in children {
            guard
                let childPoints = child.points(match: conditions)
                else { continue }
            points.append(contentsOf: childPoints)
        }
        return points
    }
    
    func matches(_ conditions :EasyPointMatching.Conditions) ->Bool {
        guard let
            predicates = self.predicates
            else { return true }
        for predicate in predicates {
            let
            object = conditions.object(to: predicate)
            guard
                predicate.evaluate(with: object)
                else { return false }
        }
        return true
    }
}

extension
EasyPoint : EasyPayloadNode {
    var
    parentNode: EasyPayloadNode? {
        return parent
    }
}

final class
    EasyPointBuilder :
    EasyBasePointBuilder<EasyPoint>,
    EasyPointBuilding,
    EasyTrackerBuilding,
    EasyChildrenBuilding
{
    
    init(trackers :EasyTrackerBuilding.Trackers) {
        self.trackers = trackers
    }
    
    // MARK:- Trackers
    
    var
    trackersBuffer :[EasyTrackerBuilding.Tracker]? = nil
    var
    overridesTrackers: Bool = false
    let
    trackers :EasyTrackerBuilding.Trackers
    
    // MARK:- Children
    
    var
    childrenBuffer :ChildrenBuffer? = nil
    
    // MARK:- Predicates
    
    typealias
        PredicatesBuffer = ArrayBuilder<Predicate>
    lazy var
    predicatesBuffer :PredicatesBuffer? = nil
    @discardableResult func
        when<Value>(_ key :String, equal expectedValue :Value)
        ->Self where Value : Equatable
    {
        let
        predicate = EqualPredicate(key: key, expectedValue: expectedValue)
        append(predicate)
        return self
    }
    
    func
        append(_ predicate :Predicate) {
        if predicatesBuffer == nil { predicatesBuffer = PredicatesBuffer() }
        predicatesBuffer!.add(predicate)
    }
    
    // MARK:- Build
    
    typealias
        Point = EasyPoint
    override func
        point() throws -> Point {
        let
        dictionary = try buffer.build(),
        payload = try self.payload(from: dictionary),
        trackers = trackersBuffer,
        predicates = try predicatesBuffer?.array(),
        children = try childrenBuffer?.array(),
        point = Point(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
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
