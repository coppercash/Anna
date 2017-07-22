//
//  TrackerTests.swift
//  Anna
//
//  Created by William on 24/06/2017.
//
//

import XCTest
import Anna

class TrackerTests: AnnaTestCase {
    
    func test_appendTracker() {
        class
        Object : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :Registering.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                        .tracker($0.trackers["second"]!)
                }
            }
        }
        
        let appended = ClosureTracker()
        appended.append(expectation(description: "AnotherExpectation"))
        manager.trackers["second"] = appended
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
        XCTAssertNotNil(appended.receivedEvents.last)
        XCTAssertNil(appended.receivedErrors.last)
    }
    
    func
        test_overrideTrackers() {
        class
        Object : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :Registering.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                        .trackers([$0.trackers["second"]!])
                }
            }
        }
        
        let appended = ClosureTracker()
        appended.append(expectation(description: "AnotherExpectation"))
        manager.trackers["second"] = appended
        
        waitForEvents(of: 0) {
            Object(manager).call()
        }
        
        XCTAssertNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
        XCTAssertNotNil(appended.receivedEvents.last)
        XCTAssertNil(appended.receivedErrors.last)
    }
}
