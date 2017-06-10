//
//  MethodPointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
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
            guard point.matches(event) else { continue }
            points.append(point)
        }
        return points
    }
}
