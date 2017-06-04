//
//  ClassPointSet.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

class MethodPointSet {
    
    init(points :[Point]) {
        self.points = points
    }
    
    let points :[Point]
    func points(match event :Event) ->[Point] {
        var points = [Point]()
        for point in self.points {
            guard point.isMatched(with: event) else { continue }
            points.append(point)
        }
        return points
    }
}

class ClassPointSet {
    
    let superClassPointSet :ClassPointSet? = nil
    init(pointSetsByMethod :[String:MethodPointSet]) {
        self.pointSetsByMethod = pointSetsByMethod
    }
    
    func points(match event :Event) ->[Point]? {
        return pointSet(for: event.method)?.points(match: event)
    }
    
    let pointSetsByMethod :[String:MethodPointSet]
    func pointSet(for method :String) ->MethodPointSet? {
       return pointSetsByMethod[method]
    }
}

/*
 self.class | self.method | super.class | super.method | expected | search
 0            0             0             0              -
 0            0             0             1              -
 0            0             1             0              nothing
 0            0             1             1              in super   self, super
 0            1             0             0              -
 0            1             0             1              -
 0            1             1             0              -
 0            1             1             1              -
 1            0             0             0              nothing    self
 1            0             0             1              -
 1            0             1             0              nothing    self, super
 1            0             1             1              in super   self, super
 1            1             0             0              in self    self
 1            1             0             1              -
 1            1             1             0              in self    self
 1            1             1             1              in both    self, super
 */
class PointSet {
    func points(match event :Event) ->[Point]? {
        var current :ClassPointSet! = pointSet(for: String(describing: event.cls))
        guard current != nil else { return nil }
        var points = [Point]()
        while current != nil {
            if let matched = current.points(match: event) {
                points.append(contentsOf: matched)
            }
            current = current.superClassPointSet
        }
        return points
    }
    
    var pointSetsByClass :[String:ClassPointSet] = [String:ClassPointSet]()
    func pointSet(for cls :String) ->ClassPointSet? {
       return pointSetsByClass[cls]
    }
    func set(_ pointSet :ClassPointSet, for cls :String) {
        pointSetsByClass[cls] = pointSet
    }
}
