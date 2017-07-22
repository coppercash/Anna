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
        Parent : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .point { $0
                        .method("call()")
                }
            }
        }
        class
        Child : Parent {
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .superClass(Parent.self)
            }
        }
        
        waitForEvents {
            Child(manager).call()
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_inheritsMethodFromSuperWithouthRegistering() {
        class
        Parent : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
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
                call() {}
        }
        class
        Child : Parent, Analyzable {
            override func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
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
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_overridesPointRegisterredBySuper() {
        class
        Parent : ANATAnalyzable, Analyzable {
            func
                call() { self.ana.analyze() }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
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
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
                registrar
                    .superClass(Parent.self)
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
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_KVObservedObjectBehavesAsNormalObject() {
        class
        Observable : ANATAnalyzableObjC, Analyzable {
            var property :String {
                self.ana.analyze()
                return "whatever"
            }
            class func
                registerAnalyticsPoints(with registrar :EasyRegistering.Registrar) {
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
