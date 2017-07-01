//
//  ANAAnalyzable.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAEventDispatching, ANAPrefix;
@protocol ANAAnalyzable <NSObject>
- (id<ANAEventDispatching> __nonnull)ana_analyticsManager;
- (id<ANAPrefix> __nonnull (^ __nonnull)(SEL __nonnull)) ana_context;
@end

// MARK: - NSObject (ANAPrefix)

#define ana ana_context(_cmd)

@interface NSObject (ANAAnalyzable) <ANAAnalyzable>
@end
