
# Anna

![Language](https://img.shields.io/badge/language-Swift%20|%20ObjC-green.svg)

Anna is an analytics abstraction library which helps separate the analyzing part of code from the main business logic.
Although inspired by AOP, Anna doesn't require method-swizzling, which consumes considerable runtime. Instead, it needs a tiny piece of code to be inserted into the analyzed method. And then all the magic starts.

## How to Use

### The Most Basic

There are three roles in Anna:

+ The **Analyzable Object**, which conforms the protocol `ANAAnalyzable`. It registers all the **points** related to the class and calls `self.ana.analyze()` in the methods with which the **points** are registered.
+ The **Tracker**, which conforms the protocol `ANATracking`.  It receives **events** or error dispatched by the **manager**.
+ The **Manager** (`ANAManager`) works as a bridge between **Analyzable Object** and **Tracker**. Most of the time, we don't need to touch it, unless there is some configuration to be done.

[Swift](../README.md) | ObjC
```objective-c
@interface Object : NSObject <ANAAnalyzable>
- (void)call;
@end
@implementation Object

- (void)call {
    // Pull the trigger
    self.ana.analyze();
}

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {
    // Register points related to the class
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@selector(call))
        .set(@"theAnswer", @42)
        ;
    })
    ;
}

@end

@interface Tracker : NSObject <ANATracking>
@end
@implementation Tracker

- (void)receiveAnalyticsEvent:(id<ANAEventBeing>)event
                 dispatchedBy:(id<ANAManaging>)manager {
    NSLog(@"%@", event[@"theAnswer"]);  // 42
}

- (void)receiveAnalyticsError:(NSError *)error
                 dispatchedBy:(id<ANAManaging>)manager {
    NSLog(@"%@", error);
}

@end

// Configure the tracker to be default
Tracker *tracker = [[Tracker alloc] init];
ANAManager.sharedManager.trackers.defaults = @[tracker];

// Given the points registered, this call will trigger an event sent to the configured tracker
Object *object = [[Object alloc] init];
[object call];

```

### Multiple Points in One Method

Sometimes, there are more than one points in one method. Then, we need to register the points recursively, in a tree-like way. And when calling `.analyze()`, we pass in some arguments to determine which point is wanted. When the method in **tracker** gets called, the `event` will contain all the properties set through the point tree path and the arguments passed in.

[Swift](../README.md) | ObjC
```objective-c
- (void)callWithIndex:(NSInteger)index
                 name:(NSString *)name {
    self.ana.event_
    .set(@"index", @(index))
    .set(@"name", name)
    ._.analyze();
}

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {
    // Register points related to the class
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@selector(callWithIndex:name:))
        .point(^(id<ANAPointBuilding> _) { _
            .equal(@"index", @0)
            .set(@"first-level", @"42")
            .point(^(id<ANAPointBuilding> _) { _
                .equal(@"name", @"Tom")
                .set(@"second-level", @42)
                ;
            })
            .point(^(id<ANAPointBuilding> _) { _
                .equal(@"name", @"Jerry")
                .set(@"second-level", @24)
                ;
            })
            ;
        })
        .point(^(id<ANAPointBuilding> _) { _
            .equal(@"index", @1)
            .set(@"first-level", @"24")
            ;
        })
        ;
    })
    ;
}

// With a call as following
[[[Object alloc] init] callWithIndex:0 name:@"Jerry"];

// We can expect it in the tracker's delegate method
- (void)receiveAnalyticsEvent:(id<ANAEventBeing>)event
                 dispatchedBy:(id<ANAManaging>)manager {
    NSLog(@"%@", event[@"index"]);          // 0
    NSLog(@"%@", event[@"name"]);           // Jerry
    NSLog(@"%@", event[@"first-level"]);    // 42
    NSLog(@"%@", event[@"second-level"]);   // 24
}
```
