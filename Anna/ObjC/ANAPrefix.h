//
//  ANAPrefix.h
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ANAEventSeedBuilding;
@class ANAAnalyzer;
@protocol ANAPrefixing
@property (readonly) void(^analyze)();
@property (readonly) id<ANAEventSeedBuilding> event_;
@property (readonly) ANAAnalyzer *analyzer;
@end

NS_ASSUME_NONNULL_END
