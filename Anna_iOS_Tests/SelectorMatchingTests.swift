//
//  FunctionMatchingTests.swift
//  Anna
//
//  Created by William on 17/06/2017.
//
//

import XCTest
import Anna

class
SelectorMatchingTests : AnnaTestCase {
    
    func
        test_withoutParameter() {
        class
        Object : AnalyzableObjC {
            @objc func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        // call
                        //
                        .selector(#selector(Object.call))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call()
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }

    func
        test_firstParameterWith() {
        class
        Object : AnalyzableObjC {
            @objc func
                call(with number :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(Object.call(with:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call(with: 24)
        }
       
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_firstParameterPreposition() {
        class
        Object : AnalyzableObjC {
            @objc func
                call(at index :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(Object.call(at:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call(at: 24)
        }
       
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_firstParameterPrepositionNoun() {
        class
        Object : AnalyzableObjC {
            @objc func
                go(to bed :String) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(go(to:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).go(to: "bed")
        }
       
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_methodNamePrepositionNoun_firstNamePrepositionNoun() {
        class
        Object : AnalyzableObjC {
            @objc func
                goToBed(at time :String) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(goToBed(at:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).goToBed(at: "night")
        }
       
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_firstParameterNoun() {
        class
        Object : AnalyzableObjC {
            @objc func
                call(phoneNumber number :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(Object.call(phoneNumber:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call(phoneNumber: 24)
        }
       
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_methodNameVerdNoun_firstParameterPrepositionNoun() {
        class
        Object : AnalyzableObjC {
            @objc func
                selectRow(at index :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(selectRow(at:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).selectRow(at: 0)
        }
       
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_secondParameterVerbPreposition() {
        class
        Object : AnalyzableObjC {
            func
                view(_ view: UIView, didTapAreaAround point: CGPoint) {
                self.ana.analyze()
            }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(view(_:didTapAreaAround:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).view(UIView(), didTapAreaAround: CGPoint.zero)
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_secondParameterVerbPrepositionNounPrepositionNoun() {
        class
        Object : AnalyzableObjC, UITableViewDelegate {
            func
                tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                self.ana.analyze()
            }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(tableView(_:didSelectRowAt:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).tableView(UITableView(), didSelectRowAt: IndexPath())
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_oneOmittedParameterLabel() {
        class
        Object : AnalyzableObjC {
            func
                call(_ string :String) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(call(_:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call("42")
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_twoOmittedParameterLabels() {
        class
        Object : AnalyzableObjC {
            func
                call(_ string :String, _ number :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(call(_:_:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call("42", 24)
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_omittingOneParameterAmongTwo() {
        class
        Object : AnalyzableObjC {
            func
                call(_ string :String, number :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(call(_:number:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call("42", number: 24)
        }
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_unableToMatchCustomObjCSelector() {
        class
        Object : AnalyzableObjC {
            @objc(call:) func
                call(parameterA argumentA :Int) { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(Object.call(parameterA:)))
                }
            }
        }
        
        waitForEvents {
            Object(manager).call(parameterA: 24)
        }
        
        XCTAssertNil(receivedEvents.last)
        XCTAssertNotNil(receivedErrors.last)
    }
    
    func
        test_getter() {
        class
        Object : AnalyzableObjC {
            var
            property :String {
                self.ana.analyze()
                return "42"
            }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(getter: property))
                }
            }
        }
        
        waitForEvents {
            let _ = Object(manager).property
        }
        
        XCTAssertNil(receivedEvents.last)
        XCTAssertNotNil(receivedErrors.last)
    }
    
    func
        test_setter() {
        class
        Object : AnalyzableObjC {
            var
            property :String {
                get {
                    return "42"
                }
                set {
                    self.ana.analyze()
                }
            }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
                        .selector(#selector(setter: property))
                }
            }
        }
        
        waitForEvents {
            Object(manager).property = "24"
        }
        
        XCTAssertNil(receivedEvents.last)
        XCTAssertNotNil(receivedErrors.last)
    }
}
