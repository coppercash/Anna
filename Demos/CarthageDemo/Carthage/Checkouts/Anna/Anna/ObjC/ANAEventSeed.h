//
//  ANAEventSeed.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAPrefixing;
@protocol ANAEventSeedBuilding <NSObject>
@property (readonly, nonnull) id<ANAEventSeedBuilding>__nonnull (^set)(NSObject<NSCopying> * __nonnull, id __nullable);
@property (readonly, nonnull) id<ANAPrefixing> _;
@end
