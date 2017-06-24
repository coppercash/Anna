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

enum
EasyMethodPointError : Error {
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

final public class
EasyMethodPointBuilder : EasyBasePointBuilder<EasyMethodPoint>, EasyTrackerConfigurable {
    
    public let
    trackers :EasyTrackerConfigurable.Trackers
    init(trackers :EasyTrackerConfigurable.Trackers) {
        self.trackers = trackers
    }
    
    // MARK:- Children
    
    public typealias
        Child = EasyPointBuilder
    typealias
        ChildPoints = ArrayBuilder<Child.Result>
    @discardableResult public func
        point(_ buildup :Child.Buildup) ->Self {
        let
        builder = Child(trackers: trackers)
        buildup(builder)
        let
        points = buffer.get("children", ChildPoints())
        points.add(builder)
        return self
    }
    
    // MARK:- Method
    
    public typealias
        MethodName = String
    lazy var
    methodNames = [MethodName]()
    @discardableResult public func
        method(_ name :MethodName) ->Self {
        methodNames.append(name)
        return self
    }
    
    lazy var
    selectors = Array<Selector>()
    @discardableResult public func
        selector(_ selector :Selector) ->Self {
        selectors.append(selector)
        return self
    }
    
    typealias
        Method = String
    func
        allMethods() ->[Method] {
        var
        methods = [MethodName]()
        for methodName in methodNames {
            methods.append(methodName)
        }
        for selector in selectors {
            let
            methodName = selector.methodName
            methods.append(methodName)
        }
        return methods
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
