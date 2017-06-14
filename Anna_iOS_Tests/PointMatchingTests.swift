//
//  PointMatchingTests.swift
//  Anna
//
//  Created by William on 10/05/2017.
//
//

import XCTest
import Anna

class PointMatchingTests: AnnaTestCase {
    
    func
        test_pointUserInfo() {
        class
        Object : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalysisPoints(with registrar :EasyRegistrant.Registrar) {
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
        
        let
        point = receivedPoints.last!,
        payload = point.payload as? Dictionary<String, Any>
        XCTAssertEqual(payload?["data"] as? String, "42")
    }
    
    func test_missmatch() {
        
    }
    
    func test_twoPointsContainedInOneMethod() {
        class
        Object : Analyzable {
            func
                functionContainsTwoPoints(index :Int) {
                self.ana.event{ $0.set("index", index) }.analyze()
            }
            override class func
                registerAnalysisPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .method("functionContainsTwoPoints(index:)")
                        .point { $0
                            .when("index", equal: 0)
                            .set("data", "42")
                        }
                        .point { $0
                            .when("index", equal: 1)
                            .set("data", "42")
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
        
        let
        payload0 = receivedPoints[0].payload as? Dictionary<String, Any>
        XCTAssertEqual(payload0?["data"] as? String, "42")
        let
        payload1 = receivedPoints[1].payload as? Dictionary<String, Any>
        XCTAssertEqual(payload1?["data"] as? String, "24")
    }
}

// TODO 
// test custom prefix anat
// .fucntion leverage String Literal
// super selector

//extension Anna.Analyzable {
//    var anat :Anna.InvocationContext {
//        return self.ana
//    }
//}
