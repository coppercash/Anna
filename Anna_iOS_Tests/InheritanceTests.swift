//
//  InheritanceTests.swift
//  Anna
//
//  Created by William on 24/06/2017.
//
//

import XCTest
import Anna

class
InheritanceTests: AnnaTestCase {
    
    func
        test_inheritsMethodFromSuper() {
        class
        Parent : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                }
            }
        }
        class
        Child : Parent {
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                super.registerAnalyticsPoints(with: registrar)
            }
        }
        
        waitForEvents {
            Child(manager).call()
        }
        
        XCTAssertNotNil(receivedEvents.last)
    }
    
    func
        test_inheritsMethodFromSuperWithouthRegistering() {
        class
        Parent : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                }
            }
        }
        class
        Child : Parent {}
        
        waitForEvents {
            Child(manager).call()
        }
        
        XCTAssertNotNil(receivedEvents.last)
    }
    
    func
        test_pointNotRegisterredBySuper() {
        class
        Parent : Analyzable {
            func
                call() { self.ana.analyze() }
        }
        class
        Child : Parent {
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                super.registerAnalyticsPoints(with: registrar)
                registrar
                    .point { $0
                        .method("call()")
                }
            }
        }
        
        waitForEvents {
            Child(manager).call()
        }
        
        XCTAssertNotNil(receivedEvents.last)
    }
    
    func
        test_overriedsPointRegisterredBySuper() {
        class
        Parent : Analyzable {
            func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                        .set("name", "Parent")
                }
            }
        }
        class
        Child : Parent {
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                super.registerAnalyticsPoints(with: registrar)
                registrar
                    .point { $0
                        .method("call()")
                        .set("name", "Child")
                }
            }
        }
        
        waitForEvents {
            Child(manager).call()
        }
        
        XCTAssertEqual(receivedEvents.last?["name"] as? String, "Child")
    }
}