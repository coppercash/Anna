//
//  ANAMethod.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>

#import "ANAPoint.h"

@protocol ANAMethodPointBuilding;
typedef void(^ANAMethodPointBuildup)(id<ANAMethodPointBuilding> __nonnull _);

@protocol ANATracking, ANATrackerCollecting;
@protocol ANAMethodPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^selector)(SEL __nonnull);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^set)(NSObject<NSCopying> * __nonnull, id __nullable);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^point)(ANAPointBuildup __nullable);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^tracker)(id<ANATracking> __nonnull);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^trackers)(NSArray<id<ANATracking>> * __nonnull);
@property (readonly, nonnull) id<ANATrackerCollecting> availableTrackers;
@end
