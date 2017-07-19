//
//  ANAEventSeed.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAPointMatchable <NSObject>
@property (readonly, nonnull) Class cls;
@property (readonly, nonnull) SEL selector;
@end

@protocol ANAPayloadCarrying <NSObject>
@property (readonly, nullable) NSDictionary<NSObject<NSCopying> *, id> *payload;
@end

@protocol ANARegistrantCarrying;
@protocol ANAEventDispatching <NSObject>
- (void)dispatchEventWithSeed:(id<ANAPointMatchable, ANAPayloadCarrying, ANARegistrantCarrying> __nonnull)seed;
@end

@protocol ANAPrefixing;
@protocol ANAEventSeedBuilding <NSObject>
@property (readonly, nonnull) id<ANAEventSeedBuilding>__nonnull (^set)(NSObject<NSCopying> * __nonnull, id __nullable);
@property (readonly, nonnull) id<ANAPrefixing> _;
@end
