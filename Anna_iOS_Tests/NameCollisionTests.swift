//
//  NameCollisionTests.swift
//  Anna
//
//  Created by William on 24/06/2017.
//
//

import XCTest
import Anna

class
NameCollisionTests: AnnaTestCase {
    
    func
        test_customPrefix() {
        class
        Object : ANATAnalyzable {
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
}

extension
ANATAnalyzable {
    var
    custom :EasyAnalyzable.Prefix {
        return self.ana
    }
}
