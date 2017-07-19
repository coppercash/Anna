//
//  ANATracker.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAEvent;
@protocol ANATracker <NSObject>
- (void)receiveAnalyticsEvent:(id<ANAEvent> __nonnull)event
                 dispatchedBy:(id<ANAManaging> __nonnull)manager;
- (void)receiveAnalyticsError:(NSError * __nonnull)error
                 dispatchedBy:(id<ANAManaging> __nonnull)manager;
@end

@protocol ANATrackerCollection <NSObject>
- (id<ANATracker> __nullable)objectForKeyedSubscript:(NSObject<NSCopying> * __nonnull)key;
- (void)setObject:(id<ANATracker> __nullable)obj
forKeyedSubscript:(NSObject<NSCopying> * __nonnull)key;
@end

@protocol ANATrackerConfigurator <NSObject>
@property (readwrite, nullable) NSArray<id<ANATracker>> *defaults;
@end
