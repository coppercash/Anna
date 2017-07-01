//
//  ANAMethod.h
//  Anna
//
//  Created by William on 07/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol BDPDictionaryBuilding <NSObject>
@property (readonly, nonnull) id<BDPDictionaryBuilding> __nonnull (^set)(id<NSCopying> __nonnull, id __nullable);
@end

@protocol ANAMethodPointBuilding <NSObject>
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^selector)(SEL __nonnull);
@property (readonly, nonnull) id<ANAMethodPointBuilding> __nonnull (^set)(NSString * __nonnull, id __nullable);
@end
typedef void(^ANAMethodPointBuildup)(id<ANAMethodPointBuilding> __nonnull _);
