//
//  PointMatchingTests.swift
//  Anna
//
//  Created by William on 10/05/2017.
//
//

import XCTest
import Anna

extension Analyzable {
    var anat :Anna.InvocationContext {
        return self.ana
    }
}

class Target : Anna.Analyzable {
    let analyzer :Anna.Manager
    init(analyzer :Anna.Manager) {
        self.analyzer = analyzer
    }
    
    func functionOne() {
        self.anat.analyze()
    }
    
    func functionContainsTwoPoints(index :Int) {
        self.anat.event{ $0.set("index", index) }.analyze()
    }
    
    class func registerPoints(with registrar :Registrar) {
        registrar
            .point { $0
                .method("functionContainsTwoPoints(index:)")
                .set("data", "function_contains_two_points_index_zero")
                .when("index", equal: 0)
            }
            .point { $0
                .method("functionContainsTwoPoints(index:)")
                .set("data", "function_contains_two_points_index_one")
                .when("index", equal: 1)
            }
            .point { $0
                .method("functionOne()")
                .set("data", "function_one_point_data")
        }
    }
    
    var analysisManager: Anna.Manager {
        return self.analyzer
    }
}

class Tracker : Anna.Tracker {
    typealias
    Receiving = (Anna.Event, Anna.Point)->Void
    let receiving :Receiving
    init(receiving : @escaping Receiving) {
        self.receiving = receiving
    }
    
    func
        receive(
        event: Anna.Event,
        with point: Anna.Point,
        dispatchedBy manager: Anna.Manager
        ) {
        receiving(event, point)
    }
}

class Manager : Anna.Manager, Anna.DefaultsProvider {
    let defaultTracker :Tracker
    init(defaultTracker :Tracker) {
        self.defaultTracker = defaultTracker
        super.init()
        self.defaultsProvider = self
    }
    
    public var point: Anna.PointDefaults? {
        return Point(trackers:[self.defaultTracker], predicates: nil, payload: nil)
    }
}

class PointMatchingTests: XCTestCase {
    
    func test_pointUserInfo() {
        let
        xpt = expectation(description: #function)
        var
        lastPoint :Point? = nil
        let tracker = Tracker { (event, point) in
            lastPoint = point
            xpt.fulfill()
        }
        let
        manager = Manager(defaultTracker: tracker)
        let
        target = Target(analyzer: manager)
        target.functionOne()
        
        waitForExpectations(timeout: 0.1)
        let
        payload = lastPoint?.payload as? Dictionary<String, Any>
        XCTAssertEqual(payload?["data"] as? String, "function_one_point_data")
    }
    
    func test_twoPointsContainedInOneMethod() {
        let
        xpt = expectation(description: #function)
        var
        points = [Point]()
        let tracker = Tracker { (event, point) in
            points.append(point)
            if points.count >= 2 { xpt.fulfill() }
        }
        let
        manager = Manager(defaultTracker: tracker)
        let
        target = Target(analyzer: manager)
        
        target.functionContainsTwoPoints(index: 0)
        target.functionContainsTwoPoints(index: 1)
        waitForExpectations(timeout: 0.1)
        
        let
        payload0 = points[0].payload as? Dictionary<String, Any>
        XCTAssertEqual(payload0?["data"] as? String, "function_contains_two_points_index_zero")
        let
        payload1 = points[1].payload as? Dictionary<String, Any>
        XCTAssertEqual(payload1?["data"] as? String, "function_contains_two_points_index_one")
    }
}

// TODO 
// .fucntion leverage String Literal
// super selector
