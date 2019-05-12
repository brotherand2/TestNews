//
//  SNLocationRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLocationRequest.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation SNLocationRequest

- (instancetype)initWithLocation:(CGPoint)location
{
    self = [super init];
    if (self) {
        //cdma_lng=%lf&cdma_lat=%lf
        [self.parametersDict setValue:[NSString stringWithFormat:@"%lf",location.y] forKey:@"cdma_lng"];
        [self.parametersDict setValue:[NSString stringWithFormat:@"%lf",location.x] forKey:@"cdma_lat"];
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_ReportLocation;
}

- (id)sn_parameters {
     //获取mcc、mnc
    NSString *mcc = [[SNUtility sharedUtility] getCountryCode];
    NSString *mnc = [[SNUtility sharedUtility] getNetworkCode];
    if (mcc) {
        [self.parametersDict setValue:mcc forKey:@"mcc"];
    }
    if (mnc) {
        [self.parametersDict setValue:mnc forKey:@"mnc"];
    }
    
    //获取ssid、bssid
    CFArrayRef cf_ifs = CNCopySupportedInterfaces();
    NSArray *ifs = (__bridge id)cf_ifs;
    NSString *ssid = nil;
    NSString *bssid = nil;
    for (NSString *ifnam in ifs) {
        CFDictionaryRef cf_info = CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        NSDictionary *info = (__bridge id)cf_info;
        if (info[@"SSID"]) {
            ssid = [NSString stringWithString:info[@"SSID"]];
        }
        if (info[@"BSSID"]) {
            bssid = [NSString stringWithString:info[@"BSSID"]];
        }
        if (cf_info != NULL) {
            CFRelease(cf_info); // v5.2.1 需判断NULL !
        }
    }
    if (ssid) {
        
        [self.parametersDict setValue:ssid forKey:@"wifi_ssid"];
    }
    if (bssid) {
        [self.parametersDict setValue:bssid forKey:@"wifi_bssid"];
    }
    
    if (cf_ifs != NULL) {
        CFRelease(cf_ifs); // v5.2.1
    }
    
    //net类型
    NSString *reachStatus = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    if (reachStatus && ![reachStatus isEqualToString:@""]) {
        [self.parametersDict setValue:reachStatus forKey:@"net"];
    }
    
    //定位时间戳
    NSTimeInterval locationTime = [[NSDate date] timeIntervalSince1970];
    [self.parametersDict setValue:[NSString stringWithFormat:@"%f",locationTime*1000] forKey:@"cdma_sTime"];
    
    return [super sn_parameters];
}

@end
