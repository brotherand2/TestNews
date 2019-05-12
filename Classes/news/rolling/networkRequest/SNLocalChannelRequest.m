//
//  SNLocalChannelRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLocalChannelRequest.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SNClientRegister.h"

@interface SNLocalChannelRequest ()
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
@end

@implementation SNLocalChannelRequest

- (instancetype)initWithLocationCoordinate:(CLLocationCoordinate2D )locationCoordinate
{
    self = [super init];
    if (self) {
        self.locationCoordinate = locationCoordinate;
    }
    return self;
}


- (NSDictionary *)addLocationDefaultParameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    //获取MCC、MNC
    NSString *mcc = [[SNUtility sharedUtility] getCountryCode];
    NSString *mnc = [[SNUtility sharedUtility] getNetworkCode];
    if (mcc) {
        [params setValue:mcc forKey:@"mcc"];
    }
    if (mnc) {
        [params setValue:mnc forKey:@"mnc"];
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
        
        [params setValue:ssid forKey:@"wifi_ssid"];
    }
    if (bssid) {
        [params setValue:bssid forKey:@"wifi_bssid"];
    }
    
    if (cf_ifs != NULL) {
        CFRelease(cf_ifs); // v5.2.1
    }
    
    //net类型
    NSString *reachStatus = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    if (reachStatus && ![reachStatus isEqualToString:@""]) {
        [params setValue:reachStatus forKey:@"net"];
    }
    
    //定位时间戳
    NSTimeInterval locationTime = [[NSDate date] timeIntervalSince1970];
    [params setValue:[NSString stringWithFormat:@"%f",locationTime*1000] forKey:@"cdma_sTime"];
    
    return params.copy;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;   
}

- (NSString *)sn_requestUrl {
    
    return SNLinks_Path_Channel_LocalChannel;
}


- (id)sn_parameters {
    // ?cdma_lng=%lf&cdma_lat=%lf
    [self.parametersDict setValue:[NSString stringWithFormat:@"%lf",_locationCoordinate.longitude] forKey:@"cdma_lng"];
    [self.parametersDict setValue:[NSString stringWithFormat:@"%lf",_locationCoordinate.latitude] forKey:@"cdma_lat"];
    [self.parametersDict setValuesForKeysWithDictionary:[self addLocationDefaultParameters]];
    return [super sn_parameters];
}

@end
