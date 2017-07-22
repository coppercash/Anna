//
//  ANAManager.h
//  Anna
//
//  Created by William on 07/05/2017.
//
//

#import <Foundation/Foundation.h>

@protocol
ANATrackerCollecting,
ANATrackerConfiguring;
@protocol ANAManaging <NSObject>
@property (readonly, nonnull) id<ANATrackerConfiguring, ANATrackerCollecting> trackers;
@end

extern NSErrorDomain const __unsafe_unretained __nonnull ANAMatchingErrorDomain;
typedef NS_ENUM(NSInteger, ANAMatchingError) {
    ANAMatchingErrorNoMatchingPoint,
    ANAMatchingErrorTooManyMatchingPoints,
};
