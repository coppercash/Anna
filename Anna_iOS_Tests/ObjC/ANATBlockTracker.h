//
//  ANATBlockTracker.h
//  Anna
//
//  Created by William on 15/07/2017.
//
//

#import <Foundation/Foundation.h>
#import <Anna/Anna.h>

@class XCTestExpectation;
@protocol ANAEvent;
@interface ANATBlockTracker : NSObject <ANATracker>
@property (nonatomic, readonly) NSArray<id<ANAEvent>> *receivedEvents;
@property (nonatomic, readonly) NSArray<NSError *> *receivedErrors;
- (void)addExpectation:(XCTestExpectation *)expectation;
@end
