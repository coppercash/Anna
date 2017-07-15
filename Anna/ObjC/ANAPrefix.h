//
//  ANAPrefix.h
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAEventSeedBuilding;
@protocol ANAPrefixing
@property (readonly, nonnull) void(^analyze)();
@property (readonly, nonnull) id<ANAEventSeedBuilding> event_;
@end
