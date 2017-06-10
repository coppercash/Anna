//
//  MethodPointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

class EasyMethodPointSet {
    
    init(points :[Point]) {
        self.points = points
    }
    
    typealias
        Point = EasyPoint
    let points :[Point]
    typealias
        Event = EasyEvent
    func points(match event :Event) ->[Point] {
        var points = [Point]()
        for point in self.points {
            guard point.matches(event) else { continue }
            points.append(point)
        }
        return points
    }
}
