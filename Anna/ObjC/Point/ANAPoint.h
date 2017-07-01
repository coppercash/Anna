//
//  ANAPoint.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^selector)(SEL __nonnull);
@property (readonly, nonnull) id<ANAPointBuilding> __nonnull (^set)(id<NSCopying> __nonnull, id __nullable);
@end
typedef void(^ANAPointBuildup)(id<ANAPointBuilding> __nonnull _);
