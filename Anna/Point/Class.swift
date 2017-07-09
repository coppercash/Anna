//
//  ClassPointSet.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

protocol
EasyClassPointBeing : class, EasyPointMatching, EasyPayloadNode {
    typealias
        Class = String
    typealias
        Child = EasyMethodPoint
    typealias
        Parent = EasyRootPoint
}

class
EasyClassPoint : EasyBasePoint, EasyClassPointBeing {
    let
    children :[Child.Method: Child]
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
EasyClassPoint : EasyPointMatching {
    internal func
        points(match conditions: EasyPointMatching.Conditions) ->[EasyPointMatching.Point]? {
        var
        points = Array<EasyPointMatching.Point>()
        if let methods = children[conditions.method]?.points(match: conditions) {
            points.append(contentsOf: methods)
        }
        if let supers = superClassPoint?.points(match: conditions) {
            points.append(contentsOf: supers)
        }
        return points
    }
}

final class
EasyClassPointBuilder :
    EasyBasePointBuilder<EasyClassPoint>,
    EasyTrackerBuilding
{
    public var
    trackersBuffer :[EasyTrackerBuilding.Tracker]? = nil
    public let
    trackers :EasyTrackerBuilding.Trackers
    init(trackers :EasyTrackerBuilding.Trackers) {
        self.trackers = trackers
    }
    
    // MARK:- Children
    
    typealias
        Child = EasyMethodPoint
    typealias
        ChildBuilder = EasyMethodPointBuilder
    typealias
        ChildrenBuffer = ArrayBuilder<Child>
    public var
    childrenBuffer :ChildrenBuffer? = nil
    @discardableResult func
        point(_ buildup :ChildBuilder.Buildup) ->Self {
        let
        builder = ChildBuilder(trackers: trackers)
        buildup(builder)
        append(builder)
        return self
    }
    func
        append(_ child :ChildBuilder) {
        if childrenBuffer == nil { childrenBuffer = ChildrenBuffer() }
        childrenBuffer!.add(child)
    }
    
    // MARK:- Build
    
    typealias
        Point = EasyClassPoint
    typealias
        MethodPoint = EasyMethodPoint
    override func
        point() throws ->Point {
        let
        childrenByMethod = try madeChildrenByMethod(),
        trackers = trackersBuffer,
        dictionary = try buffer.build(),
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
    
    func madeChildrenByMethod() throws ->Dictionary<MethodPoint.Method, MethodPoint> {
        guard let
            children :ChildrenBuffer = childrenBuffer,
            children.count > 0
            else {
                throw BuilderError.missedProperty(
                    name: "children",
                    result: String(describing: self)
                )
        }
        
        var childrenByMethod = Dictionary<MethodPoint.Method, MethodPoint>()
        
        // For every Method Point Builder
        //
        for child :ChildBuilder in children.elements() {
            
            // One Method Point Builder could have multiple bound methods
            //
            for method in child.allMethods() {
                
                // If the point by the method has yet been registered,
                // build a new point from the Method Point Builder
                //
                guard let point = childrenByMethod[method] else {
                    childrenByMethod[method] = try child.point()
                    continue
                }
                
                // If the point by the method has been registered,
                // update the previously registered point with the newly built point
                //
                childrenByMethod[method] = try point.merged(with: try child.point())
            }
        }
        return childrenByMethod
    }
}
