//
//  PointMatchingTests.m
//  Anna
//
//  Created by William on 22/04/2017.
//
//

#import <XCTest/XCTest.h>
#import <Anna/Anna.h>
#import <extobjc/EXTobjc.h>

#define anat ana

@interface ANATTarget : NSObject
@property (strong, nonatomic, readonly) ANAManager *analyzer;
- (instancetype)initWithAnalyzer:(ANAManager *)analyzer;
- (void)functionOne;
@end

@implementation ANATTarget

- (instancetype)initWithAnalyzer:(ANAManager *)analyzer {
    if (self = [super init]) {
        _analyzer = analyzer;
    }
    return self;
}

- (void)functionOne {
    self.anat.analyze();
}

+ (void)registerPointsWithRegistrar:(id<ANARegistrar>)_ {
    _
    .point(^(id<ANAPointBuilder> _) { _
        .selector(@checkselector0([self new], functionOne))
        .set(@"data", @"function_one_point_data");
    });
}

@end

@class ANATPoint;
@interface ANATTracker : NSObject
@property (readonly, nonatomic) ANATPoint *lastPoint;
@end

@implementation ANATTracker
@end

@interface ANATManager : ANAManager
@property (strong, nonatomic, readonly) ANATTracker *defaultTracker;
- (instancetype)initWithDefaultTracker:(ANATTracker *)tracker;
@end

@implementation ANATManager

- (instancetype)initWithDefaultTracker:(ANATTracker *)tracker {
    if (self = [super init]) {
        _defaultTracker = tracker;
    }
    return self;
}

@end

@interface ANATPoint : NSObject
@property (readonly, strong, nonatomic) id data;
@end

@interface PointMatchingTests : XCTestCase
@end

@implementation PointMatchingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_pointUserInfo {
    ANATTracker *tracker = [[ANATTracker alloc] init];
    ANATManager *manager = [[ANATManager alloc] initWithDefaultTracker:tracker];
    ANATTarget *target = [[ANATTarget alloc] initWithAnalyzer:manager];
    [target functionOne];
    ANATPoint *lastPoint = tracker.lastPoint;
    XCTAssertEqual(lastPoint.data, @"function_one_point_data");
}

@end

/* TODO
 Test multiple trackers, setting with a collection can be overridden
 */
