//
//  ANATAnnaTestCase.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <XCTest/XCTest.h>

typedef void(^ANATEventsBlock)(void);
@protocol ANAEvent, ANAManaging;
@protocol ANATAnnaTestCase
@property (readonly) id<ANAManaging> manager;
@property (readonly) NSArray<id<ANAEvent>> *receivedEvents;
@property (readonly) NSArray<NSError *> *receivedErrors;
- (void)waitForEvents:(ANATEventsBlock)execution;
- (void)waitForEventsOfCount:(NSUInteger)count
                   execution:(ANATEventsBlock)execution;
@end

@interface ANATAnnaTestCase : XCTestCase <ANATAnnaTestCase>
@end

@protocol ANAManaging;
@protocol ANATAnalyzable <NSObject>
+ (instancetype)objectWithAnalyzer:(id<ANAManaging>)analyzer;
@end

#import <Anna/Anna.h>

@interface ANATAnalyzable : NSObject <ANATAnalyzable, ANAAnalyzable>
@end

#define anat ana
