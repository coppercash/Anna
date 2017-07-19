//
//  ANAEvent.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAEvent <NSObject>
- (id __nullable)objectForKeyedSubscript:(NSObject<NSCopying> * __nonnull)key;
@end

