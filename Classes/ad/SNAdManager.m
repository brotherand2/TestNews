//
//  SNAdManager.m
//  sohunews
//
//  Created by Xiang Wei Jia on 2/25/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAdManager.h"
#import "STADManagerForNews.h"
#import "SNAdTemplateFactory.h"
#import "SNAdBaseController.h"
#import "SNAdData.h"
#import "SNADReport.h"

#define UserData @"iOSNewsClientUserData"

@interface SNAdManager() <SNADManagerDelegate>

// key: SNAdBase.sdkArg.hash
// value: SNAdBase
@property (nonatomic, retain) NSMutableDictionary *adBaseViewCache;
@property (nonatomic) BOOL enableSDK;

@end

@implementation SNAdManager

- (instancetype)init
{
    self = [super init];
    
    if (nil != self)
    {
        _adBaseViewCache = [NSMutableDictionary new];
        _enableSDK = YES;
        
        [[SNADManager sharedSTADManager] setDelegateObject:self];
    }
    
    return self;
}

- (void)dealloc
{
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SNAdManager *manager = nil;
    
    dispatch_once(&onceToken, ^{
        manager = [[SNAdManager alloc] init];
    });
    
    return manager;
}

+(SNAdBaseController *) requestAdWithSpaceId:(NSString *)spaceId
                                 clientParam:(NSDictionary *)param
                                  adDelegate:(id<SNAdDelegate>)delegate
                                      adInfo:(NSDictionary *)adInfo
                                        root:(NSDictionary *)root
                                     channel:(NSString *)channel
                                      adType:(ReportDataAdType)type
                                         tab:(ReportDataAdTab)tab
{
    if (![SNAdManager sharedInstance].enableSDK)
    {
        return nil;
    }
    
    if ([spaceId length] == 0)
    {
        return nil;
    }
    
    SNAdBaseController *ad = [SNAdTemplateFactory loadSDKTemplateWithSpaceId:spaceId delegate:delegate filter:nil];
    
    if (nil == ad)
    {
        return nil;
    }
    
    NSMutableDictionary *finalParam = [[NSMutableDictionary alloc] init];
    
    [SNADReport parseAdDictionary:param value:finalParam];

    CGSize adps = ad.adps;
    
    // 客户端广告尺寸，给服务器适配用. 规则是 宽x10000 + 高  给服务器去解析
    long long size = adps.width * 10000 + adps.height;
    
    [finalParam setObject:[NSString stringWithFormat:@"%lld", size] forKey:@"adps"];
    
    // 客户端固定写死 表示移动端广告
    [finalParam setObject:@"1" forKey:@"apt"];
    
    // 测试模式
    if ([SNPreference sharedInstance].testModeEnabled)
    {
        [finalParam setObject:@"2" forKey:@"bucketid"];
    }
    
    // 开始生成上报数据
    ad.reportId = [SNADReport parseSDKData:adInfo root:root channel:channel adType:type tab:tab];
    
    SNReportAdData *report = [SNADReport reportData:ad.reportId];
    
    if (nil != report)
    {
        [SNADReport addSpaceId:ad.reportId spaceId:spaceId];
        [SNADReport addClientParams:ad.reportId params:finalParam];
        
        [finalParam addEntriesFromDictionary:report.serverParam];
    }
    
    // 这个UserData不需要加到上报数据里，所以放到report创建之后加入到finalParam
    [finalParam setObject:ad forKey:UserData];
    
    // 这里原来是放的view的实际尺寸，而不是adps尺寸。现在这么写是因为返回的view对我来说根本没用，但是参数要传，就随便给个
    CGRect adRect = CGRectMake(0, 0, adps.width, adps.height);
    
    UIView *view = [[SNADManager sharedSTADManager] getNewsMraidWithFrame:adRect
                                                                 andParam:finalParam
                                                               andIsNight:NO
                                                             andIsNonepic:NO
                                                             shouldRender:NO];

    if (!ad.noAd && nil != view)
    {
        [SNADReport addSdkView:ad.reportId sdkView:view];
        [[SNAdManager sharedInstance].adBaseViewCache setObject:ad forKey:@(view.hash)];
        
        return ad;
    }
    else
    {
        return nil;
    }

}

