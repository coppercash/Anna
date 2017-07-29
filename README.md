
# Anna

[![Build Status](https://img.shields.io/travis/coppercash/Anna/master.svg)](https://travis-ci.org/coppercash/Anna)
[![codecov.io](https://codecov.io/gh/coppercash/Anna/branch/master/graphs/badge.svg)](https://codecov.io/github/coppercash/Anna)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Anna.svg)](https://cocoapods.org/pods/Anna)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/cocoapods/p/Anna.svg)
![License MIT](https://img.shields.io/cocoapods/l/Anna.svg)
![Language](https://img.shields.io/badge/language-Swift%20|%20ObjC-green.svg)

Anna is an analytics abstraction library which helps separate the analyzing part of code from the main business logic.
Although inspired by AOP, Anna doesn't require method-swizzling, which consumes considerable runtime. Instead, it needs a tiny piece of code to be inserted into the analyzed method. And then all the magic starts.

## How to Use

### The Most Basic

There are three roles in Anna:

+ The **Analyzable Object**, which conforms the protocol `EasyAnalyzable`. It registers all the **points** related to the class and calls `self.ana.analyze()` in the methods with which the **points** are registered.
+ The **Tracker**, which conforms the protocol `EasyTracking`.  It receives **events** or error dispatched by the **manager**.
+ The **Manager** (`EasyManager`) works as a bridge between **Analyzable Object** and **Tracker**. Most of the time, we don't need to touch it, unless there is some configuration to be done.

Swift | [ObjC](Docs/readme_objc.md)
```swift
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
```

### Multiple Points in One Method

Sometimes, there are more than one points in one method. Then, we need to register the points recursively, in a tree-like way. And when calling `.analyze()`, we pass in some arguments to determine which point is wanted. When the method in **tracker** gets called, the `event` will contain all the properties set through the point tree path and the arguments passed in.

Swift | [ObjC](Docs/readme_objc.md)
```swift
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

// With a call as following
Object().call(with: 0, name: "Jerry")

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
```
