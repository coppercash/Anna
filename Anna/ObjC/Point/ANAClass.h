//
//  ANAClass.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANAMethod.h"

@protocol ANATracking, ANATrackerCollecting;
@protocol ANAClassPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^point)(ANAMethodPointBuildup __nullable);
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^tracker)(id<ANATracking> __nonnull);
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^trackers)(NSArray<id<ANATracking>> * __nonnull);
@property (readonly, nonnull) id<ANATrackerCollecting> availableTrackers;
@end
