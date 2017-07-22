//
//  MethodPointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public protocol
    EasyMethodPointBuilding {
    typealias
        Buildup = (EasyMethodPointBuilding)->Void
    typealias
        MethodName = String
    @discardableResult func
        method(_ name :MethodName) ->Self
    @discardableResult func
        selector(_ selector :Selector) ->Self
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
        Trackers = EasyTrackerCollection
    var
    trackers :Trackers { get }
}

class
EasyMethodPoint : EasyBasePoint {
    
    typealias
    Method = String
    typealias
        Child = EasyPoint
    let
    children :[Child]?
    typealias
        Parent = EasyClassPointBeing
    weak var
    parent :Parent!
    
    init(
        trackers :[Tracker]?,
        overridesTrackers :Bool,
        payload :Payload?,
        children :[Child]?,
        parent :Parent? = nil
        ) {
        self.parent = parent
        self.children = children
        super.init(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
            payload: payload
        );
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
EasyMethodPoint : EasyPointMatching {
    internal func
        points(match conditions: EasyPointMatching.Conditions) ->[EasyPointMatching.Point]? {
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
            self.trackers?.updated(with :another.trackers!)
        let
        overridesTrackers = self.overridesTrackers && another.overridesTrackers
        let
        payload = another.payload == nil ?
            self.payload :
            self.payload?.updated(with: another.payload!)
        let
        children = another.children == nil ?
            self.children :
            self.children?.updated(with :another.children!)
        return EasyMethodPoint(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
            payload: payload,
            children: children,
            parent: parent
        )
    }
}

final class
    EasyMethodPointBuilder :
    EasyBasePointBuilder<EasyMethodPoint>,
    EasyMethodPointBuilding,
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
    
    // MARK:- Method
    
    lazy var
    methodNames = Array<EasyMethodPointBuilding.MethodName>()
    @discardableResult func
        method(_ name :MethodName) ->Self {
        methodNames.append(name)
        return self
    }
    
    lazy var
    selectors = Array<Selector>()
    @discardableResult func
        selector(_ selector :Selector) ->Self {
        selectors.append(selector)
        return self
    }
    
    typealias
        Method = String
    func
        allMethods() ->[Method] {
        var
        methods = Array<EasyMethodPointBuilding.MethodName>()
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
        payload = try self.payload(from: dictionary),
        children = try childrenBuffer?.array(),
        trackers = trackersBuffer,
        point = Point(
            trackers: trackers,
            overridesTrackers: overridesTrackers,
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
