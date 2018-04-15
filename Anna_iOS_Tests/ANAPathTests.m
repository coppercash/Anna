//
//  ANAPathTests.m
//  Anna_iOS_Tests
//
//  Created by William on 13/04/2018.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <Anna/Anna.h>
#import "Anna_iOS_Tests-Swift.h"

@interface ANAPathTests : XCTestCase
@end

@implementation ANAPathTests

- (void)testExample {
    __auto_type const
    test = [[ANAPathTestCaseBuilder alloc] initWithXCTestCase:self];
    test.defaultScript = @
    "const match = require('anna').default().match;"
    "match("
    "  'vc/bt/event',"
    "  function() { return 42; }"
    ");"
    ;
    test.rootViewController = [[ANAPathTestingViewController alloc] initWithNodeName:@"vc"];
    
    [test launch];
    __auto_type const
    button = [[ANAPathTestingButton alloc] initWithNodeName:@"bt"];
    [test.rootViewController.view addSubview:button];
    [button.ana.analyst observe];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [test expectResult];
    [self waitForExpectations:test.expectations
                      timeout:1.0];
    XCTAssertEqualObjects(test.results[0], @42);
}

@end
