//
//  ANAEventSeed.h
//  Anna
//
//  Created by William on 01/07/2017.
//
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(ANAPointMatchableProtocol)
@protocol ANAPointMatchable <NSObject>
@property (readonly, nonnull) Class cls;
@property (readonly, nonnull) SEL selector;
@end

NS_SWIFT_NAME(ANAPayloadCarryingProtocol)
@protocol ANAPayloadCarrying <NSObject>
@property (readonly, nullable) NSDictionary<NSString *, id> *payload;
@end

NS_SWIFT_NAME(ANAEventDispatchingProtocol)
@protocol ANAEventDispatching <NSObject>
- (void)dispatchEventWithSeed:(id<ANAPointMatchable, ANAPayloadCarrying> __nonnull)seed;
@end
