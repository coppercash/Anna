//
//  ANAAnalyzable.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANARegister.h"

@protocol ANAEventDispatching, ANAPrefixing;
@protocol ANAAnalyzable <NSObject, ANARegistering>
- (id<ANAEventDispatching> __nonnull)ana_analyticsManager;
- (id<ANAPrefixing> __nonnull (^ __nonnull)(SEL __nonnull)) ana_context;
@end

#define ana ana_context(_cmd)
