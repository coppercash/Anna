//
//  PointMatchingTests.m
//  Anna
//
//  Created by William on 22/04/2017.
//
//

#import <XCTest/XCTest.h>
#import <Anna/Anna.h>

@interface Target : NSObject
@end

@implementation Target


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

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    ANAManager *manager = [[ANAManager alloc] init];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
