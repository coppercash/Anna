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
    
    typealias
        PointSet = EasyPointSet
    let
    points :PointSet = PointSet()
    
    let
    queue :DispatchQueue = DispatchQueue(label: "Anna")
    
    public typealias
        DefaultsProvider = EasyDefaultsProvider
    public weak var
    defaultsProvider :DefaultsProvider? = nil
    
    public
    init() {}
    
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
        let points :[Point]! = self.points.points(match: event)
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
        for tracker in point.trackers {
            tracker.receiveAnalysisEvent(
                event,
                with: point,
                dispatchedBy: self
            )
        }
    }
    
    typealias
        Registrant = EasyRegistrant
    typealias
        ClassPointSetBuilder = EasyClassPointSetBuilder
    typealias
        ClassPointSet = EasyClassPointSet
    func loadPoints(for cls :Registrant.Type) throws {
        let name :String
        let registrar :ClassPointSetBuilder
        let pointSet :ClassPointSet
        var current :ClassPointSet!
        
        name = String(describing: cls)
        guard
            points.pointSet(for: name) == nil
            else { return }
        
        registrar = ClassPointSetBuilder()
        registrar["pointDefaults"] = defaultsProvider?.point
        cls.registerAnalysisPoints(with: registrar)
        pointSet = try registrar.pointSet()
        
        current = pointSet
        while current != nil {
            points.set(pointSet, for: name)
            current = current.superClassPointSet
        }
    }
    
}
extension EasyClassPointSetBuilder : EasyRegistrar {}

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
