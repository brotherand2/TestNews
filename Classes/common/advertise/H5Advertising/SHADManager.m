//
//  SHADManager.m
//  LiteSohuNews
//
//  Created by H on 16/1/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHADManager.h"
#import "SHADConfigs.h"
//#import "StorageUserDefault.h"
//#import "UIDevice+KCHardware.h"
#import "SNUserManager.h"
#import "SNPickStatisticRequest.h"
#import <SCMobileAds/SCMobileAds.h>
#import "SNUserLocationManager.h"

@interface SHADManager ()<SNADManagerDelegate, SCADNativeAdDelegate>{
    NSString * _currentSpaceId;
}

@property (nonatomic, strong) NSDictionary * originalData;//JS传过来的请求数据，拿到广告后回传回去。

@property (nonatomic, strong) NSMutableDictionary * AdCaches;//广告池

@property (nonatomic, strong) JsKitClient * jsClient;

@property (nonatomic, strong) SCADArticleAd *articalAd;

@property (nonatomic, strong) NSMutableDictionary *cachedAdCarriers;

@end

@implementation SHADManager

+ (SHADManager *)sharedManager {
    static SHADManager *__sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sInstance = [[self alloc] init];
    });
    return __sInstance;
}
+ (NSString *)getSpaceIdWithAdInfo:(NSDictionary *)info{
    if (!info || [info isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString * itemspaceidStr = nil;
    id itemspaceid = [info objectForKey:@"itemspaceid"];
    if (itemspaceid && [itemspaceid isKindOfClass:[NSNumber class]]) {
        itemspaceidStr = [(NSNumber *)itemspaceid stringValue];
    }else if (itemspaceid && [itemspaceid isKindOfClass:[NSString class]]){
        itemspaceidStr = (NSString *)itemspaceid;
    }
    return itemspaceidStr;
}

- (instancetype)init {
    if (self = [super init]) {
        [[SNADManager sharedSTADManager] setDelegateObject:self];
        self.AdCaches = [NSMutableDictionary dictionary];
        self.articleAdDic = [NSMutableDictionary dictionary];
        self.itemspaceidArr = [NSMutableArray array];
    }
    return self;
}

- (NSMutableDictionary *)cachedAdCarriers {
    if (!_cachedAdCarriers) {
        _cachedAdCarriers = [[NSMutableDictionary alloc] init];
    }
    return _cachedAdCarriers;
}

#pragma mark - public
/**
 *  请求SDK广告
 */
- (void)getAdDataFromSDKWithInfo:(NSDictionary *)info completed:(StadTextInfoForNewsBlock)stadTextInfoForNewsBlock{
    
    if (!info) {
        return;
    }
    
    self.stadTextInfoForNewsBlock = stadTextInfoForNewsBlock;
    
    NSDictionary * adinfo = [self adInfoWithOriginInfo:info];
    
    SHADReportData * adData = [[SHADReportData alloc] initWithId:[_currentSpaceId integerValue] adType:adReportSDK adInfo:adinfo];
    
    [self.AdCaches setObject:adData forKey:_currentSpaceId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SNADManager sharedSTADManager] getNewsMraidWithFrame:CGRectMake(0, 0, 320, 100) andParam:adinfo andIsNight:[self isNightMode] andIsNonepic:[self isNoPicMode] shouldRender:YES];
    });
}

- (void)getAdDataFromSDKWithInfo:(NSDictionary *)info jsKitClient:(JsKitClient *)client {
    if (!info) {
        return;
    }
    self.jsClient = client;
    NSDictionary * adinfo = [self adInfoWithOriginInfo:info];
    
    SHADReportData * adData = [[SHADReportData alloc] initWithId:[_currentSpaceId integerValue] adType:adReportSDK adInfo:adinfo];
    
    [self.AdCaches setObject:adData forKey:_currentSpaceId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SNADManager sharedSTADManager] getNewsMraidWithFrame:CGRectMake(0, 0, 320, 100) andParam:adinfo andIsNight:[self isNightMode] andIsNonepic:[self isNoPicMode] shouldRender:YES];
    });
}

- (void)getAdDataFromSDKWithInfo:(NSDictionary *)info itemspaceid:(NSString *)itemspaceid {
    NSMutableDictionary * filterInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    
    CGRect adViewFrame = [self configAdFrameByAdSpaceId:itemspaceid];
    [self addConfigParamsAndFrame:adViewFrame toParams:filterInfo];
    
    if ([itemspaceid isEqualToString:kSNAdSpaceIdNewsArticleInsertad]) {
        [filterInfo setObject:@"30000001" forKey:@"adps"];
    }
    
    NSDictionary * adinfo = [self adInfoWithOriginInfo:filterInfo];
    
    SHADReportData * adData = [[SHADReportData alloc] initWithId:[itemspaceid integerValue] adType:adReportSDK adInfo:adinfo];
    
    [self.AdCaches setObject:adData forKey:itemspaceid];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SNADManager sharedSTADManager] getNewsMraidWithFrame:adViewFrame andParam:adinfo andIsNight:[self isNightMode] andIsNonepic:[self isNoPicMode] shouldRender:YES];
    });
}

- (void)setAdJsClient:(JsKitClient *)jsClient {
    self.jsClient = jsClient;
}

//请求文章页新品算广告
- (void)getAdDataFromSCADWithInfo:(NSDictionary *)info itemspaceid:(NSString *)itemspaceid {
    
    SCADArticleAd *articleAd = [self creatArticleAdWithInfo:info itemspaceid:itemspaceid];
    
    NSMutableDictionary * filterInfos = [NSMutableDictionary dictionaryWithDictionary:info];
    [filterInfos setObject:articleAd forKey:@"articleAd"];
    
    NSDictionary *adinfo = [self adInfoWithOriginInfo:filterInfos];
    SHADReportData *adData = [[SHADReportData alloc] initWithId:[itemspaceid integerValue] adType:adReportSDK adInfo:adinfo];
    [self.AdCaches setObject:adData forKey:itemspaceid];
    // 广告请求
    [articleAd load];
}

