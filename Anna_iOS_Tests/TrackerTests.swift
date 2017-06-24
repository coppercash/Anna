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
        Object : ANATAnalyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
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
        XCTAssertNotNil(appended.receivedEvents.last)
    }
    
    /*
    func test_appendOverrideTrackers() {
        class
        Object : ANATAnalyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
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
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertNil(receivedEvents.last)
        XCTAssertNotNil(appended.receivedEvents.last)
    }
     */
}
