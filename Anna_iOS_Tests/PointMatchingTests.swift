//
//  PointMatchingTests.swift
//  Anna
//
//  Created by William on 10/05/2017.
//
//

import XCTest
import Anna

class
PointMatchingTests: AnnaTestCase {
    
    func
        test_pointUserInfo() {
        class
        Object : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                        .set("data", "42")
                }
            }
        }
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertEqual(receivedEvents.last?["data"] as? String, "42")
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_twoPointsContainedInOneMethod() {
        class
        Object : ANATAnalyzable, Analyzable {
            func
                functionContainsTwoPoints(index :Int) {
                self.ana.event{ $0.set("index", index) }.analyze()
            }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .point { $0
                        .method("functionContainsTwoPoints(index:)")
                        .point { $0
                            .when("index", equal: 0)
                            .set("data", "42")
                        }
                        .point { $0
                            .when("index", equal: 1)
                            .set("data", "24")
                        }
                }
            }
        }
        
        waitForEvents(of: 2) { 
            let
            object = Object(manager)
            object.functionContainsTwoPoints(index: 0)
            object.functionContainsTwoPoints(index: 1)
        }
        
        XCTAssertEqual(receivedEvents[0]["data"] as? String, "42")
        XCTAssertEqual(receivedEvents[1]["data"] as? String, "24")
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_threePointsContainedInOneMethod() {
        class
        Object : ANATAnalyzableObjC, Analyzable {
            func call(with index :Int, name :String) {
                self.ana.event{ $0
                    .set("index", index)
                    .set("name", name)
                    }.analyze()
            }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(call(with:name:)))
                        .point { $0
                            .when("index", equal: 0)
                            .set("first-level", "42")
                            .point { $0
                                .when("name", equal: "Tom")
                                .set("second-level", 42)
                            }
                            .point { $0
                                .when("name", equal: "Jerry")
                                .set("second-level", 24)
                            }
                        }
                        .point { $0
                            .when("index", equal: 1)
                            .set("first-level", "24")
                        }
                }
            }
        }
        
        waitForEvents(of: 3) {
            let
            object = Object(manager)
            object.call(with: 0, name: "Tom")
            object.call(with: 0, name: "Jerry")
            object.call(with: 1, name: "Jimmy")
        }
        
        XCTAssertEqual(receivedEvents[0]["first-level"] as? String, "42")
        XCTAssertEqual(receivedEvents[0]["second-level"] as? Int, 42)
        XCTAssertEqual(receivedEvents[1]["first-level"] as? String, "42")
        XCTAssertEqual(receivedEvents[1]["second-level"] as? Int, 24)
        XCTAssertEqual(receivedEvents[2]["first-level"] as? String, "24")
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_throwErrorForMissingMatching() {
        class
        Object : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .point { $0
                        .method("whatever")
                }
            }
        }
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertEqual(
            receivedErrors.last as? MatchingError,
            MatchingError.noMatchingPoint(
                class: String(describing: Object.self),
                method: "call()"
            )
        )
    }
    
    func
        test_throwErrorForEmptyRegistration() {
        class
        Object : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :Registrar) {
            }
        }
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertNotNil(receivedErrors.last)
    }
}