//请求文章页大图浏览新品算广告
- (void)getBigPicAdDataFromSCADWithInfo:(NSDictionary *)info itemspaceid:(NSString *)itemspaceid carrier:(SNAdDataCarrier *)carrier {
    SNAdDataCarrier *ac = (SNAdDataCarrier *)carrier;
    ac.filter = [info objectForKey:@"filterInfo"];
    ac.dataState = SNAdDataStatePending;
    [self.cachedAdCarriers setObject:ac forKey:itemspaceid];

    SCADArticleAd *articleAd = [self creatArticleAdWithInfo:info itemspaceid:itemspaceid];
    NSMutableDictionary * filterInfos = [NSMutableDictionary dictionaryWithDictionary:info];
    [filterInfos setObject:articleAd forKey:@"articleAd"];
    
    NSDictionary *adinfo = [self adInfoWithOriginInfo:filterInfos];
    SHADReportData *adData = [[SHADReportData alloc] initWithId:[itemspaceid integerValue] adType:adReportSDK adInfo:adinfo];
    [self.AdCaches setObject:adData forKey:itemspaceid];
    // 广告请求
    [articleAd load];
}

- (SCADArticleAd *)creatArticleAdWithInfo:(NSDictionary *)info itemspaceid:(NSString *)itemspaceid {
    // 初始化广告
    SCADAdConfiguration *config = [[SCADAdConfiguration alloc] init];
    NSDictionary *filterInfo = [info objectForKey:@"filterInfo"];
    if (filterInfo && [filterInfo isKindOfClass:[NSDictionary class]]) {
        config.newsID = [filterInfo stringValueForKey:@"newsid" defaultValue:@""];
        config.newsChannel = [filterInfo stringValueForKey:@"newschn" defaultValue:@""];
        config.newsPosition = [filterInfo stringValueForKey:@"position" defaultValue:@""];
        config.weMediaID = [filterInfo stringValueForKey:@"subid" defaultValue:@""];
        config.adSource = [filterInfo stringValueForKey:@"adsrc" defaultValue:@""];
        config.adUnitType = [filterInfo stringValueForKey:@"adp_type" defaultValue:@""];
        config.userID = [filterInfo stringValueForKey:@"cid" defaultValue:@""];
        config.geocoding = [filterInfo stringValueForKey:@"debugloc" defaultValue:@""];
        config.appSource = [filterInfo stringValueForKey:@"appchn" defaultValue:@""];
        config.adViewSize = [self configAdSizeByAdApaceId:itemspaceid];
        if ([[SNUserLocationManager sharedInstance] getLatitude].length > 0 && [[SNUserLocationManager sharedInstance] getLongitude].length > 0) {
            config.coordinate = CLLocationCoordinate2DMake([[SNUserLocationManager sharedInstance] getLatitude].doubleValue , [[SNUserLocationManager sharedInstance] getLongitude].doubleValue);
        }
    }
    SCADArticleAd *articleAd = [[SCADArticleAd alloc] initWithAdUnitID:itemspaceid configuration:config];
    articleAd.delegate = self;
    return articleAd;
}

#pragma mark --  SCADNativeAdDelegate
- (void)nativeAdDidSuccessToReceiveAd:(SCADNativeAd *)nativeAd {
    NSString *itemspaceid = nativeAd.adUnitID ? : @"";
    if (itemspaceid.length > 0) {
        if ([itemspaceid isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] || [itemspaceid isEqualToString:kSNAdSpaceIdGroupPicRecommendPenult] || [itemspaceid isEqualToString:kSNAdSpaceIdGroupPicRecommendPenultTest] || [itemspaceid isEqualToString:kSNAdSpaceIdSlideshowTail]) {
            SNAdDataCarrier *ac = [self.cachedAdCarriers objectForKey:itemspaceid];
            if (nil == ac)
            {
                return;
            }
            
            NSDictionary * a_textInfo = [self adInfoWithSCADNativeAd:nativeAd itemSpaceID:itemspaceid isBigPic:YES];
            [ac onlySetAdInfo:a_textInfo];
            
            ac.dataState = SNAdDataStateReady;

            // 直接去回调
            if (ac.delegate && [ac.delegate respondsToSelector:@selector(adViewDidAppearWithCarrier:)])
            {
                [ac.delegate adViewDidAppearWithCarrier:ac];
            }
        } else {
            NSDictionary * a_textInfo = [self adInfoWithSCADNativeAd:nativeAd itemSpaceID:itemspaceid isBigPic:NO];
            
            [self.articleAdDic setObject:a_textInfo forKey:itemspaceid];
            
            if (self.jsClient && [self.itemspaceidArr containsObject:itemspaceid]) {
                [self.jsClient evaluatingJavaScriptFunction:@"setArticleAd" argsCount: 2, a_textInfo, itemspaceid];
            }
        }
        SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
        NSDictionary *serverParam = [adData toStatisticsReportData:STADDisplayTrackTypeLoadImp serverParam:adData.serverParam];
        [self uploadStaticsEvent:serverParam];
        [adData report:STADDisplayTrackTypeLoadImp];
    }
}

