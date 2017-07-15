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

@protocol ANATracker, ANATrackerCollection;
@protocol ANAPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^equal)(NSString *__nonnull, NSObject *__nonnull);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^set)(NSString * __nonnull, id __nullable);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^point)(ANAPointBuildup __nullable);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^tracker)(id<ANATracker> __nonnull);
@property (readonly, nonnull) id<ANATrackerCollection> availableTrackers;
@end
