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
    
    class func registerPoints(with registrar :Registrar) {
        registrar
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
        return Point(trackers:[self.defaultTracker], payload: nil)
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
}

// TODO 
// .fucntion leverage String Literal
// super selector
