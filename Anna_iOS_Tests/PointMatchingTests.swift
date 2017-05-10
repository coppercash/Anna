//
//  PointMatchingTests.swift
//  Anna
//
//  Created by William on 10/05/2017.
//
//

import XCTest
@testable import Anna

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
                .method("functionOne")
                .set("data", "function_one_point_data")
        }
    }
}

class Tracker : Anna.Tracker {
    var lastPoint :Anna.Point? = nil
    var lastEvent :Anna.Event? = nil
    func receive(event: Anna.Event, with point: Anna.Point, dispatchedBy manager: Anna.Manager) {
        self.lastPoint = point
        self.lastEvent = event
    }
}

class Manager : Anna.Manager {
    let defaultTracker :Tracker
    init(defaultTracker :Tracker) {
        self.defaultTracker = defaultTracker
    }
}

class PointMatchingTests: XCTestCase {
    
    func test_pointUserInfo() {
        let tracker = Tracker()
        let manager = Manager(defaultTracker: tracker)
        let target = Target(analyzer: manager)
        target.functionOne()
        let lastPoint = tracker.lastPoint
        XCTAssertEqual(lastPoint?.payload as? String, "function_one_point_data")
    }
}

// TODO 
// .fucntion leverage String Literal
// super selector
