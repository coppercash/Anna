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

#define anat ana

@interface PointUserInfoObject : ANATAnalyzable <ANAAnalyzable>
- (void)call;
@end

@implementation PointUserInfoObject

- (void)call {
    self.ana.analyze();
}

+ (void)registerAnalyticsPointsWithRegistrar:(id<ANARegistrar>)registrar {
    registrar
    .point(^(id<ANAPointBuilder> _) { _
        .selector(@checkselector0([self new], call))
        .set(@"data", @"42");
    });
}

@end

@interface ANATPointMatchingTests : ANATAnnaTestCase
@end

@implementation ANATPointMatchingTests

- (void)test_pointUserInfo {
    [self waitForEvents:^{
        [[PointUserInfoObject objectWithAnalyzer:self.manager] call];
    }];
    XCTAssertEqualObjects(self.receivedEvents.lastObject[@"data"], @"42");
}

@end