+(SNAdBaseController *) requestAdWithSpaceId:(NSString *)spaceId param:(NSDictionary *)param adDelegate:(id<SNAdDelegate>)delegate
{
    if (![SNAdManager sharedInstance].enableSDK)
    {
        return nil;
    }
    
    if ([spaceId length] == 0)
    {
        return nil;
    }
    
    SNAdBaseController *ad = [SNAdTemplateFactory loadSDKTemplateWithSpaceId:spaceId delegate:delegate filter:nil];
    
    if (nil == ad)
    {
        return nil;
    }
    
    NSMutableDictionary *finalParam = [NSMutableDictionary dictionaryWithDictionary:param];
    CGSize adps = ad.adps;
    
    // 客户端广告尺寸，给服务器适配用. 规则是 宽x10000 + 高  给服务器去解析
    long long size = adps.width * 10000 + adps.height;
    
    [finalParam setObject:[NSString stringWithFormat:@"%lld", size] forKey:@"adps"];
    
    // 客户端固定写死 表示移动端广告
    [finalParam setObject:@"1" forKey:@"apt"];
    
    // 测试模式
    if ([SNPreference sharedInstance].testModeEnabled)
    {
        [finalParam setObject:@"2" forKey:@"bucketid"];
    }
    
    // 这个UserData不需要加到上报数据里，所以放到report创建之后加入到finalParam
    [finalParam setObject:ad forKey:UserData];
    
    // 这里原来是放的view的实际尺寸，而不是adps尺寸。现在这么写是因为返回的view对我来说根本没用，但是参数要传，就随便给个
    CGRect adRect = CGRectMake(0, 0, adps.width, adps.height);
   
    UIView *view = [[SNADManager sharedSTADManager] getNewsMraidWithFrame:adRect
                                                                 andParam:finalParam
                                                               andIsNight:NO
                                                             andIsNonepic:NO
                                                             shouldRender:NO];
    
    if (!ad.noAd && nil != view)
    {
        [[SNAdManager sharedInstance].adBaseViewCache setObject:ad forKey:@(view.hash)];
        
        return ad;
    }
    else
    {
        return nil;
    }
}

#pragma mark 广告SDK的delegate实现

/*! @brief 新闻开机&图文广告 成功展示
 *
 * @param itemspaceid广告位id
 *
 */
-(void)stadAdViewDidAppearForNewsWithItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview
{
    // 这里原来有大量逻辑，都被我删了，重构掉了

}

/*! @brief 新闻开机&图文广告 动作报告方法
 *
 * @param actionType为动作类型
 * @param itemspaceid广告位id
 *
 */
- (void)stadActionForNews:(kStadActionForNewsType)actionType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview
{
}

/*! @brief 新闻开机&图文广告错误报告方法
 *
 * @param errorType为错误类型
 * @param itemspaceid广告位id
 *
 */
- (void)stadErrorForNews:(kStadErrorForNewsType)errorType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview andAdParam:(NSDictionary *)params
{
    [_adBaseViewCache removeObjectForKey:@(adview.hash)];
    
    SNAdBaseController *ad = params[UserData];
    
    // 这个![ad isKindOfClass:[SNAdBaseController class]]的逻辑是因为重构的时候，
    // 老广告模块的delegate和本模块的delegate同时存在，为了防止本模块处理老广告模块的数据加上的
    // 等本广告模块稳定了，删除了老广告模块的是偶，这个isKindOfClass就可以删了
    if (nil == ad || ![ad isKindOfClass:[SNAdBaseController class]])
    {
        return ;
    }
    
    ad.noAd = YES;
    
    if (errorType == kStadErrorForNewsTypeNodata)
    {
        [ad reportEmpty];
        [ad empty];
    }
    
    // 出错了，上报数据可以丢弃了。
    [SNADReport removeUnusedAd:ad.reportId];
}

/*! @brief 新闻开机&图文广告点击方法
 *
 * 该方法会将SDK无法处理点击信息返回给App处理
 * @param clickThrough点击信息
 * @param itemspaceid广告位id
 *
 */
