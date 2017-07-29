//
//  ANAPoint.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAPointBuilding;
typedef void(^ANAPointBuildup)(id<ANAPointBuilding> __nonnull _);

@protocol ANATracking, ANATrackerCollecting;
@protocol ANAPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^equal)(NSString *__nonnull, NSObject *__nonnull);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^set)(NSObject<NSCopying> *__nonnull, id __nullable);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^point)(ANAPointBuildup __nullable);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^tracker)(id<ANATracking> __nonnull);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^trackers)(NSArray<id<ANATracking>> * __nonnull);
@property (readonly, nonnull) id<ANATrackerCollecting> availableTrackers;
@end
