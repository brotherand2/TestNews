//
//  SNDefaultParamsRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNUserLocationManager.h"
#import "Reachability.h"

@implementation SNDefaultParamsRequest

- (void)setNeedNetSafeParameters:(BOOL)needNetSafeParameters {
    _needNetSafeParameters = needNetSafeParameters;
    if (needNetSafeParameters) {
        [self.parametersDict setValuesForKeysWithDictionary:[self getNetSafeParameters]];
    }
}

- (void)setNeedCurrentNetStatusParam:(BOOL)needCurrentNetStatusParam {
    _needCurrentNetStatusParam = needCurrentNetStatusParam;
    if (needCurrentNetStatusParam) {
        [self.parametersDict setValue:[self getCurrentNetworkStatusString] forKey:@"net"];
    }
}

/**
 获取当前网络状态
 
 @return 网络状态，如 wifi,4G,3G,2G
 */
- (NSString *)getCurrentNetworkStatusString {
    NSString *stateString = @"";
    /* NetworkStatus
     NotReachable = 0,
     ReachableViaWiFi,
     ReachableViaWWAN,
     ReachableVia2G,
     ReachableVia3G,
     ReachableVia4G
     */
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            stateString = @"";
            break;
        case ReachableViaWiFi:
            stateString = @"WiFi";
            break;
        case ReachableViaWWAN:
            stateString = @"WWAN";
            break;
        case ReachableVia2G:
            stateString = @"2G";
            break;
        case ReachableVia3G:
            stateString = @"3G";
            break;
        case ReachableVia4G:
            stateString = @"4G";
            break;
        default:
            break;
    }
    return stateString;
}

/**
 *  获取网安监控参数
 *
 *  @return 网安监控参数
 */
- (NSDictionary *)getNetSafeParameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    //内网IP
    NSString *innerIPValue = [UIDevice ipAddress];
    //端口号
    NSString *portValue = [UIDevice portID];
    //经度
    NSString *longitudeValue = [[SNUserLocationManager sharedInstance] getLongitude];
    //纬度
    NSString *latitudeValue = [[SNUserLocationManager sharedInstance] getLatitude];
    
    [params setValue:innerIPValue forKey:@"innerIp"];
    [params setValue:portValue forKey:@"port"];
    [params setValue:longitudeValue forKey:@"longitude"];
    [params setValue:latitudeValue forKey:@"latitude"];
    
    return params.copy;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    NSAssert(NO, @"Subclass must implement the request Method!");
    return nil;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_baseUrl {
    return [SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK];
}

- (NSString *)sn_requestUrl {
    NSAssert(NO, @"Subclass must implement the request url!");
    return nil;
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10]; // 默认参数
    [params setValue:[SNUserManager getToken] forKey:@"token"];
    [params setValue:[SNUserManager getGid] forKey:@"gid"];
    [params setValue:[SNUserManager getP1] forKey:@"p1"];
    [params setValue:[SNUserManager getUserId] forKey:@"userId"];
    NSString *pid = [SNUserManager getPid];
    [params setValue:pid?pid:@"-1" forKey:@"pid"];
    [params setValue:[NSString stringWithFormat:@"%d", APIVersion] forKey:@"apiVersion"];
    [params setValue:[SNClientRegister sharedInstance].sid forKey:@"sid"];
    [params setValue:[SNAPI productId] forKey:@"u"];
    [params setValue:[SNAPI encodedBundleID] forKey:@"bid"];
    [self.parametersDict setValuesForKeysWithDictionary:params]; // 外部可变参数拼接

    return self.parametersDict;
}

@end
