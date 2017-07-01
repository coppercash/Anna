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
NS_SWIFT_NAME(ANAManagerProtocol)
@protocol ANAManager <NSObject>
@property (readonly, nonnull) id<ANATrackerConfigurator, ANATrackerCollection> trackers;
@property (readonly, class, nonnull) __kindof id<ANAManager> sharedManager;
@end
