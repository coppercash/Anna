//
//  ANAAnalyzable.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANARegister.h"

@protocol ANAEventDispatching, ANAPrefix;
@protocol ANAAnalyzable <NSObject, ANARegistering>
//@property (readonly, nonnull) id<ANAEventDispatching> ana_analyticsManager;
//@property (readonly, nonnull) id<ANAPrefix> __nonnull (^ana_context)(SEL __nonnull selector);
- (id<ANAEventDispatching> __nonnull)ana_analyticsManager;
- (id<ANAPrefix> __nonnull (^ __nonnull)(SEL __nonnull)) ana_context;
@end

// MARK: - NSObject (ANAPrefix)

#define ana ana_context(_cmd)

//@interface NSObject (ANAAnalyzable) <ANAAnalyzable>
//@end
