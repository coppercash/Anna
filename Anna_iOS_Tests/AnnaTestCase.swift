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
        Manager = Anna.Manager
    var
    manager :Manager! = nil,
    expectations :[XCTestExpectation]! = nil,
    receivedEvents :[Anna.EventBeing]! = nil,
    receivedErrors :[Error]! = nil
    override func
        setUp() {
        super.setUp()
        receivedEvents = Array<Anna.EventBeing>()
        receivedErrors =  Array<Error>()
        expectations = [XCTestExpectation]()
        manager = Manager()
        manager.trackers.defaults = [self]
    }
    override func
        tearDown() {
        manager = nil
        expectations = nil
        receivedErrors = nil
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
        waitForExpectations(timeout: 0.1) { (error) in }
    }
}

extension
AnnaTestCase : Tracking {
    func
        receive(
        analyticsEvent event: EasyTracking.Event,
        dispatchedBy manager: EasyTracking.Manager
        ) {
        receivedEvents.append(event)
        expectations.removeLast().fulfill()
    }
    func
        receive(
        analyticsError error: Error,
        dispatchedBy manager: EasyTracking.Manager) {
        receivedErrors.append(error)
        expectations.removeLast().fulfill()
    }
}

class
ANATAnalyzable {
    typealias
        Analyzer = EasyManager
    let
    analyzer :Analyzer
    init(_ analyzer :Analyzer) {
        self.analyzer = analyzer
    }
    var
    analyticsManager: EasyAnalyzable.Manager {
        return self.analyzer
    }
}

class
ANATAnalyzableObjC : NSObject {
    typealias
        Analyzer = EasyManager
    let
    analyzer :Analyzer
    init(_ analyzer :Analyzer) {
        self.analyzer = analyzer
    }
    var
    analyticsManager: EasyAnalyzable.Manager {
        return self.analyzer
    }
}
