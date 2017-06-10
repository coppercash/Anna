//
//  ClassPointSet.swift
//  Anna
//
//  Created by William on 05/06/2017.
//
//

import Foundation

class
EasyClassPointSet {
    
    let superClassPointSet :EasyClassPointSet? = nil
    
    typealias
        MethodPointSet = EasyMethodPointSet
    init(pointSetsByMethod :[String:MethodPointSet]) {
        self.pointSetsByMethod = pointSetsByMethod
    }
    
    typealias
        Event = EasyEvent
    typealias
        Point = EasyPoint
    func points(match event :Event) ->[Point]? {
        return pointSet(for: event.method)?.points(match: event)
    }
    
    let pointSetsByMethod :[String:MethodPointSet]
    func pointSet(for method :String) ->MethodPointSet? {
       return pointSetsByMethod[method]
    }
}

class
EasyClassPointSetBuilder {

    typealias
        Buffer = DictionaryBuilder<String, Any>
    let
    buffer = Buffer()
    
    required
    init() {}
    
    typealias
        Point = EasyPoint
    typealias
        PointBuilder = EasyPointBuilder
    typealias
        Points = ArrayBuilder<Point>
    @discardableResult
    func point(_ building :PointBuilder.Buildup) ->Self {
        let points = buffer.get("points", Points())
        points.add(building)
        return self
    }
    
    typealias
        ClassPointSet = EasyClassPointSet
    typealias
        MethodPointSet = EasyMethodPointSet
    func pointSet() throws ->ClassPointSet {
        let
        points :Points = try requiredProperty(
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


extension
EasyClassPointSetBuilder : StringAnySubscriptable {
    subscript(key :String) ->Any? {
        get { return self.buffer[key] }
        set { self.buffer[key] = newValue }
    }
}

extension
EasyClassPointSetBuilder : Builder {
    typealias Result = ClassPointSet
    func build() throws -> ClassPointSet { return try pointSet() }
    func _build() throws -> Any { return try build() }
}

extension
EasyClassPointSetBuilder : StringAnyDictionaryBufferringBuilder {}


