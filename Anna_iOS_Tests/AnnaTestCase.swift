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
    typealias
        Manager = EasyManager
    var
    manager :Manager! = nil,
    expectations :[XCTestExpectation]! = nil,
    receivedPoints :[Manager.Point]! = nil,
    receivedEvents :[Manager.Event]! = nil
    override func
        setUp() {
        super.setUp()
        receivedEvents = Array<Manager.Event>()
        receivedPoints = Array<Manager.Point>()
        expectations = [XCTestExpectation]()
        manager = Manager()
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
AnnaTestCase : Anna.EasyDefaultsProvider {
    public var
    point: Anna.EasyDefaultsProvider.PointDefaults? {
        return EasyPointDefaults(
            trackers: [self],
            predicates: nil,
            payload: nil
        )
    }
}

extension
AnnaTestCase : EasyTracker {
    func
        receiveAnalysisEvent(
        _ event: EasyTracker.Event,
        with point: EasyTracker.Point,
        dispatchedBy manager: EasyTracker.Manager
        ) {
        receivedEvents.append(event)
        receivedPoints.append(point)
        expectations.removeLast().fulfill()
    }
}

class
Analyzable : EasyAnalyzable {
    typealias
        Analyzer = EasyManager
    let
    analyzer :Analyzer
    init(_ analyzer :Analyzer) {
        self.analyzer = analyzer
    }
    var
    analysisManager: EasySender.Manager {
        return self.analyzer
    }
    class func
        registerAnalysisPoints(with registrar :EasyRegistrant.Registrar) {}
}

