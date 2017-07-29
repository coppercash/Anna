//
//  ANATBlockTracker.m
//  Anna
//
//  Created by William on 15/07/2017.
//
//

#import "ANATBlockTracker.h"
#import <XCTest/XCTest.h>

@interface ANATBlockTracker ()
@property (strong, nonatomic) NSMutableArray<XCTestExpectation *> *expectations;
@end

@implementation ANATBlockTracker {
    NSMutableArray *_receivedEvents;
    NSMutableArray *_receivedErrors;
}

- (instancetype)init {
    if (self = [super init]) {
        _expectations = [[NSMutableArray alloc] init];
        _receivedEvents = [[NSMutableArray alloc] init];
        _receivedErrors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<id<ANAEventBeing>> *)receivedEvents {
    return _receivedEvents;
}

- (NSArray<NSError *> *)receivedErrors {
    return _receivedErrors;
}

- (void)addExpectation:(XCTestExpectation *)expectation {
    [self.expectations addObject:expectation];
}

- (void)receiveAnalyticsEvent:(id<ANAEventBeing>)event
                 dispatchedBy:(id<ANAManaging>)manager
{
    [_receivedEvents addObject:event];
    [self.expectations.lastObject fulfill];
    [self.expectations removeLastObject];
}

- (void)receiveAnalyticsError:(NSError *)error
                 dispatchedBy:(id<ANAManaging>)manager
{
    [_receivedErrors addObject:error];
    [self.expectations.lastObject fulfill];
    [self.expectations removeLastObject];
}

@end
