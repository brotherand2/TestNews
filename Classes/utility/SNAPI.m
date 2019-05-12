//
//  SNAPI.m
//  sohunews
//
//  Created by Dan Cong on 5/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAPI.h"
#import "SNClientRegister.h"
#import "SNUserLocationManager.h"

@implementation SNAPI

+ (BOOL)isItunes:(NSString *)url
{
    return [url containsString:@"itunes.apple.com"];
//    return [url hasPrefix:@"https://itunes.apple.com"] || [url hasPrefix:@"http://itunes.apple.com"] || [url hasPrefix:@"itms-apps://itunes.apple.com"] || [url hasPrefix:@"itms://itunes.apple.com"];
}
+ (BOOL)isHttpsUrl:(NSString *)url
{
    url = [url lowercaseString];
    return [url hasPrefix:@"https://"];
}
+ (NSRange)rangeOfUrl:(NSString *)url
{
    url = [url lowercaseString];
    
    if([url hasPrefix:@"http://"]){
        return [url rangeOfString:@"http://"];
    }else if([url hasPrefix:@"https://"]){
        return [url rangeOfString:@"https://"];
    }
    
    NSRange range = {0,0};
    return range;
}

+ (BOOL)isWebURL:(NSString *)url
{
    url = [url lowercaseString];
    return [url hasPrefix:@"http://"]
    || [url hasPrefix:@"https://"]
    || [url hasPrefix:@"ftp://"]
    || [url hasPrefix:@"ftps://"]
    || [url hasPrefix:@"data://"]
    || [url hasPrefix:@"file://"];
}

+ (NSString *)rootSchemeUrl:(NSString *)url
{
    if ([url hasPrefix:@"http://"]) {
        return @"http://";
    }
    
    return @"https://";
}

+ (NSString *)rootScheme
{
#if defined SNPublicLinks_Https_Mode
    return @"https://";
#endif
    
    if (YES == [SNUtility getHttpsSwitchStatus]) {
        return @"https://";
    }
    
    return @"http://";
}

+ (BOOL)isNeedToChangeHttpsHost:(NSString *)scheme
{
#if defined SNPublicLinks_Https_Mode
    return YES;
#endif
    //return NO;
    
    //如果大开关打开，就不用管所有域名了
    SNAppConfigHttpsSwitch *httpsSwitchConfig = [[SNAppConfigManager sharedInstance] configHttpsSwitch];
    NSString *httpsSwitchAll = [SNUserDefaults valueForKey:kHttpsSwitchStatusAllKey];
    BOOL isBigSwitch = NO;
    if(httpsSwitchAll && [httpsSwitchAll length] > 0){
        isBigSwitch = [httpsSwitchAll boolValue];
    }else{
        isBigSwitch = httpsSwitchConfig.httpsSwitchStatusAll;
    }
    
    if(YES == isBigSwitch){
        return YES;
    }
    
    NSArray *  hostArray = @[@"api.k.sohu.com",               //*.k.sohu.com
                             @"testapi.k.sohu.com",
                             @"onlinetestapi.k.sohu.com",
                             @"zcache.k.sohu.com",
                             @"cache.k.sohu.com",
                             @"pic.k.sohu.com",
                             @"3g.k.sohu.com",
                             @"m.k.sohu.com",
                             @"cms.k.sohu.com",
                             @"sns.k.sohu.com",
                             @"content.k.sohu.com",
                             @"test3g.k.sohu.com",
                             @"push.k.sohu.com",
                             @"mp.k.sohu.com",
                             @"ee.k.sohu.com",
                             @"api1.k.sohu.com",
                             @"partner.k.sohu.com",
                             @"k.sohu.com",                   //*.sohu.com
                             @"s.itc.cn",                     //*.itc.cn
                             @"mp.wap.sohu.com",              //*.wap.sohu.com(需申请)
                             @"bi.k.sohuno.com",              //*.k.sohuno.com(需申请)
                             @"data.k.sohuno.com",
                             @"datain.k.sohuno.com",
                             @"code.k.sohuno.com",
                             
                             //增加广告的也支持了
                             //SNLinks_Domain_TAdrd,
                             
                             SNLinks_Domain_Ldd             // 网络诊断第二步
                             ];
    
    for (NSString *urlScheme in hostArray) {
        if(YES == [scheme isEqualToString:urlScheme]){
            return YES;
        }
    }
    
    return NO;
}


