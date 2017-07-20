//
//  ANAClass.swift
//  Anna
//
//  Created by William on 07/07/2017.
//
//

import Foundation

class
ANAClassPoint : EasyBasePoint, EasyClassPointBeing {
    let
    children :[Selector : Child]
    var
    childrenByMethod :[Child.Method : Child]? = nil
    var
    hasChildrenConverted = false
    weak var
    parent :Parent!
    let
    superClassPoint :ANAClassPoint?
    init(
        trackers :[Tracker]?,
        overridesTrackers :Bool,
        payload :Payload?,
        superClassPoint :ANAClassPoint? = nil,
        children :[Selector: Child],
        childrenByMethod :[Child.Method : Child]?,
        parent :Parent? = nil
        ) {
        self.parent = parent
        self.children = children
        self.childrenByMethod = childrenByMethod
        self.superClassPoint = superClassPoint
        super.init(
            trackers: trackers,
            overridesTrackers :overridesTrackers,
            payload: payload
        );
    }
}

extension
ANAClassPoint : EasyPayloadNode {
    var parentNode: EasyPayloadNode? {
        return parent
    }
}

extension
ANAClassPoint : EasyPointMatching {
    internal func
        points(match conditions: EasyPointMatching.Conditions) ->[EasyPointMatching.Point]? {
        var
        points = Array<EasyPointMatching.Point>()
        if let conditions = conditions as? ObjCEventSeed {
            if let methods = children[conditions.proto.selector]?.points(match: conditions) {
                points.append(contentsOf: methods)
            }
        }
        else {
            if hasChildrenConverted == false {
                convertChildren()
                hasChildrenConverted = true
            }
            if let methods = childrenByMethod?[conditions.method]?.points(match: conditions) {
                points.append(contentsOf: methods)
            }
        }
        if points.isEmpty,
            let supers = superClassPoint?.points(match: conditions) {
            points.append(contentsOf: supers)
        }
        return points
    }
    
    func
        convertChildren() {
        var byMethod = Dictionary<Child.Method, Child>()
        for (selector, child) in children {
            byMethod[selector.methodName] = child
        }
        if let children = childrenByMethod {
            for (method, child) in children {
                byMethod[method] = child
            }
        }
        self.childrenByMethod = byMethod
    }
}

public class
    ANAClassPointBuilder :
    NSObject,
    ANAClassPointBuilding
{
    typealias
        Proto = EasyClassPointBuilder
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
        self.availableTrackers = ObjCTrackerCollection(proto.trackers)
    }

    public var
    point: (ANAMethodPointBuildup?) -> ANAClassPointBuilding {
        return { [unowned self] (buildup) in
            let
            builder = ANAMethodPointBuilder(
                ANAMethodPointBuilder.Proto(
                    trackers: self.proto.trackers
                )
            )
            buildup!(builder)
            self.proto.append(builder.proto)
            return self
        }
    }
    
    public var
    tracker: (ANATracking) -> ANAClassPointBuilding {
        return { [unowned self] (tracker) in
            self.proto.tracker(SwiftEasyTracker(tracker))
            return self
        }
    }

    public var
    trackers: ([ANATracking]) -> ANAClassPointBuilding {
        return { [unowned self] (trackers) in
            self.proto.trackers(trackers.map { SwiftEasyTracker($0) })
            return self
        }
    }
    
    public let
    availableTrackers: ANATrackerCollection
    
    // MARK: - Class
    
    typealias
        Class = ANARegistering
    var
    classBuffer :Class.Type? = nil
    
    // MARK:- Super Class
    
    typealias
        SuperClass = Class
    var
    superClassBuffer :SuperClass.Type? {
        guard let superClass = class_getSuperclass(classBuffer) as? SuperClass.Type else { return nil }
        return superClass
    }
    var
    superClassPointBuilder :ANAClassPointBuilder? = nil
    func
        madeSuperClassPoint() throws ->Result? {
        guard let superClass = superClassBuffer else { return nil }
        let
        builder = ANAClassPointBuilder(Proto(trackers: proto.trackers))
        builder.classBuffer = superClass
        let
        point = try builder.build()
        
        self.superClassPointBuilder = builder
        return point
    }
    
    // MARK: - Children
    
    func madeChildren() throws ->(Dictionary<Selector, Proto.MethodPoint>, Dictionary<Proto.MethodPoint.Method, Proto.MethodPoint>) {
        guard let
            children :Proto.ChildrenBuffer = proto.childrenBuffer,
            children.count > 0
            else {
                throw BuilderError.missedProperty(
                    name: "children",
                    result: String(describing: Result.self)
                )
        }
        
        var
        childrenBySelector = Dictionary<Selector, Proto.MethodPoint>(),
        childrenByMethod = Dictionary<Proto.MethodPoint.Method, Proto.MethodPoint>()
        
        // For every Method Point Builder
        //
        for child :Proto.ChildBuilder in children.elements() {
            let point = try child.point()
            // One Method Point Builder could have multiple bound selectors and methods
            //
            try childrenBySelector.updatePoints(for: child.selectors, with: point)
            try childrenByMethod.updatePoints(for: child.methodNames, with: point)
        }
        return (childrenBySelector, childrenByMethod)
    }
}

extension
ANAClassPointBuilder {
    typealias
        Result = ANAClassPoint
    func
        build() throws ->Result {
        guard
            let cls = classBuffer else {
                throw BuilderError.missedProperty(
                    name: "class",
                    result: String(describing: type(of: self))
                )
        }
        cls.ana_registerAnalyticsPoints(withRegistrar: self)
        guard
            let children = try? madeChildren()
            else {
                throw ClassPointBuilderError.emtpyRegistration
        }
        let
        superClassPoint = try madeSuperClassPoint(),
        trackers = proto.trackersBuffer,
        dictionary = try proto.buffer.build(),
        payload = try proto.payload(from: dictionary),
        point = Result(
            trackers: trackers,
            overridesTrackers: proto.overridesTrackers,
            payload: payload,
            superClassPoint: superClassPoint,
            children: children.0,
            childrenByMethod: (children.1.isEmpty ? nil : children.1)
        )
        for child in point.children.values {
            child.parent = point
        }
        
        return point
    }
    
}

extension
Dictionary
    where Value == EasyMethodPoint
{
    mutating func
        updatePoints(for keys :[Key], with point :Value) throws {
        for key in keys {
            // If the point by the method has yet been registered, directly assign it
            //
            guard let previous = self[key] else {
                self[key] = point
                continue
            }
            // If the point by the method has been registered,
            // update the previously registered point with the new point
            //
            self[key] = try previous.merged(with: point)
        }
    }
}
