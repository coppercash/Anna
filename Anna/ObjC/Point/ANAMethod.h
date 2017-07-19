//
//  ANAMethod.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol BDPDictionaryBuilding <NSObject>
@property (readonly, nonnull) id<BDPDictionaryBuilding> __nonnull (^set)(NSObject<NSCopying> * __nonnull, id __nullable);
@end

#import "ANAPoint.h"

@protocol ANAMethodPointBuilding;
typedef void(^ANAMethodPointBuildup)(id<ANAMethodPointBuilding> __nonnull _);

@protocol ANATracker, ANATrackerCollection;
@protocol ANAMethodPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^selector)(SEL __nonnull);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^set)(NSObject<NSCopying> * __nonnull, id __nullable);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^point)(ANAPointBuildup __nullable);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^tracker)(id<ANATracker> __nonnull);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^trackers)(NSArray<id<ANATracker>> * __nonnull);
@property (readonly, nonnull) id<ANATrackerCollection> availableTrackers;
@end