- (NSDictionary *)adInfoWithSCADNativeAd:(SCADNativeAd *)nativeAd itemSpaceID:(NSString *)itemspaceid isBigPic:(BOOL)isBig {
    SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
    NSString *iconText = nil;
    if (adData && [adData.sdkParam objectForKey:@"iconText"]) {
        iconText = [adData.sdkParam objectForKey:@"iconText"];
    }
    NSMutableDictionary * a_textInfo = [NSMutableDictionary dictionary];
    [a_textInfo setObject:itemspaceid forKey:@"itemspaceid"];
    [a_textInfo setObject:nativeAd.properties[kSCADAdPropertyText] ? : @"" forKey:@"ad_txt"];
    [a_textInfo setObject:nativeAd.properties[kSCADAdPropertyImageUrl] ? : @"" forKey:isBig ? @"image_url" : @"ad_image"];
    [a_textInfo setObject:nativeAd.properties[kSCADAdPropertyLandingPage] ? : @"" forKey:isBig ? @"click_url" : @"ad_click"];
    NSString *dsp_source = [NSString stringWithFormat:@"%@%@", nativeAd.properties[kSCADAdPropertyDspSource] ? : @"", iconText ? : @""];
    [a_textInfo setObject:dsp_source forKey:@"iconText"];
    
    return a_textInfo;
}

- (void)nativeAd:(SCADNativeAd *)nativeAd didFailToReceiveAdWithError:(SCADError *)error {
    NSString *itemspaceid = nativeAd.adUnitID ? : @"";
    if (itemspaceid.length > 0) {
        if ([itemspaceid isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] || [itemspaceid isEqualToString:kSNAdSpaceIdGroupPicRecommendPenultTest] || [itemspaceid isEqualToString:kSNAdSpaceIdSlideshowTail]) {
            SNAdDataCarrier *ac = [self.cachedAdCarriers objectForKey:itemspaceid];
            ac.dataState = SNAdDataStateFailed;
        }
        NSDictionary * adTextInfo = [self adaptResultAdTextInfo:nil iconText:nil itemspaceid:itemspaceid];
        [self.articleAdDic setObject:adTextInfo forKey:itemspaceid];
        
        if (self.jsClient && [self.itemspaceidArr containsObject:itemspaceid]) {
            [self.jsClient evaluatingJavaScriptFunction:@"setArticleAd" argsCount:2,adTextInfo,itemspaceid];
        }
        if (error.code == SCADErrorTypeNullAd) { //新品算空广告c.gif统计
            SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
            NSDictionary *serverParam = [adData toStatisticsReportData:STADDisplayTrackTypeNullAD serverParam:adData.serverParam];
            [self uploadStaticsEvent:serverParam];
        }
        [self.AdCaches removeObjectForKey:itemspaceid];
    }
}

- (void)reportForAdLoadImpTrackingWithItemSpaceID:(NSString *)itemspaceid {
    if ([itemspaceid isEqualToString:@"12232"] || [itemspaceid isEqualToString:@"12237"]|| [itemspaceid isEqualToString:@"12434"]|| [itemspaceid isEqualToString:@"12791"] || [itemspaceid isEqualToString:@"15681"]) {
        SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
        [[SNADManager sharedSTADManager] stadLoadImpTrackingForNews:adData.sdkView andParam:adData.sdkParam];
        
        NSDictionary *serverParam = [adData toStatisticsReportData:STADDisplayTrackTypeLoadImp serverParam:adData.serverParam];
        [self uploadStaticsEvent:serverParam];
        
        [adData report:STADDisplayTrackTypeLoadImp];
    }
}

- (void)reportForAdImpTrackingWithItemSpaceID:(NSString *)itemspaceid {
    if (itemspaceid && itemspaceid.length > 0) {
        SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
        if (!adData.isReportedExposure) {
            if ([adData.serverParam[@"original"] isEqualToString:@"1"]) {
                SCADArticleAd *articleAd = [adData.sdkParam objectForKey:@"articleAd"];
                if (articleAd) {
                    [articleAd adPresented];
                }
            } else {
                [[SNADManager sharedSTADManager] stadImpTrackingForNews:adData.sdkView andParam:adData.sdkParam];
            }
            NSDictionary *serverParam = [adData toStatisticsReportData:STADDisplayTrackTypeImp serverParam:adData.serverParam];
            [self uploadStaticsEvent:serverParam];
            
            [adData report:STADDisplayTrackTypeImp];
        }
    }
}

- (void)reportForAdNullTrackingWithItemSpaceID:(NSString *)itemspaceid {
    if ([itemspaceid isEqualToString:@"12232"] || [itemspaceid isEqualToString:@"12237"]|| [itemspaceid isEqualToString:@"12434"]|| [itemspaceid isEqualToString:@"12791"] || [itemspaceid isEqualToString:@"15681"]) {
        SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
        [[SNADManager sharedSTADManager] stadNullADTrackingForNews:adData.sdkView andParam:adData.sdkParam];
        
        NSDictionary *serverParam = [adData toStatisticsReportData:STADDisplayTrackTypeNullAD serverParam:adData.serverParam];
        [self uploadStaticsEvent:serverParam];
        
        [adData report:STADDisplayTrackTypeNullAD];
    }
}

- (void)reportForAdClickTrackingWithItemSpaceID:(NSString *)itemspaceid {
    if (itemspaceid && itemspaceid.length > 0) {
        SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
        if ([adData.serverParam[@"original"] isEqualToString:@"1"]) {
            SCADArticleAd *articleAd = [adData.sdkParam objectForKey:@"articleAd"];
            if (articleAd) {
                [articleAd adClicked];
            }
        } else {
            [[SNADManager sharedSTADManager] stadClickTrackingForNews:adData.sdkView andParam:adData.sdkParam];
        }
        NSDictionary *serverParam = [adData toStatisticsReportData:STADDisplayTrackTypeClick serverParam:adData.serverParam];
        [self uploadStaticsEvent:serverParam];
        
        [adData report:STADDisplayTrackTypeClick];
    }
}