+ (BOOL)testModeEnabled
{
    return [SNPreference sharedInstance].testModeEnabled;
}

+ (NSString *)rootUrl:(NSString *)url
{
    NSString *root = [SNPreference sharedInstance].testModeEnabled ? [SNPreference sharedInstance].basicAPIDomain : SNLinks_Domain_ProductDomain;
    NSString *scheme = @"http";
    if ([SNUtility getHttpsSwitchStatus]) {
        if([self isNeedToChangeHttpsHost:root]){
            scheme = @"https";
        }
    }
    return [NSString stringWithFormat:@"%@://%@/%@", scheme, root, url];
}

+ (NSString *)circleRootUrl:(NSString *)url
{
    NSString *root = [SNPreference sharedInstance].testModeEnabled ? [SNPreference sharedInstance].circleAPIDomain : SNLinks_Domain_SnsK;
    
    NSString *scheme = @"http";
    if ([SNUtility getHttpsSwitchStatus]) {
        if([self isNeedToChangeHttpsHost:root]){
            scheme = @"https";
        }
    }
     
    return [NSString stringWithFormat:@"%@://%@/%@",scheme, root, url];
}

//+ (NSString *)liveRootUrl:(NSString *)url
//{
//    NSString *root = [SNPreference sharedInstance].testModeEnabled ? [SNPreference sharedInstance].basicAPIDomain : SNLinks_Domain_ProductDomain;
//    NSString *scheme = @"http";
//    if ([SNUtility getHttpsSwitchStatus]) {
//        if([self isNeedToChangeHttpsHost:root]){
//            scheme = @"https";
//        }
//    }
//    return [NSString stringWithFormat:@"%@://%@/%@", scheme, root, url];
//
//}

+ (NSString *)baseUrlWithDomain:(NSString *)domain {
    NSString *scheme = @"http";
    if ([SNUtility getHttpsSwitchStatus]) {
        if([self isNeedToChangeHttpsHost:domain]){
            scheme = @"https";
        }
    }
    return [NSString stringWithFormat:@"%@://%@/", scheme, domain];
}

+ (NSString *)domain:(NSString *)domain url:(NSString *)url
{
    NSString *scheme = @"http";
    if ([SNUtility getHttpsSwitchStatus]) {
        if([self isNeedToChangeHttpsHost:domain]){
            scheme = @"https";
        }
    }
    if (url.length == 0) {
        url = @"";
    }
    return [NSString stringWithFormat:@"%@://%@/%@", scheme, domain, url];
}

+ (NSString *)productId {
    if ([SNPreference sharedInstance].productId.length > 0) {
        return [SNPreference sharedInstance].productId;
    }

    return kProductID;
}

+ (NSString *)encodedBundleID {
    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleIdentifier];
    NSString *encodedBundleID = [[bundleID dataUsingEncoding:NSUTF8StringEncoding] base64String];
    return encodedBundleID;
}

#pragma mark - Server Services URL
+ (NSString *)starDotGifParamString {
    //移动端ID
    NSString *cid = [[SNClientRegister sharedInstance].uid copy];
    cid = (cid.length > 0) ? cid : @"";
    //移动端系统平台
    NSString *platform = @"ios";
    //App版本号
    NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey] copy];
    version = (version.length > 0) ? version : @"other";
    //渠道号
    NSString *marketID = [NSString stringWithFormat:@"%d", [SNUtility marketID]];
    marketID = (marketID.length > 0) ? marketID : @"";
    //网络状态
    NSString *network = [[[SNUtility getApplicationDelegate] currentNetworkStatusString] copy];
    network = (network.length > 0) ? network : @"";
    //产品ID
    NSString *productID = [[SNAPI productId] copy];
    productID = (productID.length > 0) ? productID : @"";
    //gbcode(通过location.go获取)
    //上报时的时间戳
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    
    //AbTest
    SNAppABTestStyle abMode = [SNUtility AbTestAppStyle];
    NSString *param = [NSString stringWithFormat:@"c=%@&p=%@&v=%@&h=%@&net=%@&u=%@&gbcode=%@&t=%f&abmode=%@",
                       cid,
                       platform,
                       version,
                       marketID,
                       network,
                       productID,
                       [SNUserLocationManager sharedInstance].currentChannelGBCode,
                       interval * 1000,
                       [NSNumber numberWithInteger:abMode]];
    return param;
}

