//
//  ClassPointSet.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

class
EasyClassPoint : EasyBasePoint {
    
    typealias
        Class = String
    typealias
        Child = EasyMethodPoint
    let
    children :[Child.Method: Child]
    typealias
        Parent = EasyRootPoint
    weak var
    parent :Parent!
    let
    superClassPoint :EasyClassPoint?
    init(
        trackers :[Tracker]?,
        payload :Payload?,
        superClassPoint :EasyClassPoint? = nil,
        children :[Child.Method: Child],
        parent :Parent? = nil
        ) {
        self.parent = parent
        self.children = children
        self.superClassPoint = superClassPoint
        super.init(trackers: trackers, payload: payload);
    }
}

extension
EasyClassPoint :  EasyPayloadNode {
    var parentNode: EasyPayloadNode? {
        return parent
    }
}

/*
 self.class | self.method | super.class | super.method | expected | search
 0            0             0             0              -
 0            0             0             1              -
 0            0             1             0              nothing
 0            0             1             1              in super   self, super
 0            1             0             0              -
 0            1             0             1              -
 0            1             1             0              -
 0            1             1             1              -
 1            0             0             0              nothing    self
 1            0             0             1              -
 1            0             1             0              nothing    self, super
 1            0             1             1              in super   self, super
 1            1             0             0              in self    self
 1            1             0             1              -
 1            1             1             0              in self    self
 1            1             1             1              in both    self, super
 */
extension
EasyClassPoint : EasyEventMatching {
    internal func
        points(match event: EasyEventMatching.Event) ->[EasyEventMatching.Point]? {
        var
        points = Array<EasyEventMatching.Point>()
        var
        current :EasyClassPoint! = self
        while current != nil {
            if let matched = current.points(match: event) {
                points.append(contentsOf: matched)
            }
            current = current.superClassPoint
        }
        return points
    }
}

class
EasyClassPointBuilder : EasyBasePointBuilder<EasyClassPoint> {

    // MARK:- Children
    
    typealias
        Child = EasyMethodPointBuilder
    typealias
        Children = ArrayBuilder<Child.Result>
    @discardableResult func
        point(_ buildup :Child.Buildup) ->Self {
        let
        points = buffer.get("children", Children())
        points.add(buildup)
        return self
    }
    
    // MARK:- Build
    
    typealias
        Point = EasyClassPoint
    typealias
        MethodPoint = EasyMethodPoint
    override func
        point() throws ->Point {
        let
        childrenByMethod = try self.childrenByMethod(from: buffer),
        dictionary = try buffer.build(),
        trackers = dictionary["trackers"] as? [Point.Tracker],
        payload = try self.payload(from: dictionary),
        point = Point(
            trackers: trackers,
            payload: payload,
            superClassPoint: nil,
            children: childrenByMethod
        )
        for child in point.children.values {
            child.parent = point
        }
        
        return point
    }
    
    func childrenByMethod(from buffer :Buffer) throws ->Dictionary<MethodPoint.Method, MethodPoint> {
        guard let
            children :Children = buffer.removeProperty(forKey: "children"),
            children.count > 0
            else {
                throw BuilderError.missedProperty(name: "children", result: String(describing: self))
        }
        var
        childrenByMethod = Dictionary<MethodPoint.Method, MethodPoint>()
        for child :Child in children.elements() {
            let
            methods :EasyMethodPointBuilder.Methods = try child.required("methods", for: self)
            for method in try methods.array() {
                guard
                    let point = childrenByMethod[method]
                    else {
                        childrenByMethod[method] = try child.point()
                        continue
                }
                childrenByMethod[method] = try point.merged(with: try child.point())
            }
        }
        return childrenByMethod
    }
}
