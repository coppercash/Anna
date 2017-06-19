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
FunctionMatchingTests : AnnaTestCase {
    
    func
        test_selectorWithoutParameter() {
        class
        Object : AnalyzableObjC {
            @objc func
                call() { self.ana.analyze() }
            override class func
                registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
                registrar
                    .point { $0
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
        test_selectorStartsWithWith() {
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
        test_selectorTakeObjectAsFirstParameter() {
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
        test_selectorStartsWithOtherPreposition() {
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
        test_selectorWithOneParameter() {
        class
        Object : AnalyzableObjC {
            @objc func
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
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
    
    func
        test_selectorWithTwoParamters() {
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
        test_selectorWithOneOmittedParameterLabel() {
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
        test_selectorWithTwoOmittedParameterLabels() {
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
        test_selectorOmittingOneParameterAmongTwo() {
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
        test_commonlySeenUIKitSelector() {
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
        off_test_matchingObjCSelectorWithOneParameter() {
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
        
        XCTAssertNotNil(receivedEvents.last)
        XCTAssertNil(receivedErrors.last)
    }
}
