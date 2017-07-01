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
        Parent : ANATAnalyzable {
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
        Parent : ANATAnalyzable {
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
        Parent : ANATAnalyzable {
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
        Parent : ANATAnalyzable {
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
    
    func
        test_KVObservedObject() {
        class
        Observable : ANATAnalyzableObjC {
            var property :String {
                self.ana.analyze()
                return "whatever"
            }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .method(#keyPath(property))
                        .set("answer", "42")
                }
            }
        }
        
        waitForEvents {
            let
            object = Observable(manager)
            object.addObserver(
                self,
                forKeyPath: #keyPath(Observable.property),
                options: .new,
                context: nil
            )
            let _ = object.property
            object.removeObserver(
                self,
                forKeyPath: #keyPath(Observable.property)
            )
        }
        
        XCTAssertEqual(receivedEvents.last?["answer"] as? String, "42")
        XCTAssertNil(receivedErrors.last)
    }
}
