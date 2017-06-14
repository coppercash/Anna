//
//  MethodPointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public class
EasyMethodPoint : EasyBasePoint {
    
    typealias
    Method = String
    typealias
        Child = EasyPoint
    let
    children :[Child]
    typealias
        Parent = EasyClassPoint
    weak var
    parent :Parent!
    
    init(
        trackers :[Tracker]?,
        payload :Payload?,
        children :[Child],
        parent :Parent? = nil
        ) {
        self.parent = parent
        self.children = children
        super.init(trackers: trackers, payload: payload);
    }
    
    /*
    typealias
        Point = EasyPoint
    let points :[Point]
    typealias
        Event = EasyEvent
    func points(match event :Event) ->[Point] {
        var points = [Point]()
        for point in self.points {
            guard point.matches(event) else { continue }
            points.append(point)
        }
        return points
    }
 */
}

extension
EasyMethodPoint : EasyPayloadNode {
    public var
    parentNode: EasyPayloadNode? {
        return parent
    }
}

extension EasyMethodPoint : EasyEventMatching {
    func points(match event :Event) ->[Point]? {
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
}

enum EasyMethodPointError : Error {
    case differentParent
}

extension EasyMethodPoint {
    func merged(with another :EasyMethodPoint) throws ->EasyMethodPoint {
        guard
            parent === another.parent
            else { throw EasyMethodPointError.differentParent }
        // TODO: Make tackers and children Set
        let
        trackers = another.trackers == nil ? self.trackers : self.trackers?.merged(with :another.trackers!)
        let
        payload = another.payload == nil ? self.payload : self.payload?.merged(with: another.payload!)
        let
        children = self.children.merged(with :another.children)
        return EasyMethodPoint(
            trackers: trackers,
            payload: payload,
            children: children,
            parent: parent
        )
    }
}

public class
EasyMethodPointBuilder : EasyBasePointBuilder<EasyMethodPoint> {
    
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
    
    public typealias
        MethodName = String
    typealias
        Methods = ArrayBuilder<Result.Method>
    @discardableResult public func
        method(_ name :MethodName) ->Self {
        let
        methods = buffer.get("methods", Methods())
        methods.add(name)
        return self
    }
    
    // MARK:- Build
    
    typealias
        Point = EasyMethodPoint
    override func
        point() throws -> Point {
        let
        dictionary = try buffer.build(),
        children :[Point.Child] = try dictionary.required("children", for: self),
        trackers = dictionary["trackers"] as? [Point.Tracker],
        payload = try self.payload(from: dictionary),
        point = Point(
            trackers: trackers,
            payload: payload,
            children: children
        )
        for child in point.children {
            child.parent = point
        }
        
        return point
    }
}
