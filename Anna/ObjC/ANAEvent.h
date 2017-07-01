//
//  ANAEvent.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAEvent <NSObject>
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
@end

@interface ANAEvent : NSObject <ANAEvent>
@end