- (void)reportForAdCloseTrackingWithItemSpaceID:(NSString *)itemspaceid {
    if ([itemspaceid isEqualToString:@"15681"]) {
        SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
        if ([adData.serverParam[@"original"] isEqualToString:@"1"]) {
            SCADArticleAd *articleAd = [adData.sdkParam objectForKey:@"articleAd"];
            [articleAd adClosed];
        } else {
            [[SNADManager sharedSTADManager] stadCloseImpTrackingForNews:adData.sdkView andParam:adData.sdkParam];
        }
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_close&_tp=clk&apid=%@&newsId=%@&channelid=%@", itemspaceid, [adData.serverParam objectForKey:@"newsid"], [adData.serverParam objectForKey:@"newschn"]]];
    }
}

- (void)uploadStaticsEvent:(NSDictionary *)statInfo
{
    if (!statInfo) {
        return;
    }

    @autoreleasepool {
        dispatch_queue_t default_background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        dispatch_async(default_background_queue, ^{
            
            [[[SNPickStatisticRequest alloc] initWithDictionary:statInfo
                                               andStatisticType:PickLinkDotGifTypeC] send:nil failure:nil];
        });
    }
}

#pragma mark - private
- (NSDictionary *)adInfoWithOriginInfo:(NSDictionary *)originInfo {
    
    if (!originInfo) {
        return nil;
    }
    
    self.originalData = originInfo;
    
    /**
     *  debugloc bucketid newsid apt sv adps itemspaceid <传给SDK需要是字符串类型的字段>
     */
    NSMutableDictionary * adInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary * filterInfo = [originInfo objectForKey:@"filterInfo"];
    
    /**
     *  bucketid  只有测试服有，写死的 @"2"
     */
    NSString * bucketidStr = nil;
    id bucketid = filterInfo[@"bucketid"];
    if (bucketid && [bucketid isKindOfClass:[NSNumber class]]) { //js传过来的是number类型，与sdk解析的string类型不匹配，转一下。
        bucketidStr = [(NSNumber *)bucketid stringValue];
    }else if (bucketid && [bucketid isKindOfClass:[NSString class]]){
        bucketidStr = (NSString *)bucketid;
    }
    if (bucketidStr.length > 0) {
        [adInfo setObject:bucketidStr forKey:@"bucketid"];
    }
    
    /**
     *  adps    比如：这个广告位是 300 x 200。
     *          那adps 对应的value 就是 300 * 10000 + 200。
     *          那最后 adps 就是 3000200
     */
    NSString * adpsStr = nil;
    id adps = [originInfo objectForKey:@"adps"];
    if (adps && [adps isKindOfClass:[NSNumber class]]) {
        adpsStr = [(NSNumber *)adps stringValue];
    }else if (adps && [adps isKindOfClass:[NSString class]]){
        adpsStr = (NSString *)adps;
    }
    if (adpsStr.length > 0) {
        [adInfo setObject:adpsStr forKey:@"adps"];
    }
    
    NSString * adIdStr = nil;
    id adId = [originInfo objectForKey:@"adId"];
    if (adId && [adId isKindOfClass:[NSNumber class]]) {
        adIdStr = [(NSNumber *)adId stringValue];
    }else if (adId && [adps isKindOfClass:[NSString class]]){
        adIdStr = (NSString *)adId;
    }
    if (adIdStr.length > 0) {
        [adInfo setObject:adIdStr forKey:@"adId"];
    }
    
    /**
     *  newsid 就是newsId，没什么说的，但是要注意传给广告SDK的所有newsid都要小写。
     */
    NSString * newsidStr = nil;
    id newsid = [originInfo objectForKey:@"newsid"];
    if (newsid && [newsid isKindOfClass:[NSNumber class]]) {
        newsidStr = [(NSNumber *)newsid stringValue];
    }else if (newsid && [newsid isKindOfClass:[NSString class]]){
        newsidStr = (NSString *)newsid;
    }
    if (newsidStr.length > 0) {
        [adInfo setObject:newsidStr forKey:@"newsid"];
    }
    
    /**
     *  itemspaceid 广告位id 适配规则与测试服对应的spaceId参考链接：http://confluence.sohuno.com/pages/viewpage.action?pageId=11700691
     */
    NSString * itemspaceidStr = nil;
    id itemspaceid = [originInfo objectForKey:@"itemspaceid"];
    if (itemspaceid && [itemspaceid isKindOfClass:[NSNumber class]]) {
        itemspaceidStr = [(NSNumber *)itemspaceid stringValue];
    }else if (itemspaceid && [itemspaceid isKindOfClass:[NSString class]]){
        itemspaceidStr = (NSString *)itemspaceid;
    }
    if (itemspaceidStr.length > 0) {
        [adInfo setObject:itemspaceidStr forKey:@"itemspaceid"];
        _currentSpaceId = itemspaceidStr;
    }
    
    NSString * debuglocStr = nil;
    id debugloc = [originInfo objectForKey:@"debugloc"];
    if (debugloc && [debugloc isKindOfClass:[NSNumber class]]) {
        debuglocStr = [(NSNumber *)debugloc stringValue];
    }else if (debugloc && [debugloc isKindOfClass:[NSString class]]){
        debuglocStr = (NSString *)debugloc;
    }
    if (debuglocStr.length > 0) {
        [adInfo setObject:debuglocStr forKey:@"debugloc"];//
    }
    
    NSString *gbcodeStr = nil;
    id gbcode = [originInfo objectForKey:@"gbcode"];
    if (gbcode && [gbcode isKindOfClass:[NSNumber class]]) {
        gbcodeStr = [(NSNumber *)gbcode stringValue];
    } else if (gbcode && [gbcode isKindOfClass:[NSString class]]) {
        gbcodeStr = (NSString *)gbcode;
    }
    if (gbcodeStr.length > 0) {
        [adInfo setObject:gbcodeStr forKey:@"gbcode"];
    }
    
    [adInfo setObject:filterInfo[@"adp_type"] forKey:@"adp_type"];
    [adInfo setObject:filterInfo[@"adsrc"] forKey:@"adsrc"];
    [adInfo setObject:filterInfo[@"appchn"] forKey:@"appchn"];
    if ([SNUserManager getCid]) {
        [adInfo setObject:[SNUserManager getCid] forKey:@"cid"];
    }
    [adInfo setObject:filterInfo[@"lc"] ? : @"" forKey:@"lc"];
    [adInfo setObject:filterInfo[@"newschn"] forKey:@"newschn"];
    [adInfo setObject:filterInfo[@"position"] forKey:@"position"];
    [adInfo setObject:filterInfo[@"subid"] forKey:@"subid"];
    [adInfo setObject:filterInfo[@"sv"] forKey:@"sv"];//
    [adInfo setObject:@"1" forKey:@"apt"];// 客户端固定写死 表示移动端广告
    [adInfo setObject:filterInfo[@"iconText"] forKey:@"iconText"];
    [adInfo setObject:filterInfo[@"debugloc"] forKey:@"debugloc"];
    [adInfo setObject:[filterInfo stringValueForKey:@"original" defaultValue:@""] forKey:@"original"];
    
    NSString * newsCate = [originInfo objectForKey:@"newscate"];
    if (newsCate.length > 0) {
        [adInfo setObject:newsCate forKey:@"newscate"];//push正文来源标记
    } else {
        newsCate = [filterInfo stringValueForKey:@"newscate" defaultValue:@""];
        if (newsCate.length > 0) {
            [adInfo setObject:newsCate forKey:@"newscate"];//push正文来源标记
        }
    }
    if ([originInfo objectForKey:@"articleAd"]) {
        [adInfo setObject:[originInfo objectForKey:@"articleAd"] forKey:@"articleAd"];
    }
    
    return adInfo;
}

