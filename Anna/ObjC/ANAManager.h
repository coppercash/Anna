//
//  ANAManager.h
//  Anna
//
//  Created by William on 07/05/2017.
//
//

#import <Foundation/Foundation.h>

@protocol AANTrackerCollection, ANATrackerConfigurator;
@protocol ANAManager <NSObject>
@property (readonly) id<ANATrackerConfigurator, AANTrackerCollection> trackers;
@end

@interface ANAManager : NSObject <ANAManager>
@end