- (void)stadClickForNews:(NSString *)clickThrough andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview
{

}

/*! @brief 新闻开机&图文广告 文本信息回调方法
 *
 * 该方法会将SDK处理后的文本信息返回给App
 * @param textInfo文本信息
 * @param itemspaceid广告位id
 *
 */
- (void)stadTextInfoForNews:(NSDictionary *)textinfo andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview
{
    SNAdBaseController *ad = [self.adBaseViewCache objectForKey:@(adview.hash)];

    if (nil == ad)
    {
        return ;
    }
    
    [_adBaseViewCache removeObjectForKey:@(adview.hash)];
    
    [SNADReport addSdkParam:ad.reportId sdkParam:textinfo];
    [ad.adData parseSDKData:textinfo];
    
    // 加载成功，开始上报
    [SNADReport reportLoad:ad.reportId];
    
    dispatch_async(dispatch_get_main_queue(), ^()
    {
        [ad updateAdView];
    });
}

+ (void)setSDKEnable:(NSString *)enable
{
    [SNAdManager sharedInstance].enableSDK = [@"1" isEqualToString:enable];
    [SNUserDefaults setObject:enable forKey:kSNAdvertiseEnableKey];
}

+ (BOOL)isSDKEnable
{
    return [SNAdManager sharedInstance].enableSDK;
}

+ (NSMutableDictionary *)paramFromSNAdInfo:(SNAdInfo *)adInfo newsId:(NSString *)newsId
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    if (nil != adInfo.filterInfo && adInfo.filterInfo.count > 0)
    {
        [param setValuesForKeysWithDictionary:adInfo.filterInfo];
    }
    
    param[@"newsid"] = newsId;
    param[@"spaceid"] = adInfo.adSpaceId;
    param[@"gbcode"] = adInfo.gbcode;
    param[@"newschannel"] = adInfo.newsChannel;
    param[@"appchannel"] = adInfo.appChannel;
    
    return param;
}

+ (NSString *)urlByAppendingAdParameter:(NSString *)url {

    NSString * newUrl = url;
    
    ///设备唯一标识参数们
    NSDictionary * adParameter = [[SNADManager sharedSTADManager] getStadDeviceInfo];
    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:adParameter];
    
    ///mac
    NSString *macAddress = [[UIDevice currentDevice] macAddress];
    [parameterDic setObject:macAddress?:@"" forKey:@"mac"];
    
    ///屏幕密度
    NSString *density = [NSString stringWithFormat:@"%f",[UIScreen mainScreen].scale];
    [parameterDic setObject:density?:@"" forKey:@"density"];
    
    NSString *network = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    [parameterDic setObject:network?:@"" forKey:@"nets"];
    
    ///运营商
    [parameterDic setObject:[[self getCarrierName] URLEncodedString]?:@"" forKey:@"carrier"];
    
    if (parameterDic) {
        newUrl = [newUrl stringByAppendingString:[parameterDic toUrlString]];
    }
    
    return newUrl;
}

//移动服务提供商
+ (NSString *)getCarrierName {
    NSString *currentCountry = [[SNUtility sharedUtility] getCarrierName];
    return currentCountry;
}

+ (NSDictionary *)addAdParameters {
    ///设备唯一标识参数们
    NSDictionary * adParameter = [[SNADManager sharedSTADManager] getStadDeviceInfo];
    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:adParameter];
    
    ///mac
    NSString *macAddress = [[UIDevice currentDevice] macAddress];
    [parameterDic setObject:macAddress?:@"" forKey:@"mac"];
    
    ///屏幕密度
    NSString *density = [NSString stringWithFormat:@"%f",[UIScreen mainScreen].scale];
    [parameterDic setObject:density?:@"" forKey:@"density"];
    
    NSString *network = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    [parameterDic setObject:network?:@"" forKey:@"nets"];
    
    ///运营商
    [parameterDic setObject:[[self getCarrierName] URLEncodedString]?:@"" forKey:@"carrier"];

    return parameterDic;
}

@end
