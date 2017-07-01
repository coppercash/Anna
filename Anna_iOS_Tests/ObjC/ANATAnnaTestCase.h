//
//  ANATAnnaTestCase.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <XCTest/XCTest.h>

typedef void(^ANATEventsBlock)(void);
@protocol ANAEvent, ANAManager;
@protocol ANATAnnaTestCase
@property (readonly) id<ANAManager> manager;
@property (readonly) NSArray<id<ANAEvent>> *receivedEvents;
- (void)waitForEvents:(ANATEventsBlock)execution;
- (void)waitForEventsOfCount:(NSUInteger)count
                   execution:(ANATEventsBlock)execution;
@end

@interface ANATAnnaTestCase : XCTestCase <ANATAnnaTestCase>
@end

@protocol ANAManager;
@protocol ANATAnalyzable <NSObject>
+ (instancetype)objectWithAnalyzer:(id<ANAManager>)analyzer;
@end

@interface ANATAnalyzable : NSObject <ANATAnalyzable>
@end

#define anat ana
