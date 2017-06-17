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
    
    public typealias
        DefaultsProvider = EasyDefaultsProvider
    public weak var
    defaultsProvider :DefaultsProvider? = nil
    
    public
    init(root :Root) {
        self.root = root
    }
    
    public typealias
        Event = EasyEvent
    func receive(_ event :Event) {
        queue.async {
            try! self.dispatch(event)
        }
    }
    
    public typealias
        Point = EasyPoint
    func dispatch(_ event :Event) throws {
        // Try to load points if they have not been loaded
        //
        try loadPoints(for: event.cls)
        
        // Find point
        //
        let points :[Point]! = self.root.points(match: event)
        assert(
            points != nil && points.count == 1,
            "Exactly one point is expected to be matched, " +
            "but found \(points.count). \n\(points)"
        )
        
        guard
            let point = points?.first
            else { return }
        
        // Dispatch the event with point to every tracker tracks the point
        //
        let merged = try point.mergedToRoot()
        guard
            let trackers = merged.trackers
            else {
                // TODO: throw
                return
        }
        for tracker in trackers {
            tracker.receiveAnalysisEvent(
                event,
                with: merged,
                dispatchedBy: self
            )
        }
    }
    
    typealias
        Registrant = EasyRegistrant
    typealias
        ClassPointBuilder = EasyClassPointBuilder
    func loadPoints(for cls :Registrant.Type) throws {
        guard
            root.classPoint(for: cls) == nil
            else { return }
        
        let
        builder = ClassPointBuilder()
        cls.registerAnalysisPoints(with: builder)
        let
        point = try builder.point()
        root.setClassPoint(point, for: cls)
    }
}

extension
EasyClassPointBuilder : EasyRegistrar {}

public typealias
    EasyPointDefaults = EasyPoint
public protocol
EasyDefaultsProvider : class {
    typealias
        PointDefaults = EasyPointDefaults 
    var point :PointDefaults? { get }
}

public protocol
EasyAnalyzable : EasySender, EasyRegistrant {}
