//
//  PointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

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
class EasyPointSet {
    typealias
        Event = EasyEvent
    typealias
        Point = EasyPoint
    typealias
        ClassPointSet = EasyClassPointSet
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
