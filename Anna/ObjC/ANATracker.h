//
//  ANATracker.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAEventBeing;
@protocol ANATracking <NSObject>
- (void)receiveAnalyticsEvent:(id<ANAEventBeing> __nonnull)event
                 dispatchedBy:(id<ANAManaging> __nonnull)manager;
- (void)receiveAnalyticsError:(NSError * __nonnull)error
                 dispatchedBy:(id<ANAManaging> __nonnull)manager;
- (void)receiveAnalyticsResult:(id __nonnull)result
                 dispatchedBy:(id<ANAManaging> __nonnull)manager;
@end

@protocol ANATrackerCollecting <NSObject>
- (id<ANATracking> __nullable)objectForKeyedSubscript:(NSObject<NSCopying> * __nonnull)key;
- (void)setObject:(id<ANATracking> __nullable)obj
forKeyedSubscript:(NSObject<NSCopying> * __nonnull)key;
@end

@protocol ANATrackerConfiguring <NSObject>
@property (readwrite, nullable) NSArray<id<ANATracking>> *defaults;
@end
