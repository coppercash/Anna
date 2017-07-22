//
//  Manager.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

public protocol
EasyManaging {
    typealias
        Trackers = Anna.TrackerConfiguring & Anna.TrackerCollecting
    var
    trackers :Trackers { get }
}

public class
EasyManager : EasyManaging
{
    let
    configQueue :DispatchQueue,
    queue :DispatchQueue
    
    public init
        () {
        self.configQueue = DispatchQueue(
            label: "Anna.config",
            attributes: .concurrent
        )
        self.queue = DispatchQueue (
            label: "Anna.main",
            target: configQueue
        )
    }
    
    // MARK:- Point
    
    typealias
        Root = EasyRootPoint
    let
    root :Root = Root()
    
    // MARK:- Tracker
    
    lazy internal(set) public var
    trackers :Anna.Managing.Trackers = {
        return EasyTrackerConfigurator(host: self)
    }()
}

// MARK: - Singleton

extension
EasyManager {
    public static let
    shared = EasyManager()
}

// MARK: - Load Points

extension
EasyClassPointBuilder : EasyRegistrationRecording {}
extension
EasyManager {
    typealias
        Registrant = EasyRegistering.Type
    typealias
        ClassPointBuilder = EasyClassPointBuilder
    func loadPoints(for cls :Registrant) throws {
        guard root.classPoint(for: cls) == nil else { return }
        let
        builder = ClassPointBuilder(trackers: trackers)
        builder.classBuffer = cls
        let
        point = try builder.point()
        
        // Register the newly loaded point and all its super points
        //
        var
        current :EasyClassPoint? = point,
        currentBuilder :ClassPointBuilder? = builder
        while
            let point = current,
            let cls = currentBuilder?.classBuffer
        {
            point.parent = root
            root.setClassPoint(point, for: cls)
            current = point.superClassPoint
            currentBuilder = currentBuilder?.superClassPointBuilder
        }
    }
}

// MARK: - Receive & Dispatch

public enum
MatchingError : Error {
    case noMatchingPoint(class :String, method :String)
    case tooManyMatchingPoints(count :Int)
}

extension
MatchingError : LocalizedError {
    public var
    errorDescription: String? {
        switch self {
        case .noMatchingPoint(class: let cls, method: let method):
            return "No matching point found on class \(cls) for method \(method)."
        case .tooManyMatchingPoints(count: let count):
            return "Too many matching points found. Expected one but found \(count)."
        }
    }
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

public enum
ConfigurationError : Error {
   case noAvailableTrackers
}

extension
EasyManager : EasyEventDispatching {
    typealias
        Event = EasyEvent
    func
        dispatchEvent(with seed: Seed) {
        queue.async {
            do {
                // Try to load points if they have not been loaded
                //
                try self.loadPoints(for: seed.registrant)
                try self.dispatch(seed)
            }
            catch {
                self.sendDefaultTrackers(error)
            }
        }
    }
    
    typealias
        Point = EasyPoint
    func
        dispatch(_ seed :EasyPointMatchable & EasyPayloadCarrier) throws {
        
        // Find point
        //
        let
        points :[EasyPayloadNode]! = root.points(match: seed)
        guard points.count > 0 else {
            throw MatchingError.noMatchingPoint(
                class: String(describing: seed.cls),
                method: seed.method
            )
        }
        guard points.count <= 1 else {
            throw MatchingError.tooManyMatchingPoints(count: points.count)
        }
        guard let point = points?.first else { return }
        
        // Dispatch the event with point to every tracker tracks the point
        //
        let merged = try point.mergedFromRoot()
        guard
            let trackers = merged.trackers,
            trackers.count > 0
            else { throw ConfigurationError.noAvailableTrackers }
        let
        event = try EasyEvent(seed: seed, point: merged)
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
    
