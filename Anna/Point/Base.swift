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
            if let
                cTrackers = current.trackers {
                trackers.merge(with: cTrackers)
            }
        }
        return EasyPoint(
            trackers: trackers,
            payload: payload,
            predicates: nil,
            children: nil
        )
    }
}

protocol
EasyEventMatching {
    typealias
    Event = EasyEventSeed
    typealias
        Point = EasyPayloadNode
    func points(match event :Event) ->[Point]?
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
    
    public
    init(
        trackers :[Tracker]? = nil,
        payload :Payload? = nil
        ) {
        self.trackers = trackers
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
        set(_ key :String, _ value :Any) ->Self {
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
