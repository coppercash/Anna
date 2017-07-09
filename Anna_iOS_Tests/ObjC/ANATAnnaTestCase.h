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
@property (readonly) NSArray<NSError *> *receivedErrors;
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

#import <Anna/Anna.h>

@interface ANATAnalyzable : NSObject <ANATAnalyzable, ANAAnalyzable>
@end

#define anat ana
