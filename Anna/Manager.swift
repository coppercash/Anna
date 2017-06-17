//
//  Manager.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

open class
EasyManager {
    
    public typealias
        Root = EasyRootPoint
    let
    root :Root
    
    let
    queue :DispatchQueue = DispatchQueue(label: "Anna")
    
    init(root :Root) {
        self.root = root
    }
    
    public typealias
        Configuration = EasyConfiguration
    public convenience init
        (config :Configuration) {
        let
        root = EasyRootPoint(
            trackers: config.pointDefaults.trackers,
            payload: config.pointDefaults.payload
        )
        self.init(root: root)
    }
    
    
    public typealias
        Event = EasyEvent
    public typealias
        Seed = EasyEventSeed
    func receive(_ seed :Seed) {
        queue.async {
            try! self.dispatch(seed)
        }
    }
    
    public typealias
        Point = EasyPoint
    func dispatch(_ seed :Seed) throws {
        // Try to load points if they have not been loaded
        //
        try loadPoints(for: seed.cls)
        
        // Find point
        //
        let
        points :[EasyPayloadNode]! = self.root.points(match: seed)
        assert(
            points != nil && points.count == 1,
            "Exactly one point is expected to be matched, " +
            "but found \(points.count). \n\(points)"
        )
        
        guard let
            point = points?.first
            else { return }
        
        // Dispatch the event with point to every tracker tracks the point
        //
        let merged = try point.mergedFromRoot()
        guard
            let trackers = merged.trackers,
            trackers.count > 0
            else {
                // TODO: throw
                return
        }
        let
        event = try EasyEvent(seed: seed, point: point)
        for tracker in trackers {
            tracker.receiveAnalyticsEvent(
                event,
                dispatchedBy: self
            )
        }
    }
    
    typealias
        Class = EasyAnalyzable
    typealias
        ClassPointBuilder = EasyClassPointBuilder
    func loadPoints(for cls :Class.Type) throws {
        guard
            root.classPoint(for: cls) == nil
            else { return }
        let
        builder = ClassPointBuilder()
        cls.registerAnalysisPoints(with: builder)
        let
        point = try builder.point()
        point.parent = root
        root.setClassPoint(point, for: cls)
    }
}

extension
EasyClassPointBuilder : EasyRegistrar {}

public protocol
EasyPointDefaults {
    typealias
        Payload = Dictionary<String, Any>
    var
    payload :Payload? { get }
    typealias
        Tracker = EasyTracker
    var
    trackers :[Tracker] { get }
}

public protocol
EasyConfiguration {
    typealias
        PointDefaults = EasyPointDefaults 
    var pointDefaults :PointDefaults { get }
}
