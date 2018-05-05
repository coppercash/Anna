//
//  Tracker.m
//  CocoapodsDemo
//
//  Created by William on 2018/5/5.
//  Copyright © 2018 coppercash. All rights reserved.
//

#import "Tracker.h"

@implementation Tracker

- (void)receiveAnalyticsError:(NSError * _Nonnull)analyticsError
          dispatchedByManager:(ANAManager * _Nonnull)manager
{
    NSLog(@"%@", analyticsError);
}

- (void)receiveAnalyticsResult:(id _Nonnull)analyticsResult
           dispatchedByManager:(ANAManager * _Nonnull)manager
{
    NSLog(@"%@", analyticsResult);
}

@end
