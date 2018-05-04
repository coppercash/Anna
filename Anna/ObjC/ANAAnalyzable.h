//
//  ANAAnalyzable.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANARegister.h"

NS_ASSUME_NONNULL_BEGIN

@class ANAManager, ANAAnalyzer;
@protocol ANAPrefixing;
@protocol ANAAnalyzable <NSObject, ANARegistering>
- (ANAAnalyzer *)ana_analyzer;
- (ANAManager *)ana_analyticsManager;
- (id<ANAPrefixing>(^)(SEL))ana_context;
@end

@interface NSObject (ANAAnalyzable) 
- (ANAManager *)ana_analyticsManager;
- (id<ANAPrefixing>(^)(SEL))ana_context;
@end

NS_ASSUME_NONNULL_END

#define ana ana_context(_cmd)