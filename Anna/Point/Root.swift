//
//  PointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public class
EasyRootPoint {
    typealias
        Child = EasyClassPoint
    var
    children :[Child.Class: Child] = Dictionary<Child.Class, Child>()
    public typealias
        Tracker = EasyTracker
    lazy var
    trackers :[Tracker]? = nil
    
    init() {
    }
}

extension
EasyRootPoint : EasyPayloadNode {
    public var
    payload: EasyPayloadCarrier.Payload? {
        return nil
    }

    var
    parentNode: EasyPayloadNode? {
        return nil
    }
}

extension
EasyRootPoint : EasyEventMatching {
    func
        points(match event :EasyEventMatching.Event) ->[EasyEventMatching.Point]? {
        return classPoint(for: event.cls)?.points(match: event)
    }
}

extension
EasyRootPoint {
    typealias
        Sender = EasyAnalyzable
    func classPoint(for cls :Sender.Type) ->Child? {
        return children[String(describing: cls)]
    }
    func setClassPoint(_ classPoint :Child, for cls :Sender.Type) {
        children[String(describing: cls)] = classPoint
    }
}

public protocol
EasyChildrenBuilding : EasyTrackerBuilding {
    typealias
        Child = EasyPoint
    typealias
        ChildBuilder = EasyPointBuilder
    typealias
        ChildrenBuffer = ArrayBuilder<Child>
    var
    childrenBuffer :ChildrenBuffer? { get set }
    @discardableResult func
        point(_ buildup :ChildBuilder.Buildup) ->Self
}

extension
EasyChildrenBuilding {
    @discardableResult public func
        point(_ buildup :ChildBuilder.Buildup) ->Self {
        let
        builder = ChildBuilder(trackers: trackers)
        buildup(builder)
        if childrenBuffer == nil { childrenBuffer = ChildrenBuffer() }
        childrenBuffer!.add(builder)
        return self
    }
}
