//
//  ANAAnalyzable.m
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import "ANAAnalyzable.h"
#import <Anna/Anna-Swift.h>

@implementation NSObject (ANAPrefix)
        
- (id<ANAPrefix> (^)(SEL))ana_context {
    id __unsafe_unretained target = self;
    return ^id(SEL selector) {
        return [[ANAPrefix alloc] initWithTarget:target
                                        selector:selector];
    };
}

- (id<ANAManager>)analyticsManager {
    return ANAManager.sharedManager;
}

@end
