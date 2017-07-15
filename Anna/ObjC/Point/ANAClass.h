//
//  ANAClass.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANAMethod.h"

@protocol ANATracker, ANATrackerCollection;
@protocol ANAClassPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^point)(ANAMethodPointBuildup __nullable);
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^tracker)(id<ANATracker> __nonnull);
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^trackers)(NSArray<id<ANATracker>> * __nonnull);
@property (readonly, nonnull) id<ANATrackerCollection> availableTrackers;
@end
