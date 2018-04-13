//
//  ANAPathTests.m
//  Anna_iOS_Tests
//
//  Created by William on 13/04/2018.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <Anna/Anna.h>

@interface ANAPathTests : XCTestCase
@property (nonatomic) UIApplication *application;
@property (nonatomic) ANAManager *manager;
@end

@implementation ANAPathTests

- (void)testExample {
    __auto_type const
    fs = self.fileManager;
    __auto_type const
    ap = self.application;
    __auto_type const
    dl = self.delegate;
    
    fs.readContentsAtPath = ^(NSString *path) {
        return @""
        "const match = require('anna').default().match;"
        "match("
        "  '/UIApplication/ANAAppDelegate/UIViewController/event',"
        "  function() { return 42; }"
        ");"
        ;
    }
    __auto_type const
    ex = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    __auto_type __block
    rs = (id)nil;
    dl.receiveAnalyticsResult = ^(id result, ANAManager *manager) {
        rs = result;
        [ex fulfill];
    };
    __auto_type const
    rt = ap.delegate.window.rootViewController;
    [rt.ana_analyst observeViewController:rt];
    [ap.delegate.window makeKeyWindow];
    
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
    XCTAssertEqualObjects(rs, @42);
}

@end
