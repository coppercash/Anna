//
//  ANATracker.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANATracker <NSObject>
@end

@protocol ANATrackerCollection <NSObject>
- (id<ANATracker>)objectForKeyedSubscript:(NSString *)key;
@end

@protocol ANATrackerConfigurator <NSObject>
@property (readwrite) NSArray<id<ANATracker>> *defaults;
@end
