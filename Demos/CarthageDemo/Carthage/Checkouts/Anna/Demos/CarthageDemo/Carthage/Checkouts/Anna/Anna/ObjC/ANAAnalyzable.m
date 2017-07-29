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

- (id<ANAPrefixing> __nonnull (^ __nonnull)(SEL __nonnull)) ana_context {
    id __unsafe_unretained target = self;
    return ^id(SEL selector) {
        return [[ANAPrefix alloc] initWithTarget:target
                                        selector:selector];
    };
}

- (ANAManager * __nonnull)ana_analyticsManager {
    return ANAManager.sharedManager;
}

@end
