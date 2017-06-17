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
    var parentNode :EasyPayloadNode? { get }
    func merged(with another :EasyPayloadNode) ->EasyPayloadNode
}

protocol
EasyEventMatching {
    typealias
        Event = EasyEvent
    typealias
        Point = EasyPoint
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
    
    func
        merged(with another: EasyPayloadNode) -> EasyPayloadNode {
        let
        payload = another.payload == nil ?
            self.payload :
            self.payload?.merged(with: another.payload!)
        return EasyPoint(
            trackers: nil,
            payload: payload,
            predicates: nil,
            children: nil
        )
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
    typealias
        Buffer = DictionaryBuilder<String, Any>
    let
    buffer = Buffer()
    
    public required
    init() {}
    
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
EasyBasePointBuilder : StringAnySubscriptable {
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

/*
extension
EasyBasePointBuilder : StringAnyDictionaryBufferringBuilder {}
 */
