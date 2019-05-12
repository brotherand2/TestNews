//
//  SNStatisticsManager.m
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatisticsManager.h"
#import "SNStatTypeObject.h"
#import "SNPickStatisticRequest.h"
#import "SNNewsReportRequest.h"
#import "SNUserManager.h"
#import "SNUserLocationManager.h"

#pragma mark - 私有类-SNShnAdStatRequest
/**
 *  专用于搜狐新闻投放的广告统计的请求类
 */
@interface SNShnAdStatRequest : ASIHTTPRequest
@end

@implementation SNShnAdStatRequest

/**
 *  初始化SNShnAdStatRequest对象
 *
 *  @param newURL 请求地址
 *
 *  @return SNShnAdStatRequest对象
 */
- (id)initWithURL:(NSURL *)newURL {
    NSString *_urlString = [SNUtility addParamP1ToURL:[newURL absoluteString]];
    
    if (self = [super initWithURL:[NSURL URLWithString:_urlString]]) {
        [self setResponseEncoding:NSUTF8StringEncoding];
        [self addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
        [self setNumberOfTimesToRetryOnTimeout:3];
        [self setTimeOutSeconds:10];
    }
	return self;
}
@end

@interface SNStatisticsManager () {
    NSMutableString * _appStartParams;
}

@end

@implementation SNStatisticsManager

static SNStatisticsManager *__instance = nil;

+ (SNStatisticsManager *)shareInstance
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __instance = [[SNStatisticsManager alloc] init];
    });
    return __instance;
}
#pragma mark - Singleton
- (id)init {
    if (__instance) {
        return __instance;
    }
    if(self = [super init]) {
    }
    
    return self;
}

- (void)uploadStaticsEvent:(SNStatInfo *)statInfo
{
    if (!statInfo) {
        return;
    }
    
    // 和于和琪BOSS商定，以后缓存的不再报了  by Cae.
    if (statInfo.isReported && STADDisplayTrackTypeClick != statInfo.adTrackType && STADDisplayTrackTypePlaying != statInfo.adTrackType)
    {
        return ;
    }
    
    Class statTypeObjClass = [SNStatTypeObject classForStatisticsType:statInfo.objLabel];
    SNStatTypeObject *statTypeObj = [[statTypeObjClass alloc] initWithStateInfo:statInfo];
    if (statTypeObj) {
        NSMutableDictionary *dataServerParams = statTypeObj.dataServerParams;
        if (statInfo.itemspaceid.length > 0) {
            [dataServerParams setValue:statInfo.itemspaceid forKey:@"apid"];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[[SNPickStatisticRequest alloc] initWithDictionary:dataServerParams
                                               andStatisticType:PickLinkDotGifTypeC] send:nil failure:nil];
        });
    }
}

/**
 记录APP启动后到频道流内展示各个阶段的时间戳，并上报
 
 @param stage 阶段代号
 t0 应用启动的的时间
 t1 开始请求广告的时间
 t2 loading页广告显示出来的时间
 t3 loading页结束的时间
 t4 新手引导页展示的时间
 t5 新手引导页退出的时间
 t6 进入频道流页的时间
 type = 1 为第一次启动（第一次启动的定义为：单个版本第一次启动时；包含覆盖安装和全新安装的情况）
 */
- (void)recordAppStartStage:(NSString *)stage {
    if ([_appStartParams containsString:stage]) {
        return;
    }
    if (!_appStartParams) {
        _appStartParams = [NSMutableString string];
    }
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    [_appStartParams appendFormat:@"&%@=%@",stage,timestamp];
    if ([stage isEqualToString:@"t6"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL isFirstLoad = [SNUtility getApplicationDelegate].startCount == 1;
            /*lbs_info LBS信息
             carriers 网络运营商
             simulator 模拟器 platformStringForSohuNews
             is_root 是否越狱
             resolution 分辨率 screenSizeStringForSohuNews
             screen_density 屏幕密度
             current_channelid 当前渠道号
             imsi 设备唯一识别号
             idfa iOS设备唯一识别号
             idfv iOS设备唯一识别号
             openudid 设备唯一识别号*/
            UIDevice *currentDevice = [UIDevice currentDevice];
            NSString *simulator = @"";
#if TARGET_IPHONE_SIMULATOR
            simulator = @"simulator";
#else
            simulator = @"Device";
#endif
            //上报
            NSString *baseParamsStr = [NSString stringWithFormat:@"_act=start&_tp=tm&type=%d&p1=%@&pid=%@%@&carriers=%@&simulator=%@&is_root=%d&resolution=%@&screen_density=%f&current_channelid=%d&imsi=%@%@&idfa=%@&idfv=%@&openudid=%@&lbs_info=%@_%@&machineid=%@&os_version=%@", isFirstLoad, [SNUserManager getP1], [SNUserManager getPid], _appStartParams, [[[SNUtility sharedUtility] getCarrierName] URLEncodedString] ? : @"", simulator, [UIDevice isJailbroken], [currentDevice screenSizeStringForSohuNews], [currentDevice getPhysicalPixels], [SNUtility marketID], [[SNUtility sharedUtility] getCountryCode] ? :  @"", [[SNUtility sharedUtility] getNetworkCode] ? : @"", [UIDevice deviceIDFA], [[currentDevice identifierForVendor] UUIDString], [UIDevice deviceUDID], [[SNUserLocationManager sharedInstance] getLongitude], [[SNUserLocationManager sharedInstance] getLatitude], [currentDevice platformForSohuNews], [currentDevice systemVersion]];

            baseParamsStr = [self addWifiSSIDForUrl:baseParamsStr];
            
            NSString *urlString = [SNAPI aDotGifUrlWithParameters:baseParamsStr];
            [[[SNNewsReportRequest alloc] initWithUrl:urlString] send:nil failure:nil];
        });
    }

}


- (NSString *)addWifiSSIDForUrl:(NSString *)url {
    NSDictionary *dict = [SNUtility getWifiSSIDInfo];
    if (!dict) {
        return url;
    }
    NSString *ssid = [dict stringValueForKey:@"SSID" defaultValue:nil];
    NSString *bssid = [dict stringValueForKey:@"BSSID" defaultValue:nil];
    
    if (ssid) {
        url = [url stringByAppendingFormat:@"&wifi_ssid=%@", ssid];
    }
    if (bssid) {
        url = [url stringByAppendingFormat:@"&wifi_bssid=%@", bssid];
    }
    if ([[UIDevice currentDevice] macAddress]) {
        url = [url stringByAppendingFormat:@"&wifi_mac=%@", [[UIDevice currentDevice] macAddress]];
    }
    
    return url;
}

@end
