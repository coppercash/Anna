//
//  Manager.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

public class Manager {
    let points :PointSet = PointSet()
    let queue :DispatchQueue = DispatchQueue(label: "Anna")
    
    func receive(_ event :Event) {
        queue.async {
            self.dispatch(event)
        }
    }
    
    func dispatch(_ event :Event) {
        // Try to load points if they have not been loaded
        //
        loadPoints(for: event.cls)
        
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
    
    func loadPoints(for cls :Registrant.Type) {
        let name = String(describing: type(of: cls))
        guard points.pointSet(for: name) == nil else { return }
        let registrar = ClassPointSetBuilder()
        let pointSet = try! registrar.pointSet()
        
        var current :ClassPointSet! = pointSet
        while current != nil {
            points.set(pointSet, for: name)
            current = current.superClassPointSet
        }
    }
    
    static let shared = Manager()
}

extension ClassPointSetBuilder : Registrar {}

protocol Analyzable : Registrant {
    var ana :InvocationContext { get }
}

extension Analyzable {
    var ana :InvocationContext {
        return InvocationContext(target: self)
    }
}

class InvocationContext {
    typealias Target = Analyzable
    let target :Target
    init(target :Target) {
        self.target = target
    }
    
    var event :Event? = nil
    func analyze(method :String = #function) {
        let event :Event! = self.event ??
            Event(class: type(of: target),
                  method: method)
        manager.receive(event)
    }
    
    var manager :Manager {
        return Manager.shared
    }
}

class Event {
    typealias Class = Registrant.Type
    let cls :Class
    
    typealias Method = String
    let method :String
    
    init(class cls :Class, method :Method) {
        self.cls = cls
        self.method = method
    }
    let payload :Any? = nil
}
