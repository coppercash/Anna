//
//  ANATTrackerTests.m
//  Anna
//
//  Created by William on 15/07/2017.
//
//

#import "ANATAnnaTestCase.h"
#import <Anna/Anna.h>
#import <extobjc/EXTobjc.h>
#import "ANATBlockTracker.h"

@interface TrackerObject : ANATAnalyzable <ANAAnalyzable>
@end

@implementation TrackerObject

- (void)appendTracker { self.ana.analyze(); }
- (void)overrideTrackers { self.ana.analyze(); }
+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], appendTracker))
        .tracker(_.availableTrackers[@"second"])
        ;
    })
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], overrideTrackers))
        .trackers(@[_.availableTrackers[@"second"]])
        ;
    })
    ;
}

@end

@interface ANATTrackerTests : ANATAnnaTestCase
@end
@implementation ANATTrackerTests

- (void)test_appendTracker {
    ANATBlockTracker *appended;
    appended = [[ANATBlockTracker alloc] init];
    [appended addExpectation:[self expectationWithDescription:@"AnotherExpectation"]];
    self.manager.trackers[@"second"] = appended;
    
    [self waitForEvents:^{
        [[TrackerObject objectWithAnalyzer:self.manager] appendTracker];
    }];
    
    XCTAssertNotNil(self.receivedEvents.lastObject);
    XCTAssertNil(self.receivedErrors.lastObject);
    XCTAssertNotNil(appended.receivedEvents.lastObject);
    XCTAssertNil(appended.receivedErrors.lastObject);
}

- (void)test_overrideTrackers {
    ANATBlockTracker *appended;
    appended = [[ANATBlockTracker alloc] init];
    [appended addExpectation:[self expectationWithDescription:@"AnotherExpectation"]];
    self.manager.trackers[@"second"] = appended;
    
    [self waitForEventsOfCount:0 execution:^{
        [[TrackerObject objectWithAnalyzer:self.manager] overrideTrackers];
    }];
    
    XCTAssertNil(self.receivedEvents.lastObject);
    XCTAssertNil(self.receivedErrors.lastObject);
    XCTAssertNotNil(appended.receivedEvents.lastObject);
    XCTAssertNil(appended.receivedErrors.lastObject);
}

@end
