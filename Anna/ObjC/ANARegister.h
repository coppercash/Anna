//
//  ANARegister.h
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import <Foundation/Foundation.h>

@protocol ANAPointBuilder <NSObject>
@property (nonatomic, readonly) id<ANAPointBuilder> (^selector)(SEL);
@property (nonatomic, readonly) id<ANAPointBuilder> (^set)(id<NSCopying>, id);
@end
typedef void(^ANAPointBuilding)(id<ANAPointBuilder> _);

@protocol ANARegistrar <NSObject>
@property (nonatomic, readonly) id<ANARegistrar> (^point)(ANAPointBuilding);
@end

@protocol ANARegistrant <NSObject>

@end
