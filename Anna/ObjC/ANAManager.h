//
//  ANAManager.h
//  Anna
//
//  Created by William on 07/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANAEventSeed.h"

@protocol
ANATrackerCollection,
ANATrackerConfigurator,
ANAEventSeed;
@protocol ANAManaging <NSObject, ANAEventDispatching>
@property (readonly, nonnull) id<ANATrackerConfigurator, ANATrackerCollection> trackers;
@property (readonly, class, nonnull) id<ANAManaging> __kindof sharedManager;
@end
