//
//  ANAClass.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "ANAMethod.h"

@protocol ANAClassPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAClassPointBuilding> __nonnull (^point)(ANAMethodPointBuildup __nullable);
@end
