//
//  PointMatchingTests.m
//  Anna
//
//  Created by William on 22/04/2017.
//
//

#import "ANATAnnaTestCase.h"
#import <Anna/Anna.h>
#import <extobjc/EXTobjc.h>

@interface PointMatchingObject : ANATAnalyzable <ANAAnalyzable>
@end

@implementation PointMatchingObject

- (void)pointUserInfo {
    self.ana.analyze();
}

- (void)twoPointsContainedInOneMethod:(NSInteger)index {
    self.ana.event_.set(@"index", @(index))._.analyze();
}

- (void)threePointsContainedInOneMethodWithIndex:(NSInteger)index
                                            name:(NSString *)name
{
    self.ana.event_
    .set(@"index", @(index))
    .set(@"name", name)
    ._.analyze();
}

- (void)throwErrorForMissingMatching {
    self.ana.analyze();
}

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], pointUserInfo))
        .set(@"data", @"42")
        ;
    })
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector([self new], twoPointsContainedInOneMethod:))
        .point(^(id<ANAPointBuilding> _) { _
            .equal(@"index", @0)
            .set(@"data", @"42")
            ;
        })
        .point(^(id<ANAPointBuilding> _) { _
            .equal(@"index", @1)
            .set(@"data", @"24")
            ;
        })
        ;
    })
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector([self new], threePointsContainedInOneMethodWithIndex:, name:))
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

@interface EmptyRegistrationObject : ANATAnalyzable <ANAAnalyzable>
@end
@implementation EmptyRegistrationObject

- (void)throwErrorForEmptyRegistration { self.ana.analyze(); }

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {}

@end

@interface ANATPointMatchingTests : ANATAnnaTestCase
@end

@implementation ANATPointMatchingTests

- (void)test_pointUserInfo {
    [self waitForEvents:^{
        [[PointMatchingObject objectWithAnalyzer:self.manager] pointUserInfo];
    }];
    XCTAssertEqualObjects(self.receivedEvents.lastObject[@"data"], @"42");
    XCTAssertNil(self.receivedErrors.lastObject);
}

- (void)test_twoPointsContainedInOneMethod {
    [self waitForEventsOfCount:2
                     execution:^{
        PointMatchingObject *object;
        object = [PointMatchingObject objectWithAnalyzer:self.manager];
        [object twoPointsContainedInOneMethod:0];
        [object twoPointsContainedInOneMethod:1];
    }];
    XCTAssertEqualObjects(self.receivedEvents[0][@"data"], @"42");
    XCTAssertEqualObjects(self.receivedEvents[1][@"data"], @"24");
    XCTAssertNil(self.receivedErrors.lastObject);
}

- (void)test_threePointsContainedInOneMethod {
    [self waitForEventsOfCount:3
                     execution:^{
        PointMatchingObject *object;
        object = [PointMatchingObject objectWithAnalyzer:self.manager];
        [object threePointsContainedInOneMethodWithIndex:0 name:@"Tom"];
        [object threePointsContainedInOneMethodWithIndex:0 name:@"Jerry"];
        [object threePointsContainedInOneMethodWithIndex:1 name:@"Jimmy"];
    }];
    XCTAssertEqualObjects(self.receivedEvents[0][@"first-level"], @"42");
    XCTAssertEqualObjects(self.receivedEvents[0][@"second-level"], @42);
    XCTAssertEqualObjects(self.receivedEvents[1][@"first-level"], @"42");
    XCTAssertEqualObjects(self.receivedEvents[1][@"second-level"], @24);
    XCTAssertEqualObjects(self.receivedEvents[2][@"first-level"], @"24");
    XCTAssertNil(self.receivedErrors.lastObject);
}

- (void)test_throwErrorForMissingMatching {
    [self waitForEvents:^{
        [[PointMatchingObject objectWithAnalyzer:self.manager] throwErrorForMissingMatching];
    }];
    NSError *answer;
    answer = [NSError errorWithDomain:ANAMatchingErrorDomain
                                 code:ANAMatchingErrorNoMatchingPoint
                             userInfo:nil];
    XCTAssertEqualObjects(self.receivedErrors.lastObject, answer);
}

- (void)test_throwErrorForEmptyRegistration {
    [self waitForEvents:^{
        [[EmptyRegistrationObject objectWithAnalyzer:self.manager] throwErrorForEmptyRegistration];
    }];
    XCTAssertNotNil(self.receivedErrors.lastObject);
}

@end
