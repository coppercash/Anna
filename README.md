


# Anna

[ ![Language](https://img.shields.io/badge/language-%20Swift%20-green.svg)](#)

Anna is an analytics abstraction library which helps separate the analyzing part of code from the main business logic.
Although inspired by AOP, Anna doesn't require method-swizzling, which consumes considerable runtime. Instead, it needs a tiny piece of code to be inserted into the analyzed method. And then all the magic starts.

## How to Use

### The Most Basic

There are three roles in Anna:
    
+ The **Analyzable Object**, which conforms the protocol `Analyzable`. It registers all the **points** related to the class and calls `self.ana.analyze()` in the methods which the **points** register with.
+ The **Tracker**, which conforms the protocol `Tracker`.  It receives **events** or error dispatched by the **manager**.
+ The **Manager** works as a bridge between **Analyzable Object** and **Tracker**. Most of the time, we don't need to touch it, unless there is some configuration to be done.

```swift
class Object : NSObject, Anna.Analyzable {
    func call() {
	    // pull the trigger
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

class Tracker : Anna.Tracker {
    public func receive(
        analyticsEvent event: Event,
        dispatchedBy manager: Manager
        ) {
        // Record the event or anything else with it
    }
    public func receive(
        analyticsError error: Error,
        dispatchedBy manager: Manager
        ) {
        // Deal with the error
    }
}

// Configure the tracker to be default
let tracker = Tracker()
Anna.Manager.shared.trackers.defaults = [tracker]

// Given the points registered, this call will trigger an event sent to the configured tracker
Object().call()
```

### Multiple Points in One Method

Sometimes, there are more than one points in one method. Then, we need to register the points recursively, in a tree-like way. And when calling `.analyze()`, we pass in some arguments to determine which point is wanted. When the method in **tacker** gets called, the `event` will contain all the properties set through the point tree path and the arguments passed in.

```swift
func call(with index :Int, name :String) {
    self.ana.event{ $0
        .set("index", index)
        .set("name", name)
        }.analyze()
}

override class func
    registerAnalyticsPoints(with registrar :EasyRegistrant.Registrar) {
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

// The event we finally get will contain "index", "name", "first-level" and "second-level"
```