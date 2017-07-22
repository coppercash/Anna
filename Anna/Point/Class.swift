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
    children :[Child.Method: Child]?
    weak var
    parent :Parent!
    let
    superClassPoint :EasyClassPoint?
    init(
        trackers :[Tracker]?,
        overridesTrackers :Bool,
        payload :Payload?,
        superClassPoint :EasyClassPoint? = nil,
        children :[Child.Method: Child]?,
        parent :Parent? = nil
        ) {
        self.parent = parent
        self.children = children
        self.superClassPoint = superClassPoint
        super.init(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
            payload: payload
        );
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
        if let methods = children?[conditions.method]?.points(match: conditions) {
            points.append(contentsOf: methods)
        }
        if points.isEmpty, let inherited = superClassPoint?.points(match: conditions) {
            points.append(contentsOf: inherited)
        }
        return points
    }
}

public enum
ClassPointBuilderError : Error {
   case emtpyRegistration
}

extension
ClassPointBuilderError : LocalizedError {
    public var
    errorDescription: String? {
        switch self {
        case .emtpyRegistration:
            return "Empty registration is not allowed. At least one of following property should be presented: childrenPoints, superClass"
        }
    }
}

final class
EasyClassPointBuilder :
    EasyBasePointBuilder<EasyClassPoint>,
    EasyTrackerBuilding
{
    public var
    trackersBuffer :[EasyTrackerBuilding.Tracker]? = nil
    var
    overridesTrackers: Bool = false
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
    func
        madeChildrenByMethod() throws ->Dictionary<MethodPoint.Method, MethodPoint>? {
        guard let
            children :ChildrenBuffer = childrenBuffer,
            children.count > 0
            else { return nil }
        
        var childrenByMethod = Dictionary<MethodPoint.Method, MethodPoint>()
        
        // For every Method Point Builder
        //
        for child :ChildBuilder in children.elements() {
            let point = try child.point()
            // One Method Point Builder could have multiple bound selectors and methods
            //
            try childrenByMethod.updatePoints(for: child.allMethods(), with: point)
        }
        
        return childrenByMethod
    }
    
    
    // MARK:- Class
    
    typealias
        Class = EasyRegistering
    var
    classBuffer :Class.Type? = nil
    
    // MARK:- Super Class
    
    typealias
        SuperClass = EasyRegistering
    var
    superClassBuffer :SuperClass.Type? = nil
    var
    superClassPointBuilder :EasyClassPointBuilder? = nil
    public func
        superClass(_ cls :SuperClass.Type) ->Self {
        superClassBuffer = cls
        return self
    }
    func
        madeSuperClassPoint() throws ->Point? {
        guard let superClass = superClassBuffer else { return nil }
        let
        builder = EasyClassPointBuilder(trackers: trackers)
        builder.classBuffer = superClass
        let
        point = try builder.point()
        
        self.superClassPointBuilder = builder
        return point
    }
    
    // MARK:- Build
    
    typealias
        Point = EasyClassPoint
    typealias
        MethodPoint = EasyMethodPoint
    override func
        point() throws ->Point {
        guard let cls = classBuffer else {
            throw BuilderError.missedProperty(
                name: "class",
                result: String(describing: Result.self)
            )
        }
        cls.registerAnalyticsPoints(with: self)
        let
        childrenByMethod = try madeChildrenByMethod(),
        superClassPoint = try madeSuperClassPoint()
        guard
            childrenByMethod != nil ||
            superClassPoint != nil
            else {
                throw ClassPointBuilderError.emtpyRegistration
        }
        let
        trackers = trackersBuffer,
        dictionary = try buffer.build(),
        payload = try self.payload(from: dictionary),
        point = Point(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
            payload: payload,
            superClassPoint: superClassPoint,
            children: childrenByMethod
        )
        if let children = point.children?.values {
            for child in children {
                child.parent = point
            }
        }
        
        return point
    }
}
