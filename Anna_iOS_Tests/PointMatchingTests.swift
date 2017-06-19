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
        Object : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
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
    }
    
    func
        test_twoPointsContainedInOneMethod() {
        class
        Object : Analyzable {
            func
                functionContainsTwoPoints(index :Int) {
                self.ana.event{ $0.set("index", index) }.analyze()
            }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
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
    }
    
    func
        test_missMatching() {
        class
        Object : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
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
            MatchingError.noMatchingPoint(class: String(describing: Object.self), method: "call()")
        )
    }
    
    func
        test_emptyClassPointError() {
        class
        Object : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
            }
        }
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertNotNil(receivedErrors.last)
    }
}

// TODO
// test custom prefix anat
// .fucntion leverage String Literal
// super selector