- (NSDictionary *)adaptResultAdTextInfo:(NSDictionary *)textInfo iconText:(NSString *)iconText itemspaceid:(NSString *)itemspaceid
{
    NSMutableDictionary * a_textInfo = [NSMutableDictionary dictionary];
    [a_textInfo setObject:itemspaceid forKey:@"itemspaceid"];
    
    [a_textInfo setObject:textInfo[@"ad_txt"] ? : @"" forKey:@"ad_txt"];
    
    [a_textInfo setObject:textInfo[@"image_url"] ? : @"" forKey:@"ad_image"];
    
    [a_textInfo setObject:textInfo[@"click_url"] ? : @"" forKey:@"ad_click"];
    
    NSString *dsp_source = [NSString stringWithFormat:@"%@%@", textInfo[@"dsp_source"] ? : @"", iconText ? : @""];
    [a_textInfo setObject:dsp_source forKey:@"iconText"];
    
    return a_textInfo;
}

# pragma mark - SDK Delegate Method

/*! @brief 新闻开机&图文广告错误报告方法
 *
 * @param errorType为错误类型
 * @param itemspaceid广告位id
 *
 */
- (void)stadErrorForNews:(kStadErrorForNewsType)errorType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview andAdParam:(NSDictionary *)params
{
    SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
    adData.sdkView = adview;
    //self.stadTextInfoForNewsBlock(itemspaceid,nil,self.originalData);
    NSDictionary * adTextInfo = [self adaptResultAdTextInfo:nil iconText:nil itemspaceid:itemspaceid];
    [self.articleAdDic setObject:adTextInfo forKey:itemspaceid];
    
    if (self.jsClient && [self.itemspaceidArr containsObject:itemspaceid]) {
        [self.jsClient evaluatingJavaScriptFunction:@"setArticleAd" argsCount:2,adTextInfo,itemspaceid];
    }
    [self reportForAdNullTrackingWithItemSpaceID:itemspaceid];
    [self.AdCaches removeObjectForKey:itemspaceid];
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
    SHADReportData * adData = [self.AdCaches objectForKey:itemspaceid];
    adData.sdkView = adview;
    
    NSString *iconText = nil;
    if (adData && [adData.sdkParam objectForKey:@"iconText"]) {
        iconText = [adData.sdkParam objectForKey:@"iconText"];
    }
    NSDictionary * adTextInfo = [self adaptResultAdTextInfo:textinfo iconText:iconText itemspaceid:itemspaceid];
    [self.articleAdDic setObject:adTextInfo forKey:itemspaceid];
    
    [[SHADManager sharedManager] reportForAdLoadImpTrackingWithItemSpaceID:itemspaceid];
    
    if (self.jsClient && [self.itemspaceidArr containsObject:itemspaceid]) {
        [self.jsClient evaluatingJavaScriptFunction:@"setArticleAd" argsCount:2,adTextInfo,itemspaceid];
    }
}

#pragma mark - configure params

- (BOOL)isNightMode {
    // 夜间模式 客户端自己去alpha遮罩 不用sdk来做处理了
    return NO;
}

- (BOOL)isNoPicMode {
    // 这里不考虑做无图模式了 sdk的无图直接连图都不加载
    return NO;
}

- (void)addConfigParamsAndFrame:(CGRect)frame toParams:(NSMutableDictionary *)param {
    if (param && [param isKindOfClass:[NSMutableDictionary class]]) {
        [param setObject:@"1" forKey:@"apt"]; // 客户端固定写死 表示移动端广告
        // adps
        /*
         比如：这个广告位是 300 x 200。
         那adps 对应的value 就是 300 * 10000 + 200。
         那最后 adps 就是 3000200
         */
        //        int scale = [[UIScreen mainScreen] scale];
        NSInteger scale = [self scaleForPlatformType];
        
        long long size = fabs(frame.size.width) * 10000 * scale + fabs(frame.size.height) * scale;
        NSString *sizeString = [NSString stringWithFormat:@"%lld", size];
        [param setObject:sizeString forKey:@"adps"];
    }
}

