//
//  SampleCodeTests.swift
//  Anna
//
//  Created by William on 22/07/2017.
//
//

import XCTest
import Anna

class SampleCodeTests: XCTestCase {
    
    func test_theMostBasic() {
        class Object : NSObject, EasyAnalyzable {
            func call() {
                // Pull the trigger
                self.ana.analyze()
            }
            class func registerAnalyticsPoints(
                with registrar :Registrar
                ) {
                // Register points related to the class
                registrar
                    .point { $0
                        .selector(#selector(call))
                        .set("theAnswer", 42)
                }
            }
        }
        
        class Tracker : EasyTracking {
            public func receive(
                analyticsEvent event: Event,
                dispatchedBy manager: Manager
                ) {
                print(event["theAnswer"] as! Int)   // 42
            }
            public func receive(
                analyticsError error: Error,
                dispatchedBy manager: Manager
                ) {
                print(error)
            }
        }
        
        // Configure the tracker to be default
        let tracker = Tracker()
        EasyManager.shared.trackers.defaults = [tracker]
        
        // Given the points registered, this call will trigger an event sent to the configured tracker
        let object = Object()
        object.call()
    }
    
    func test_multiplePointsInOneMethod() {
        
        class Object : NSObject, EasyAnalyzable {
            func call(with index :Int, name :String) {
                self.ana.event{ $0
                    .set("index", index)
                    .set("name", name)
                    }.analyze()
            }
            
            class func registerAnalyticsPoints(
                with registrar :Registrar
                ) {
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
        
        class Tracker : EasyTracking {
            // We can expect it in the tracker's delegate method
            public func receive(
                analyticsEvent event: Event,
                dispatchedBy manager: Manager
                ) {
                print(event["index"] as! Int)           // 0
                print(event["name"] as! String)         // Jerry
                print(event["first-level"] as! String)  // 42
                print(event["second-level"] as! Int)    // 24
            }
            public func receive(
                analyticsError error: Error,
                dispatchedBy manager: Manager
                ) {
            }
        }
        
        
        EasyManager.shared.trackers.defaults = [Tracker()]
        // With a call as following
        Object().call(with: 0, name: "Jerry")
    }
}
