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
    receivedEvents :[Manager.Event]! = nil
    override func
        setUp() {
        super.setUp()
        receivedEvents = Array<Manager.Event>()
        expectations = [XCTestExpectation]()
        manager = Manager(config: self)
    }
    override func
        tearDown() {
        manager = nil
        expectations = nil
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
AnnaTestCase : Anna.EasyConfiguration, Anna.EasyPointDefaults {
    public var
    pointDefaults: EasyConfiguration.PointDefaults {
        return self
    }
    var payload: EasyPointDefaults.Payload? {
        return nil
    }
    var trackers: [EasyPointDefaults.Tracker] {
        return [self]
    }
}

extension
AnnaTestCase : EasyTracker {
    func
        receiveAnalyticsEvent(
        _ event: EasyTracker.Event,
        dispatchedBy manager: EasyTracker.Manager
        ) {
        receivedEvents.append(event)
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
    analysisManager: EasyAnalyzable.Manager {
        return self.analyzer
    }
    class func
        registerAnalysisPoints(with registrar :EasyRegistrant.Registrar) {}
}