- (NSUInteger)scaleForPlatformType {
    return [UIScreen mainScreen].scale;
}

#pragma mark - config ad frame

- (CGRect)configAdFrameByAdSpaceId:(NSString *)spaceId {
    // 正文页 图文广告
    if ([spaceId isEqualToString:kSNAdSpaceIdArticleAd]) {
        return CGRectMake(0, 0, kAppScreenWidth - 28, kSNNewsSdkAdPicTextView_ImageViewHeight);
    }
    // 相关新闻最后一条
    else if ([spaceId isEqualToString:kSNAdSpaceIdArticleRecommendTail]) {
        return CGRectMake(0, 0, kAdvertiseAdRecommendView_width, kAdvertiseAdRecommendView_height);
    }
    
    return CGRectZero;
}

- (CGSize)configAdSizeByAdApaceId:(NSString *)spaceId {
    CGFloat width = 0;
    CGFloat height = 0;
    //文章页中插广告
    if ([spaceId isEqualToString:kSNAdSpaceIdNewsArticleInsertad]) {
        return CGSizeMake(3000, 1);
    }
    // 正文页 图文广告
    else if ([spaceId isEqualToString:kSNAdSpaceIdArticleAd]) {
        width = kAppScreenWidth - 28;
        height = kSNNewsSdkAdPicTextView_ImageViewHeight;
    }
    // 相关新闻最后一条
    else if ([spaceId isEqualToString:kSNAdSpaceIdArticleRecommendTail]) {
        width = kAdvertiseAdRecommendView_width;
        height = kAdvertiseAdRecommendView_height;
    }
    //大图浏览最后一针
    else if ([spaceId isEqualToString:kSNAdSpaceIdSlideshowTail]) {
        UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
        if (t==UIDevice1GiPhone || t==UIDevice3GiPhone || t==UIDevice3GSiPhone ||
            t==UIDevice1GiPod || t==UIDevice2GiPod || t==UIDevice3GiPod ||
            t==UIDevice1GiPadMini || t==UIDevice1GiPad || t==UIDevice2GiPad) {
            width = 320.0f;
            height = 480.0f;
        }
        else if (t==UIDevice4iPhone || t==UIDevice4SiPhone || t==UIDevice4GiPod ||
                 t==UIDevice2GiPadMini || t==UIDevice3GiPad || t==UIDevice4GiPad || t==UIDevice5GiPad) {
            width = 320.0f;
            height = 480.0f;
        }
        else if (t==UIDevice5iPhone || t==UIDevice5CiPhone || t==UIDevice5SiPhone || t==UIDevice5GiPod || t==UIDeviceSEiPhone) {
            width = 320.0f;
            height = 568.0f;
        }
        else if (t == UIDevice6iPhone || t == UIDevice7iPhone || t == UIDevice8iPhone) {
            width = 375.0f;
            height = 667.0f;
        }
        else if (t == UIDevice6PlusiPhone || t == UIDevice7PlusiPhone || t == UIDevice8PlusiPhone) {
            width = 360.0f;
            height = 640.0f;
        }
        else {
            width = kAppScreenWidth;
            height = kAppScreenHeight;
        }
    }
    //大图浏览相关推荐倒数两个
    else if ([spaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendPenult] || [spaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendPenultTest] || [spaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail]) {
        width = kAdvertistGroupPicRecommendTail;
        height = kAdvertistGroupPicRecommendPenult;
        if (kAppScreenWidth > 320) {
            CGFloat w_rate = width / 320.0;
            CGFloat h_rate = height / 480.0;
            width =  kAppScreenWidth * w_rate;
            height = (kAppScreenHeight - 146/2 - 44) * h_rate;
        }
    }
    else {
        return CGSizeZero;
    }
    
    NSInteger scale = [self scaleForPlatformType];
    return CGSizeMake(fabs(width) * scale, fabs(height) * scale);
}

/**
 *  passport id 上报接口
 *
 *  @param passportId passportId
 */
- (void)sendPassportIdForLoginSuccessed:(NSString *)passportId {
    if (passportId.length > 0) {
        [[SNADManager sharedSTADManager] stadLoginTrackWithPassport:passportId];
    }
}

@end

#pragma mark - 用来上报的data，每个广告对应一个data

@implementation SHADReportData

- (instancetype)initWithId:(NSInteger)dataId adType:(ReportDataAdType)type adInfo:(NSDictionary *)adInfo
{
    self = [super init];
    
    _tab = adReportTabNews;
    _adType = type;
    _dataId = dataId;
    _clientParam = [[NSMutableDictionary alloc] init];
    _sdkParam = [self toSDKParamWith:adInfo];
    _serverParam = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    
    _cache = NO;
    
    return self;
}

