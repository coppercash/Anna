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
ANATrackerCollecting,
ANATrackerConfigurator,
ANAEventSeed;
@protocol ANAManaging <NSObject, ANAEventDispatching>
@property (readonly, nonnull) id<ANATrackerConfigurator, ANATrackerCollecting> trackers;
@property (readonly, class, nonnull) id<ANAManaging> __kindof sharedManager;
@end

extern NSErrorDomain const __unsafe_unretained __nonnull ANAMatchingErrorDomain;
typedef NS_ENUM(NSInteger, ANAMatchingError) {
    ANAMatchingErrorNoMatchingPoint,
    ANAMatchingErrorTooManyMatchingPoints,
};
