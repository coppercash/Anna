//
//  ClosureTracker.swift
//  Anna
//
//  Created by William on 24/06/2017.
//
//

import XCTest
import Anna

class
ClosureTracker : Tracking {
    typealias
        Event = Anna.EventBeing
    var
    receivedEvents = [Event]()
    var
    receivedErrors = [Error]()
    var
    expectations = [XCTestExpectation]()
    
    typealias
        Closure = (Event?, Error?)->Void
    let
    closure :Closure?
    init(closure : Closure? = nil) {
        self.closure = closure
    }
    
    func
        receive(
        analyticsEvent event: Tracking.Event,
        dispatchedBy manager: Tracking.Manager
        ) {
        receivedEvents.append(event)
        if let closure = self.closure {
            closure(event, nil)
        }
        expectations.removeLast().fulfill()
    }
    func
        receive(
        analyticsError error: Error,
        dispatchedBy manager: Tracking.Manager) {
        receivedErrors.append(error)
        if let closure = self.closure {
            closure(nil, error)
        }
        expectations.removeLast().fulfill()
    }
    
    func append(_ expectation :XCTestExpectation) {
        expectations.append(expectation)
    }
}
