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
@class ANAAnalyst;
@protocol ANAPrefixing
@property (readonly) void(^analyze)();
@property (readonly) id<ANAEventSeedBuilding> event_;
@property (readonly) ANAAnalyst *analyst;
@end

NS_ASSUME_NONNULL_END
