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
    
    typealias Points = ArrayBuilder<Point>
    @discardableResult
    func point(_ building :PointBuilding) ->Self {
        let points = buffer.get("points", Points())
        points.add(building)
        return self
    }
    
    func pointSet() throws ->ClassPointSet {
        guard
            let points = buffer["points"] as? ArrayBuilder<Point>
            else {
                throw BuilderError.missingProperty
        }
        
        var pointsByMethod = [String:[Point]]()
        for point :PointBuilder in points.elements() {
            guard let method = point["method"] as? String else { continue }
            if pointsByMethod[method] == nil {
                pointsByMethod[method] = [Point]()
            }
            pointsByMethod[method]!.append(try point.point())
        }
        
        var pointSets = [String:MethodPointSet]()
        for (method, points) in pointsByMethod {
            pointSets[method] = MethodPointSet(points: points) 
        }
        
        return ClassPointSet(pointSetsByMethod: pointSets)
    }
}

public class PointBuilder {
    
    let buffer = DictionaryBuilder<String, Any>()
    
    required
    public init() {}
    
    @discardableResult
    func method(_ name :String) ->Self {
        buffer.set(#function, name)
        return self
    }
    
    @discardableResult
    func set(_ key :String, _ value :Any) ->Self {
        buffer.set(key, value)
        return self
    }
    
    subscript(key :String) ->Any? {
        return buffer[key]
    }
    
    func point() throws ->Point {
        let dictionary = try buffer.build()
        guard
            let cls = dictionary["class"] as? String,
            let method = dictionary["method"] as? String
            else { throw BuilderError.missingProperty }
        return Point(class: cls, method: method)
    }
}

extension PointBuilder : Builder {
    typealias Result = Point
    func build() throws -> Point { return try point() }
    func _build() throws -> Any { return try build() }
}

typealias PointBuilding = (PointBuilder)->Void
