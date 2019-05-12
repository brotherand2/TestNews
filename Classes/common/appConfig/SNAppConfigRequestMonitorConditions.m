//
//  SNAppConfigRequestMonitorConditions.m
//  sohunews
//
//  Created by WongHandy on 8/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppConfigRequestMonitorConditions.h"

static NSString *const kCarrier = @"smc.client.req_carrier";
static NSString *const kGBCode = @"smc.client.req_gbcode";
static NSString *const kMonitorScale = @"smc.client.req_monitor_scale";
static NSString *const kNetwork = @"smc.client.req_net";
static NSString *const kDevicePlatform = @"smc.client.req_plat";
static NSString *const kAppVersion = @"smc.client.req_version";

@implementation SNAppConfigRequestMonitorConditions

- (void)updateWithDic:(NSDictionary *)configDic {
    self.carrier = configDic[kCarrier];
    self.gbcode = configDic[kGBCode];
    self.monitorScale = configDic[kMonitorScale];
    self.network = configDic[kNetwork];
    self.devicePlatform = configDic[kDevicePlatform];
    self.appVersion = configDic[kAppVersion];
}

- (NSString *)description {
    NSDictionary *desc = @{kCarrier:(self.carrier.length > 0 ? self.carrier : @""),
                           kGBCode:(self.gbcode.length > 0 ? self.gbcode : @""),
                           kMonitorScale:(self.monitorScale.length > 0 ? self.monitorScale : @""),
                           kNetwork:(self.network.length > 0 ? self.network : @""),
                           kDevicePlatform:(self.devicePlatform.length > 0 ? self.devicePlatform : @""),
                           kAppVersion:(self.appVersion.length > 0 ? self.appVersion : @"")
                           };
    return [desc description];
}


@end
