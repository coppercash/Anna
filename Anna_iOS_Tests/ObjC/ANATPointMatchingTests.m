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
- (void)pointUserInfo;
- (void)twoPointsContainedInOneMethod:(NSInteger)index;
@end

@implementation PointMatchingObject

- (void)pointUserInfo {
    self.ana.analyze();
}

- (void)twoPointsContainedInOneMethod:(NSInteger)index {
    self.ana.event_.set(@"index", @(index))._.analyze();
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
    ;
}

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
    [self waitForEvents:^{
        PointMatchingObject *object;
        object = [PointMatchingObject objectWithAnalyzer:self.manager];
        [object twoPointsContainedInOneMethod:0];
        [object twoPointsContainedInOneMethod:1];
    }];
    XCTAssertEqualObjects(self.receivedEvents[0][@"data"], @"42");
    XCTAssertEqualObjects(self.receivedEvents[1][@"data"], @"24");
    XCTAssertNil(self.receivedErrors.lastObject);
}

@end