+ (NSString *)aDotGifUrlWithParameters:(NSString *)parameters {
    NSString *finalUrl = [NSString stringWithFormat:SNLinks_Path_DotGifBaseUrl,@"a"];
    if (parameters.length > 0) {
        finalUrl = [NSString stringWithFormat:@"%@?%@&%@", finalUrl, [SNAPI starDotGifParamString], parameters];
    } else {
        finalUrl = [NSString stringWithFormat:@"%@?%@", finalUrl, [SNAPI starDotGifParamString]];
    }
    return [SNUtility aesEncryptWithString:finalUrl];
}

//+ (NSString *)cDotGifUrlPrefixWithParameters:(NSString *)parameters {
//    NSString *finalUrl = nil;
//    if (parameters.length > 0) {
//        finalUrl = [NSString stringWithFormat:@"%@?%@&%@", SNLinks_Pick_cDotGifBaseUrl, [SNAPI starDotGifParamString], parameters];
//    } else {
//        finalUrl = [NSString stringWithFormat:@"%@?%@", SNLinks_Pick_cDotGifBaseUrl, [SNAPI starDotGifParamString]];
//    }
//    return [SNUtility aesEncryptWithString:finalUrl];
//}

//+ (NSString *)nDotGifUrlPrefixWithParameters:(NSString *)parameters {
//    NSString *finalUrl = nil;
//    if (parameters.length > 0) {
//        finalUrl = [NSString stringWithFormat:@"%@?%@&%@", SNLinks_Pick_nDotGifBaseUrl, [SNAPI starDotGifParamString], parameters];
//    }
//    else {
//        finalUrl = [NSString stringWithFormat:@"%@?%@", SNLinks_Pick_nDotGifBaseUrl, [SNAPI starDotGifParamString]];
//    }
//    return [SNUtility aesEncryptWithString:finalUrl];
//}

//+ (NSString *)usrDotGifUrlWithStatData:(SNAppUsageStatData *)statData {
//    NSString *startfrom = @"icon";
//    if (statData.appLaunchingRefer == SNAppLaunchingRefer_iCon) {
//        startfrom = @"icon";
//    } else if (statData.appLaunchingRefer == SNAppLaunchingRefer_Push) {
//        startfrom = @"push";
//    } else {
//        startfrom = @"other";
//    }
//    
//    NSString *finalUrl = [NSString stringWithFormat:@"%@?%@&objType=%@&lastetime=%f&stime=%f&etime=%f&inchannel=%f&invedio=%f&infriend=%f&incontent=%f&startfrom=%@",
//                          SNLinks_Pick_usrDotGifBaseUrl,
//                          [SNAPI starDotGifParamString],
//                          kUserStartAPPType,
//                          statData.lastTimeResigningTimeInSec*1000,
//                          statData.launchingTimeInSec*1000,
//                          statData.currentTimeResigningTimeInSec*1000,
//                          statData.rollingNewsStayDurInSec*1000,
//                          statData.videosStayDurInSec*1000,
//                          statData.myCenterStayDurInSec*1000,
//                          statData.newsContentStayDurInSec*1000,
//                          startfrom
//                          ];
//    return [SNUtility aesEncryptWithString:finalUrl];
//}
//
//+ (NSString *)reqstatDotGifWithParamers:(NSString *)parameters {
//    NSString *finalUrl = nil;
//    if (parameters.length > 0) {
//        finalUrl = [NSString stringWithFormat:@"%@?%@&%@", SNLinks_Pick_reqstatDotGifBaseUrl, [SNAPI starDotGifParamString], parameters];
//    } else {
//        finalUrl = [NSString stringWithFormat:@"%@?%@", SNLinks_Pick_reqstatDotGifBaseUrl, [SNAPI starDotGifParamString]];
//    }
//    return [SNUtility aesEncryptWithString:finalUrl];
//}

@end
