//
//  ANATAnnaTestCase.m
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import "ANATAnnaTestCase.h"

@interface ANATAnnaTestCase ()
@property (strong, nonatomic) NSMutableArray<id<ANAEvent>> *receivedEvents;
@property (strong, nonatomic) NSMutableArray<NSError *> *receivedErrors;
@property (strong, nonatomic) NSMutableArray<XCTestExpectation *> *expectations;
@property (strong, nonatomic) id<ANAManager> manager;
@end

@implementation ANATAnnaTestCase

- (void)setUp {
    [super setUp];
    self.receivedEvents = [[NSMutableArray alloc] init];
    self.receivedErrors = [[NSMutableArray alloc] init];
    self.expectations = [[NSMutableArray alloc] init];
    self.manager = [[ANAManager alloc] init];
    self.manager.trackers.defaults = @[self,];
}

- (void)tearDown {
    self.manager = nil;
    self.expectations = nil;
    self.receivedErrors = nil;
    self.receivedEvents = nil;
    [super tearDown];
}

- (void)waitForEvents:(ANATEventsBlock)execution {
    [self waitForEventsOfCount:1
                     execution:execution];
}

- (void)waitForEventsOfCount:(NSUInteger)count
                   execution:(ANATEventsBlock)execution
{
    NSInteger index;
    for (index = 0; index < count; index += 1) {
        NSString *description;
        description = [NSString stringWithFormat:@"Expectation for Event %ld", (long)count];
        XCTestExpectation *expectation;
        expectation = [self expectationWithDescription:description];
        [self.expectations addObject:expectation];
    }
    execution();
    [self waitForExpectationsWithTimeout:.1
                                 handler:
     ^(NSError * _Nullable error) { }];
}

@end

@interface ANATAnnaTestCase (ANATracker) <ANATracker>
@end

@implementation ANATAnnaTestCase (ANATracker)

- (void)receiveAnalyticsEvent:(id<ANAEvent>)event
                 dispatchedBy:(id<ANAManager>)manager
{
    [self.receivedEvents addObject:event];
    [self.expectations.lastObject fulfill];
    [self.expectations removeLastObject];
}

- (void)receiveAnalyticsError:(NSError *)error
                 dispatchedBy:(id<ANAManager>)manager
{
    [self.receivedErrors addObject:error];
    [self.expectations.lastObject fulfill];
    [self.expectations removeLastObject];
}

@end

@interface ANATAnalyzable ()
@property (strong, nonatomic) id<ANAManager> analyzer;
@end

@implementation ANATAnalyzable

+ (instancetype)objectWithAnalyzer:(id<ANAManager>)analyzer {
    ANATAnalyzable *object;
    object = [[self alloc] initWithAnalyzer:analyzer];
    return object;
}

- (instancetype)initWithAnalyzer:(id<ANAManager>)analyzer {
    if (self = [super init]) {
        _analyzer = analyzer;
    }
    return self;
}

- (id<ANAEventDispatching>)ana_analyticsManager {
    return self.analyzer;
}

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording> __nonnull)registrar {
    
}

@end