- (NSMutableDictionary *)toSDKParamWith:(NSDictionary *)adInfo {
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    /*
     {
     "adp_type" = 5;
     appdelaytrack = 0;
     cid = 6051983681726623862;
     gbcode = 1156110000;
     lc = 1;
     newsid = 15556722;
     position = 3;
     }
     
     */
    [param setObject:adInfo[@"adp_type"] ? : @"" forKey:@"adp_type"];
    [param setObject:adInfo[@"cid"]      ? : @"" forKey:@"cid"];
    [param setObject:adInfo[@"position"] ? : @"" forKey:@"position"];
    //    [param setObject:adInfo[@"lc"]       ? : @"" forKey:@"lc"];
    [param setObject:adInfo[@"newsid"] ? : @"" forKey:@"newsid"];
    [param setObject:adInfo[@"subid"] ? : @"" forKey:@"subid"];
    [param setObject:adInfo[@"debugloc"] forKey:@"debugloc"];
    [param setObject:@"0" forKey:@"appdelaytrack"];
    [param setObject:adInfo[@"iconText"] forKey:@"iconText"];
    if (adInfo[@"newscate"]) {
        [param setObject:adInfo[@"newscate"] forKey:@"newscate"];
    }
    if (adInfo[@"articleAd"]) {
        [param setObject:adInfo[@"articleAd"] forKey:@"articleAd"];
    }
    
    return param;
}

