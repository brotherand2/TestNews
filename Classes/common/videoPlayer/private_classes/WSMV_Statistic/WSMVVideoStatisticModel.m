//
//  WSMVVideoStatisticModel.m
//  sohunews
//
//  Created by handy wang on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "WSMVVideoStatisticModel.h"

@implementation WSMVVideoStatisticModel

#pragma mark - Lifecycle
-(void)dealloc {
    self.offline = nil;
    self.page = nil;
    self.screen = nil;
}

#pragma mark - Public
- (NSString *)networkReachability {
    NetworkStatus networkStatus = [[SNUtility getApplicationDelegate] currentNetworkStatus];
    if (networkStatus == ReachableViaWiFi) {
        return @"wifi";
    }
    else if (networkStatus == ReachableViaWWAN ||
             networkStatus == ReachableVia2G ||
             networkStatus == ReachableVia3G ||
             networkStatus == ReachableVia4G) {
        return @"2G,3G";
    }
    else {
        return @"notreachable";
    }
}

@end
