//
//  ANATInheritanceTests.m
//  Anna
//
//  Created by William on 15/07/2017.
//
//

#import "ANATAnnaTestCase.h"
#import <Anna/Anna.h>
#import <extobjc/EXTobjc.h>

@interface InheritanceParent : ANATAnalyzable <ANAAnalyzable>
@end
@implementation InheritanceParent

- (void)inheritsMethodFromSuper { self.ana.analyze(); }
- (void)inheritsMethodFromSuperWithouthRegistering { self.ana.analyze(); }
- (void)overridesPointRegisterredBySuper { self.ana.analyze();  }
- (void)KVObservedObjectBehavesAsNormalObject { self.ana.analyze(); }
+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], inheritsMethodFromSuper))
        ;
    })
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], inheritsMethodFromSuperWithouthRegistering))
        ;
    })
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], overridesPointRegisterredBySuper))
        .set(@"name", @"Parent")
        ;
    })
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], KVObservedObjectBehavesAsNormalObject))
        .set(@"answer", @42)
        ;
    })
    ;
}

@end

@interface InheritanceChild : InheritanceParent
@end
@implementation InheritanceChild

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar
{
    [super ana_registerAnalyticsPointsWithRegistrar:registrar];
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@checkselector0([self new], overridesPointRegisterredBySuper))
        .set(@"name", @"Child")
        ;
    })
    ;
}

@end

@interface InheritanceChildWithoutRegistering : InheritanceParent
@end
@implementation InheritanceChildWithoutRegistering
@end

@interface ANATInheritanceTests : ANATAnnaTestCase
@end
@implementation ANATInheritanceTests

- (void)test_inheritsMethodFromSuper {
    [self waitForEvents:^{
        [[InheritanceChild objectWithAnalyzer:self.manager] inheritsMethodFromSuper];
    }];
    XCTAssertNotNil(self.receivedEvents.lastObject);
    XCTAssertNil(self.receivedErrors.lastObject);
}

- (void)test_inheritsMethodFromSuperWithouthRegistering {
    [self waitForEvents:^{
        [[InheritanceChildWithoutRegistering objectWithAnalyzer:self.manager] inheritsMethodFromSuperWithouthRegistering];
    }];
    XCTAssertNotNil(self.receivedEvents.lastObject);
    XCTAssertNil(self.receivedErrors.lastObject);
}

- (void)test_overridesPointRegisterredBySuper {
    [self waitForEvents:^{
        [[InheritanceChild objectWithAnalyzer:self.manager] overridesPointRegisterredBySuper];
    }];
    XCTAssertEqualObjects(self.receivedEvents.lastObject[@"name"], @"Child");
    XCTAssertNil(self.receivedErrors.lastObject);
}

- (void)test_KVObservedObjectBehavesAsNormalObject {
    [self waitForEvents:^{
        InheritanceChild *object;
        object = [InheritanceChild objectWithAnalyzer:self.manager];
        [object addObserver:self
                 forKeyPath:@keypath(object, hash)
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        [object KVObservedObjectBehavesAsNormalObject];
        [object removeObserver:self
                    forKeyPath:@keypath(object, hash)
                       context:nil];
    }];
    XCTAssertEqualObjects(self.receivedEvents.lastObject[@"answer"], @42);
    XCTAssertNil(self.receivedErrors.lastObject);
}

@end