- (BOOL)isStreamAd
{
    switch (_adType)
    {
        case adReportTimeLineStream:
        case adReportRecommendStream:
        case adReportPopularizeTimeLine:
        case adReportPopularizeRecommend:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isReported:(STADDisplayTrackType)type
{
    switch (type)
    {
        case STADDisplayTrackTypeNotInterest:    //不感兴趣
        {
            return _isReportedUninteresting;
        }
        case STADDisplayTrackTypeClick:          //点击
        {
            return NO;
        }
        case STADDisplayTrackTypeLoadImp:        //加载曝光 （曝光）
        {
            return _isReportedLoad;
        }
        case STADDisplayTrackTypeImp:            //展示曝光 （有效曝光）
        {
            return _isReportedExposure;
        }
        case STADDisplayTrackTypeNullAD:         //空广告曝光
        {
            return _isReportedEmpty;
        }
        default:
        {
            // 不认识的上报统一表示为已经上报过了。
            return YES;
        }
    }
}

- (void)report:(STADDisplayTrackType)type
{
    switch (type)
    {
        case STADDisplayTrackTypeNotInterest:    //不感兴趣
        {
            _isReportedUninteresting = YES;
            
            break;
        }
        case STADDisplayTrackTypeLoadImp:        //加载曝光 （曝光）
        {
            _isReportedLoad = YES;
            
            break;
        }
        case STADDisplayTrackTypeImp:            //展示曝光 （有效曝光）
        {
            _isReportedExposure = YES;
            
            break;
        }
        case STADDisplayTrackTypeNullAD:         //空广告曝光
        {
            _isReportedEmpty = YES;
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (NSMutableDictionary *)toSDKReportData:(STADDisplayTrackType)reportType
{
    
    NSMutableDictionary *reportData = [NSMutableDictionary dictionary];
    
    
    if (((NSString *)_serverParam[adTrackParamAppChn]).length > 0)
    {
        reportData[adTrackParamAppChn] = _serverParam[adTrackParamAppChn];
    }
    else
    {
        reportData[adTrackParamAppChn] = [NSString stringWithFormat:@"%d", 3111];
    }
    
    reportData[adTrackParamNewsChn] = _serverParam[@"channel"] ? : @"";
    reportData[adTrackParamGbcode] = _serverParam[adTrackParamGbcode] ? : @"";
    reportData[adTrackParamADPType] = _serverParam[adTrackParamADPType] ? : @"";
    reportData[@"debugloc"] = _serverParam[adTrackParamGbcode] ? : @"";
    
    NSString * blockId = _serverParam[@"blockId"] ? : @"";
    if (blockId.length > 0) {
        reportData[@"blockId"] = blockId;
    }
    // 如果服务器的参数和sdk的冲突，以SDK为准
    [reportData addEntriesFromDictionary:_sdkParam];
    
    // 如果客户端的参数和服务器返回的冲突，以客户端的为准
    [reportData addEntriesFromDictionary:_clientParam];
    
    
    if (nil != _sdkParam)
    {
        [reportData addEntriesFromDictionary:_sdkParam];
    }
    
    [reportData addEntriesFromDictionary:_clientParam];
    
    // 缓存标志
    reportData[@"appdelaytrack"] = _cache ? @"1" : @"0";
    
    NSString *cid = [SNUserDefaults objectForKey:kProfileClientIDKey];
    
    reportData[adTrackParamCid] = cid == nil ? @"" : cid;
    
    
    if (nil != _serverParam[@"jsondata"]) {
        reportData[@"jsondata"] = _serverParam[@"jsondata"];
    }
    if ([reportData[adTrackParamSpaceid] isEqualToString:@"12224"] || [reportData[adTrackParamSpaceid] isEqualToString:@"12717"] || [reportData[adTrackParamSpaceid] isEqualToString:@"12718"] || [reportData[adTrackParamSpaceid] isEqualToString:@"13372"] || [reportData[adTrackParamSpaceid] isEqualToString:@"13373"]) {
        if (reportData[adTrackParamPosition]) {
            [reportData removeObjectForKey:adTrackParamPosition];
        }
        if (reportData[adTrackParamReposition]) {
            [reportData removeObjectForKey:adTrackParamReposition];
        }
        if (reportData[adTrackParamAbposition]) {
            [reportData removeObjectForKey:adTrackParamAbposition];
        }
        if (reportData[adTrackParamRefreshCount]) {
            [reportData removeObjectForKey:adTrackParamRefreshCount];
        }
        if (reportData[adTrackParamLoadmoreCount]) {
            [reportData removeObjectForKey:adTrackParamLoadmoreCount];
        }
        
    }
    return reportData;
}

- (NSInteger)objLabel:(BOOL)empty
{
    // 然后才判断adType
    switch (_adType)
    {
        case adReportTimeLineStream:
        {
            return empty ? (SNStatInfoUseTypeTimelineAd + 10)
            : SNStatInfoUseTypeTimelineAd;
        }
        case adReportRecommendStream:
        {
            return empty ? (SNStatInfoUseTypeRecommed + 10)
            : SNStatInfoUseTypeRecommed;
        }
        case adReportSDK:
        {
            return empty ? (SNStatInfoUseTypeOutTimelineAd  + 10)
            : SNStatInfoUseTypeOutTimelineAd ;
        }
        case adReportPush:
        {
            return empty ? (SNStatInfoUseTypePushAd + 10) : SNStatInfoUseTypePushAd;
        }
        case  adReportPopularizeTimeLine:
        {
            return empty ? (SNStatInfoUseTypeOutTimelinePopularize + 10)
            : SNStatInfoUseTypeOutTimelinePopularize;
        }
        case adReportPopularizeRecommend:
        {
            return empty ? (SNStatInfoUseTypeEmptyOutTimelinePopularize + 10)
            : SNStatInfoUseTypeEmptyOutTimelinePopularize;
        }
    }
}

+ (NSString *)stateType:(STADDisplayTrackType)reportType
{
    switch (reportType)
    {
        case STADDisplayTrackTypeNotInterest:
            return @"unintr";
        case STADDisplayTrackTypeClick:
            return @"clk";
        case STADDisplayTrackTypeLoadImp:
            return @"load";
        case STADDisplayTrackTypeImp:
            return @"show";
        case STADDisplayTrackTypeNullAD:
            // 不要奇怪，约定的就是空广告传load. 为什么这么约定不要找我，不是我约定的. 我来了就是这样的
            return @"load";
        default:
            return @"";
    }
}

- (NSString *)objType
{
    // objType还有其他的值，现在使用到的只有spaceId，等全面接管首页流内上报的时候就有其他的值了
    return _spaceId;
}

- (NSString *)objFrom
{
    switch (_tab)
    {
        case adReportTabNews:
            return @"news";
            break;
        case adReportTabViedo:
            return @"video";
            break;
        case adReportTabMine:
            return @"mine";
            break;
        default:
            return @"unknown";
    }
}

- (NSDictionary *)toStatisticsReportData:(STADDisplayTrackType)reportType serverParam:(NSDictionary *)serverParam
{
    // 做一个字典是为了率重
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSObject *adId = serverParam[@"adId"];
    [parameters setObject:adId ? : @"" forKey:@"objId"];
    
    parameters[@"ad_gbcode"] =  serverParam[@"debugloc"] ? : @"";
    parameters[@"objLabel"] = @([self objLabel:reportType == STADDisplayTrackTypeNullAD]);
    parameters[@"statType"] = [SHADReportData stateType:reportType];
    parameters[@"objType"] = [NSString stringWithFormat:@"ad_%@", serverParam[@"itemspaceid"] ? : @""];
    parameters[@"token"] = serverParam[@"token"] ? : @"";
    parameters[@"objFrom"] = [self objFrom];
    parameters[@"objFromId"] = serverParam[@"channel"] ? : @"";
    parameters[@"appchn"] = serverParam[@"appchn"] ? : @"";
    parameters[@"appdelaytrack"] = @(_cache ? 1 : 0);
    parameters[@"newschn"] = serverParam[@"newschn"] ? : @"";
    parameters[@"position"] = serverParam[@"position"] ? : @"";
    parameters[@"reposition"] = serverParam[@"reposition"] ? : @"";
    parameters[@"abposition"] = serverParam[@"abposition"] ? : @"";
    parameters[@"scope"] = serverParam[@"scope"] ? : @"";
    parameters[@"rc"] = serverParam[@"rc"] ?: @"";
    parameters[@"apid"] = serverParam[@"itemspaceid"] ? : @"";
    
    // 如果服务器的参数和sdk的冲突，以SDK为准
    [parameters addEntriesFromDictionary:_sdkParam];
    
    // 如果客户端的参数和服务器返回的冲突，以客户端的为准
//    [parameters addEntriesFromDictionary:_clientParam];
    
    [self delUnsuedReportParams:parameters];
    
    return parameters;
}

// 删除上报不需要的数据。
// 必须要删除，因为某些不需要的数据可能因为上get的数据过大，导致上报失败
- (void)delUnsuedReportParams:(NSMutableDictionary *)dic
{
    [dic removeObjectForKey:@"click_url"];
    [dic removeObjectForKey:@"image_url"];
}

- (BOOL)isEmptyAd
{
    // 是SDK的广告，以sdk的返回值为准
    if (nil != _sdkView)
    {
        // 如果SDK有广告，sdkParam的内容肯定不是0个
        return _sdkParam.count == 0;
    }
    else
    {
        // server to server的广告，以server的返回值为准
        NSString *adType = _serverParam[@"adType"];
        NSString *error = _serverParam[@"error"];
        
        return (nil != adType && adType.integerValue == 2)
        || (nil != error && [error isEqualToString:@"1"]);
    }
}

@end


@implementation SHADReportData(SHADReportDataClientData)

- (void)addClientParams:(NSDictionary *)params
{
    
}

- (void)addPTime:(NSTimeInterval)pTime
{
    _clientParam[@"ptime"] = [NSString stringWithFormat:@"%g", pTime];
}

- (void)addTTime:(NSTimeInterval)tTime
{
    _clientParam[@"ttime"] = [NSString stringWithFormat:@"%g", tTime];
}

- (void)addExposureFrom:(NSInteger)from
{
    _clientParam[@"exposureFrom"] = @(from);
}

- (void)addNewsId:(NSString *)newsId
{
    _clientParam[@"newsid"] = [newsId copy];
}

- (void)addgbcode:(NSString *)gbcode
{
    _clientParam[@"gbcode"] = [gbcode copy];
}

- (void)addRoomId:(NSString *)roomId
{
    _clientParam[@"roomid"] = [roomId copy];
}

@end
