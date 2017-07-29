//
//  ANATSampleCodeTests.m
//  Anna
//
//  Created by William on 22/07/2017.
//
//

#import <XCTest/XCTest.h>
#import <Anna/Anna.h>

// MARK:- The Most Basic

@interface MYObject : NSObject <ANAAnalyzable>
- (void)call;
- (void)callWithIndex:(NSInteger)index name:(NSString *)name;
@end
@implementation MYObject

- (void)call {
    // Pull the trigger
    self.ana.analyze();
}

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
        .selector(@selector(call))
        .set(@"theAnswer", @42)
        ;
    })
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

// MARK:- Multiple Points in One Method

@interface Tracker1 : NSObject <ANATracking>
@end
@implementation Tracker1

// We can expect it in the tracker's delegate method
- (void)receiveAnalyticsEvent:(id<ANAEventBeing>)event
                 dispatchedBy:(id<ANAManaging>)manager {
    NSLog(@"%@", event[@"index"]);          // 0
    NSLog(@"%@", event[@"name"]);           // Jerry
    NSLog(@"%@", event[@"first-level"]);    // 42
    NSLog(@"%@", event[@"second-level"]);   // 24
}

- (void)receiveAnalyticsError:(NSError *)error
                 dispatchedBy:(id<ANAManaging>)manager {
    NSLog(@"%@", error);
}

@end

@interface ANATSampleCodeTests : XCTestCase
@end

@implementation ANATSampleCodeTests

- (void)test_theMostBasic {
    // Configure the tracker to be default
    Tracker *tracker = [[Tracker alloc] init];
    ANAManager.sharedManager.trackers.defaults = @[tracker];
    
    // Given the points registered, this call will trigger an event sent to the configured tracker
    MYObject *object = [[MYObject alloc] init];
    [object call];
}

- (void)test_multiplePointsInOneMethod {
    ANAManager.sharedManager.trackers.defaults = @[[[Tracker1 alloc] init]];
    // With a call as following
    [[[MYObject alloc] init] callWithIndex:0 name:@"Jerry"];
}

@end
