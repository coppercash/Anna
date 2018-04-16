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
    [test launch];
    
    __auto_type const
    navigation = (UINavigationController *)test.appDelegate.window.rootViewController;
    __auto_type const
    controller = [[ANAPathTestingViewController alloc] initWithNodeName:@"vc"];
    [navigation pushViewController:controller
                          animated:NO];
    __auto_type const
    button = [[ANAPathTestingButton alloc] initWithNodeName:@"bt"];
    button.analyzer = [[ANAUIControlAnalyzer alloc] initWithDelegate:button];
    [button.analyzer hookControl:button];
    [controller.view addSubview:button];
    [NSRunLoop.mainRunLoop runUntilDate:NSDate.distantFuture];
    
    [test expectResult];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [self waitForExpectations:test.expectations
                      timeout:100.0];
    XCTAssertEqualObjects(test.results[0], @42);
}

@end
