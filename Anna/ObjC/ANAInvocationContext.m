//
//  ANAInvocationContext.m
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import "ANAInvocationContext.h"

@implementation ANAInvocationContext

- (instancetype)initWithClass:(Class)cls
                     selector:(SEL)selector
{
    if (self = [super init]) {
        _cls = cls;
        _selector = selector;
    }
    return self;
}

@end

#pragma mark - ANAInvocationContext (Analyze)

@implementation ANAInvocationContext (Analyze)

- (void (^)())analyze {
    __typeof(self) __unsafe_unretained context = self;
    return ^() {
//        QRAnalyticsEvent *event;
//        if (![(event = self.collector[@"event"]) isKindOfClass:QRAnalyticsEvent.class]) {
//            event = [[QRAnalyticsEvent alloc] initWithClass:context.cls
//                                                   selector:context.selector
//                                                   userInfo:nil];
//        }
//        [QRAnalyticsManager.sharedInstance handleEvent:event];
    };
}

@end

#pragma mark - NSObject (ANAInvocationContext)

@implementation NSObject (ANAInvocationContext)
        
- (ANAInvocationContext *(^)(SEL))ana_context
{
    id __unsafe_unretained cls = self.class;
    return ^(SEL selector) {
        return [[ANAInvocationContext alloc] initWithClass:cls
                                                  selector:selector];
    };
}

@end
