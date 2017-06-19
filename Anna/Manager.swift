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
    
}

// MARK: - Load Points

extension
EasyClassPointBuilder : EasyRegistrar {}
extension
EasyManager {
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
        cls.registerAnalyticsPoints(with: builder)
        let
        point = try builder.point()
        point.parent = root
        root.setClassPoint(point, for: cls)
    }
}

// MARK: - Receive & Dispatch

public enum
MatchingError : Error {
    case noMatchingPoint(class :String, method :String)
    case tooManyMatchingPoints(count :Int)
}

extension
MatchingError : Equatable {
    public static func
        == (lhs: MatchingError, rhs: MatchingError) ->Bool {
        switch (lhs, rhs) {
        case (.noMatchingPoint, .noMatchingPoint):
            return true
        case (.tooManyMatchingPoints, .tooManyMatchingPoints):
            return true
        default:
            return false;
        }
    }
}

extension
EasyManager {
    public typealias
        Event = EasyEvent
    public typealias
        Seed = EasyEventSeed
    func receive(_ seed :Seed) {
        queue.async {
            do {
               try self.dispatch(seed)
            }
            catch {
                self.sendDefaultTrackers(error)
            }
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
        guard
            points.count > 0
            else { throw MatchingError.noMatchingPoint(class: String(describing: seed.cls), method: seed.method) }
        guard
            points.count <= 1
            else { throw MatchingError.tooManyMatchingPoints(count: points.count) }
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
            tracker.receive(
                analyticsEvent: event,
                dispatchedBy: self
            )
        }
    }
    
    
    func
        sendDefaultTrackers(_ error :Error) {
        for tracker in root.trackers! {
            tracker.receive(analyticsError: error, dispatchedBy: self)
        }
    }
}
    
