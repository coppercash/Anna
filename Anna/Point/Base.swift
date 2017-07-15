//
//  Base.swift
//  Anna
//
//  Created by William on 14/06/2017.
//
//

import Foundation

public protocol
EasyPayloadCarrier : class {
    typealias
        Payload = Dictionary<String, Any>
    var
    payload :Payload? { get }
}

protocol
EasyTrackerCarrier {
    typealias
        Tracker = EasyTracker
    var
    trackers :[Tracker]? { get }
    var
    overridesTrackers :Bool { get }
}

protocol
EasyPayloadNode : EasyPayloadCarrier, EasyTrackerCarrier {
    var
    parentNode :EasyPayloadNode? { get }
    func
        mergedFromRoot() throws ->EasyPayloadNode
}

extension
EasyPayloadNode {
    func
        mergedFromRoot() throws ->EasyPayloadNode {
        var
        stack = Array<EasyPayloadNode>()
        var
        current :EasyPayloadNode! = self
        while current != nil {
            stack.append(current)
            current = current.parentNode
        }
        var
        payload = Self.Payload()
        var
        trackers = Array<Self.Tracker>()
        while stack.isEmpty == false {
            let
            current = stack.removeLast()
            if let
                cPayload = current.payload {
                payload.merge(with: cPayload)
            }
            if current.overridesTrackers {
                trackers = current.trackers ?? Array<Self.Tracker>()
            }
            else {
                if let cTrackers = current.trackers {
                    trackers.merge(with: cTrackers)
                }
            }
        }
        return EasyPoint(
            trackers: trackers,
            overridesTrackers :true,
            payload: payload,
            predicates: nil,
            children: nil
        )
    }
}

protocol
EasyPointMatching {
    typealias
        Conditions = EasyPointMatchable
    typealias
        Point = EasyPayloadNode
    func
        points(match conditions :Conditions) ->[Point]?
}

protocol
EasyPointMatchable {
    typealias
        Class = Any.Type
    var
    cls :Class { get }
    typealias
        Method = String
    var
    method :Method { get }
    func
        object(to predicate :Predicate) ->Any?
}

public class
EasyBasePoint : EasyPayloadCarrier {
    public typealias
        Payload = Dictionary<String, Any>
    public let
    payload :Payload?
    public typealias
        Tracker = EasyTracker
    public let
    trackers :[Tracker]?
    let
    overridesTrackers :Bool
    
    public
    init(
        trackers :[Tracker]? = nil,
        overridesTrackers :Bool,
        payload :Payload? = nil
        ) {
        self.trackers = trackers
        self.overridesTrackers = overridesTrackers
        self.payload = payload
    }
}

enum EasyBasePointBuilderError : Error {
   case unimplemented
}

public class
EasyBasePointBuilder<Point>
where
    Point : EasyBasePoint
{
    public typealias
        Buffer = DictionaryBuilder<String, Any>
    public let
    buffer = Buffer()
    
    // MARK:- Payload
    
    @discardableResult public func
        set(_ key :String, _ value :Any?) ->Self {
        buffer.set(key, value)
        return self
    }
    
    // MARK:- Build
    
    func
        point() throws ->Point {
        throw EasyBasePointBuilderError.unimplemented
    }
    
    internal func
        payload(from buffer:[String:Any]) throws ->[String:Any]? {
        return buffer
    }
}

extension
EasyBasePointBuilder : BuilderPropertyBuffer {
    subscript(key :String) ->Any? {
        get { return buffer[key] }
        set { buffer[key] = newValue }
    }
}

extension
EasyBasePointBuilder : Builder {
    public typealias
        Result = Point
    public func
        build() throws -> Point { return try point() }
    public func
        _build() throws -> Any { return try build() }
}
