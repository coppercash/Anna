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
    children :[Child]?
    typealias
        Parent = EasyClassPoint
    weak var
    parent :Parent!
    
    init(
        trackers :[Tracker]?,
        payload :Payload?,
        children :[Child]?,
        parent :Parent? = nil
        ) {
        self.parent = parent
        self.children = children
        super.init(trackers: trackers, payload: payload);
    }
}

extension
EasyMethodPoint : EasyPayloadNode {
    var
    parentNode: EasyPayloadNode? {
        return parent
    }
}

extension
EasyMethodPoint : EasyEventMatching {
    internal func
        points(match event: EasyEventMatching.Event) ->[EasyEventMatching.Point]? {
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
}

enum EasyMethodPointError : Error {
    case differentParent
}

extension
EasyMethodPoint {
    func
        merged(with another :EasyMethodPoint) throws ->EasyMethodPoint {
        guard
            parent === another.parent
            else { throw EasyMethodPointError.differentParent }
        // TODO: Make tackers and children Set
        let
        trackers = another.trackers == nil ?
            self.trackers :
            self.trackers?.merged(with :another.trackers!)
        let
        payload = another.payload == nil ?
            self.payload :
            self.payload?.merged(with: another.payload!)
        let
        children = another.children == nil ?
            self.children :
            self.children?.merged(with :another.children!)
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
    
    public typealias
        Child = EasyPointBuilder
    typealias
        ChildPoints = ArrayBuilder<Child.Result>
    @discardableResult public func
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
        children = dictionary["children"] as? [Point.Child],
        trackers = dictionary["trackers"] as? [Point.Tracker],
        payload = try self.payload(from: dictionary),
        point = Point(
            trackers: trackers,
            payload: payload,
            children: children
        )
        if let children = point.children {
            for child in children {
                child.parent = point
            }
        }
        
        return point
    }
}
