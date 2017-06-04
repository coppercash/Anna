//
//  Builder.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

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
        guard let
            points = self["points"] as? ArrayBuilder<Point>
            else {
                throw BuilderError.missedProperty(
                    name: "points",
                    result: String(describing: Result.self)
                )
        }
        
        var
        pointsByMethod = [String:[Point]]()
        for point :PointBuilder in points.elements() {
            guard let
                method = point["method"] as? String
                else {
                    throw BuilderError.missedProperty(
                        name: "points.method",
                        result: String(describing: Result.self)
                    )
            }
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

extension
ClassPointSetBuilder {
    subscript(key :String) ->Any? {
        get { return self.buffer[key] }
        set { self.buffer[key] = newValue }
    }
}

extension
ClassPointSetBuilder : Builder {
    typealias Result = ClassPointSet
    func build() throws -> ClassPointSet { return try pointSet() }
    func _build() throws -> Any { return try build() }
}

