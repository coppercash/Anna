//
//  Base.swift
//  Anna
//
//  Created by William on 14/06/2017.
//
//

import Foundation

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
                payload.update(with: cPayload)
            }
            if current.overridesTrackers {
                trackers = current.trackers ?? Array<Self.Tracker>()
            }
            else {
                if let cTrackers = current.trackers {
                    trackers.update(with: cTrackers)
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

class
EasyBasePoint : EasyPayloadCarrier {
    let
    payload :Payload?
    typealias
        Tracker = EasyTracking
    let
    trackers :[Tracker]?
    let
    overridesTrackers :Bool
    
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

class
EasyBasePointBuilder<Point>
where
    Point : EasyBasePoint
{
    typealias
        Buffer = DictionaryBuilder<AnyHashable, Any>
    let
    buffer = Buffer()
    
    // MARK:- Payload
    
    @discardableResult public func
        set(_ key :AnyHashable, _ value :Any?) ->Self {
        buffer.set(key, value)
        return self
    }
    
    // MARK:- Build
    
    func
        point() throws ->Point {
        throw EasyBasePointBuilderError.unimplemented
    }
    
    internal func
        payload(from buffer :[AnyHashable : Any]) throws ->[AnyHashable : Any]? {
        return buffer
    }
}

extension
EasyBasePointBuilder : Builder {
    typealias
        Result = Point
    func
        build() throws -> Point { return try point() }
    func
        _build() throws -> Any { return try build() }
}
