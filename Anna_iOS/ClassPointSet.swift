//
//  ClassPointSet.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

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

class ClassPointSetBuilder {

    typealias Buffer = DictionaryBuilder<String, Any>
    let buffer = Buffer()
    
    required
    init() {}
    
    typealias Points = ArrayBuilder<Point>
    @discardableResult
    func point(_ building :PointBuilding) ->Self {
        let points = buffer.get("points", Points())
        points.add(building)
        return self
    }
    
    func pointSet() throws ->ClassPointSet {
        let
        points :ArrayBuilder<Point> = try requiredProperty(
            from: self,
            for: "points"
        )
        
        var
        pointsByMethod = [String:[Point]]()
        for point :PointBuilder in points.elements() {
            let
            method :String = try requiredProperty(
                from: point,
                for: "method",
                propertyPrefix: "points"
            )
            point["defaults"] = self["pointDefaults"]
            let
            builtPoint = try point.point()
            
            if pointsByMethod[method] == nil { pointsByMethod[method] = [Point]() }
            pointsByMethod[method]!.append(builtPoint)
        }
        
        var pointSets = [String:MethodPointSet]()
        for (method, points) in pointsByMethod {
            pointSets[method] = MethodPointSet(points: points) 
        }
        
        return ClassPointSet(pointSetsByMethod: pointSets)
    }
}
