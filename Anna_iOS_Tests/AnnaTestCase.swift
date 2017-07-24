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
        Manager = Anna.EasyManager
    var
    manager :Manager! = nil,
    expectations :[XCTestExpectation]! = nil,
    receivedEvents :[Manager.Event]! = nil,
    receivedErrors :[Error]! = nil
    override func
        setUp() {
        super.setUp()
        receivedEvents = Array<Manager.Event>()
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
AnnaTestCase : Anna.EasyTracking {
    func
        receive(
        analyticsEvent event: Event,
        dispatchedBy manager: Manager
        ) {
        receivedEvents.append(event)
        expectations.removeLast().fulfill()
    }
    func
        receive(
        analyticsError error: Error,
        dispatchedBy manager: Manager) {
        receivedErrors.append(error)
        expectations.removeLast().fulfill()
    }
}

class
ANATAnalyzable {
    typealias
        Analyzer = Anna.EasyManager
    let
    analyzer :Analyzer
    init(_ analyzer :Analyzer) {
        self.analyzer = analyzer
    }
    var
    analyticsManager: Analyzer {
        return self.analyzer
    }
}

class
ANATAnalyzableObjC : NSObject {
    typealias
        Analyzer = Anna.EasyManager
    let
    analyzer :Analyzer
    init(_ analyzer :Analyzer) {
        self.analyzer = analyzer
    }
    var
    analyticsManager: Analyzer {
        return self.analyzer
    }
}
