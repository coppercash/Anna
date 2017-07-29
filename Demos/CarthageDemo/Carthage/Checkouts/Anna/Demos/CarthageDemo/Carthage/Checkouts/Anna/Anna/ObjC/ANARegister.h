//
//  ANARegister.h
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import <Foundation/Foundation.h>

#import "ANAClass.h"

@protocol ANARegistrationRecording <NSObject, ANAClassPointBuilding>
@end

@protocol ANARegistering <NSObject>
+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording> __nonnull)registrar;
@end
