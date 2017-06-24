//
//  ConvenienceTests.swift
//  Anna
//
//  Created by William on 24/06/2017.
//
//

import XCTest
import Anna

class ConvenienceTests: XCTestCase {
    
    func test_convenience() {
        class
        Object : NSObject, Anna.Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(call))
                        .set("theAnswer", 42)
                }
            }
        }
        
        class
        Tracker : Anna.Tracker {
            var
            event :Event? = nil
            var
            eventExpectation :XCTestExpectation? = nil
            public func
                receive(analyticsError error: Error, dispatchedBy manager: Manager) {
            }
            
            public func
                receive(analyticsEvent event: Event, dispatchedBy manager: Manager) {
                self.event = event
                eventExpectation?.fulfill()
            }
        }
        
        let
        tracker = Tracker()
        tracker.eventExpectation = expectation(description: "")
        Anna.Manager.shared.trackers.defaults = [tracker]
        
        Object().call()
        
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(tracker.event?["theAnswer"] as? Int, 42)
    }
}
