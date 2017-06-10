//
//  AnnaTestCase.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import XCTest
import Anna

class
AnnaTestCase : XCTestCase {
    var
    manager :Anna.Manager! = nil,
    expectations :[XCTestExpectation]! = nil,
    receivedPoints :[Anna.Point]! = nil,
    receivedEvents :[Anna.Event]! = nil
    override func
        setUp() {
        super.setUp()
        receivedEvents = Array<Anna.Event>()
        receivedPoints = Array<Anna.Point>()
        expectations = [XCTestExpectation]()
        manager = Anna.Manager()
        manager.defaultsProvider = self
    }
    override func
        tearDown() {
        manager = nil
        expectations = nil
        receivedPoints = nil
        receivedEvents = nil
        super.tearDown()
    }
    
    func
        waitForEvents(of count :Int = 1, execution :()->Void) {
        for index in 0..<count {
            expectations.append(
                expectation(description: "Expectation for Event \(index)")
            )
        }
        execution()
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}

extension
AnnaTestCase : Anna.DefaultsProvider {
    public var
    point: Anna.PointDefaults? {
        return Point(
            trackers: [self],
            predicates: nil,
            payload: nil
        )
    }
}

extension
AnnaTestCase : Anna.Tracker {
    func
        receive(
        event: Anna.Event,
        with point: Anna.Point,
        dispatchedBy manager: Anna.Manager
        ) {
        receivedEvents.append(event)
        receivedPoints.append(point)
        expectations.removeLast().fulfill()
    }
}

class
Analyzable : Anna.Analyzable {
    let
    analyzer :Anna.Manager
    init(_ analyzer :Anna.Manager) {
        self.analyzer = analyzer
    }
    var
    analysisManager: Anna.Manager {
        return self.analyzer
    }
    class func
        registerPoints(with registrar :Registrar) {}
}

