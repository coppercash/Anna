//
//  Manager.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

open class
Manager {
    let
    points :PointSet = PointSet(),
    queue :DispatchQueue = DispatchQueue(label: "Anna")
    public weak var
    defaultsProvider :DefaultsProvider? = nil
    
    public
    init() {}
    
    func receive(_ event :Event) {
        queue.async {
            try! self.dispatch(event)
        }
    }
    
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
            tracker.receive(event: event, with: point, dispatchedBy: self)
        }
    }
    
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
        cls.registerPoints(with: registrar)
        pointSet = try registrar.pointSet()
        
        current = pointSet
        while current != nil {
            points.set(pointSet, for: name)
            current = current.superClassPointSet
        }
    }
    
    static let shared = Manager()
}

public typealias
    PointDefaults = Point
public protocol
DefaultsProvider : class {
    var point :PointDefaults? { get }
}

extension ClassPointSetBuilder : Registrar {}

public protocol Analyzable : Registrant {
    var ana :InvocationContext { get }
    var analysisManager :Manager { get }
}

public extension Analyzable {
    var ana :InvocationContext {
        return InvocationContext(target: self)
    }
}

public class
InvocationContext {
    typealias
        Target = Analyzable
    let
    target :Target
    init(target :Target) {
        self.target = target
    }
    
    var
    event :EventBuilder? = nil
    public func
        event(building :EventBuilding) ->Self {
        let
        builder = EventBuilder()
        building(builder)
        event = builder
        return self
    }
    
    public func
        analyze(method :String = #function) {
        let
        event = self.event ?? EventBuilder()
        event["class"] = type(of: target)
        event["method"] = method
        manager.receive(try! event.event())
    }
    
    var manager :Manager {
        return target.analysisManager
    }
}
