//
//  SNAdvertiseManager.m
//  sohunews
//
//  Created by jojo on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNAdvertiseManager.h"
#import "STADManagerForNews.h"
#import "SNStatisticsManager.h"
#import "SNSpaceId.h"
#import "SNUserManager.h"
#import "SNUserLocationManager.h"
#import "SNCacheManager.h"
#import "SNAppConfigConst.h"

#define UserData @"iOSNewsClientUserData"

@interface SNAdvertiseManager ()<SNADManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *cachedAdCarriers; // spaceId --- > array of carriers

@end

@implementation SNAdvertiseManager

@synthesize cachedAdCarriers = _cachedAdCarriers;

+ (SNAdvertiseManager *)sharedManager {
    static SNAdvertiseManager *__sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sInstance = [[self alloc] init];
    });
    return __sInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[SNADManager sharedSTADManager] setDelegateObject:self];
    }
    return self;
}

- (void)dealloc {

}

- (NSString *)getCurrentNetworkType{
    return [[SNADManager sharedSTADManager] getCurrentNetworkType];
}

- (NSMutableDictionary *)cachedAdCarriers {
    if (!_cachedAdCarriers) {
        _cachedAdCarriers = [[NSMutableDictionary alloc] init];
    }
    return _cachedAdCarriers;
}

#pragma mark - public methods
- (BOOL)isSDKAdEnable {
    return [[SNUserDefaults stringForKey:kSNAdvertiseEnableKey] isEqualToString:@"1"];
}

- (SNAdDataCarrier *)generateNormalAdDataCarrierWithSpaceId:(NSString *)spaceId adInfoParam:(NSDictionary *)param {
    if ([spaceId length] == 0 ||
        [param count] == 0) {

        return nil;
    }
    
    SNAdDataCarrier *adCarrier = [[SNAdDataCarrier alloc] initWithAdSpaceId:spaceId];
    adCarrier.filter = param;
    
    __block typeof(self) pSelf = self;
    
    [adCarrier setAdDataHandler:^UIView *(id dataCarrier, BOOL needRender) {
        
        if ([dataCarrier isKindOfClass:[SNAdDataCarrier class]]) {
            
            SNAdDataCarrier *ac = (SNAdDataCarrier *)dataCarrier;
            [pSelf cacheAdDataCarrier:ac forSpaceId:spaceId];
            
            NSMutableDictionary *finalParam = [NSMutableDictionary dictionaryWithDictionary:param];
            CGRect adViewFrame = [pSelf configAdFrameByAdSpaceId:spaceId];
            [pSelf addConfigParamsAndFrame:adViewFrame toParams:finalParam];

            if ([SNPreference sharedInstance].testModeEnabled) {
                [finalParam setObject:@"2" forKey:@"bucketid"];
            }

            [finalParam setObject:ac forKey:UserData];
            
            ac.adView = [[SNADManager sharedSTADManager]
                         getNewsMraidWithFrame:adViewFrame
                                      andParam:finalParam
                                    andIsNight:[pSelf isNightMode]
                                  andIsNonepic:[pSelf isNoPicMode]
                                  shouldRender:needRender];
            
            return ac.adView;
        }
        
        return nil;
    }];
    
    return adCarrier;
}

- (void)snadStartPerdonwloadWithParam
{
    NSDictionary *param12224Dict = [self getOpenAdFromNews];
    [[SNADManager sharedSTADManager] snadStartPerdonwloadWithParam:param12224Dict];
    NSDictionary *param12355Dict = [self getOpen12355AdFromNews];
    [[SNADManager sharedSTADManager] snadStartPerdonwloadWithParam:param12355Dict];
}

- (void)getNewsOpenisFirstLoad:(BOOL)isFirstLoad loadDidFinished:(SNOpenAssetLoadFinishedBlock)loadFinished playDidFinished:(SNOpenAssetPlayFinishedBlock)playFinished didClicked:(SNOpenAssetClickBlock)click
{
    self.openAdLoadFinishedBlock = loadFinished;
    self.openAdPlayFinishedBlock = playFinished;
    self.openAdClickBlock = click;
    NSDictionary *paramDict = [self getOpenAdFromNews];
    //SNADManager * manager = [SNADManager sharedSTADManager];
    [[SNADManager sharedSTADManager] getNewsOpenWithParam:paramDict isFirstLoad:isFirstLoad];
}

- (NSDictionary *)getOpenAdFromNews
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:@"13" forKey:@"adsrc"];
    [paramDict setObject:[SNPreference sharedInstance].marketId forKey:@"appchn"];
    [paramDict setObject:[SNPreference sharedInstance].marketId forKey:@"h"];
    [paramDict setObject:@"1" forKey:@"adapter_id"];
    [paramDict setObject:[SNUserManager getCid]?:@"" forKey:@"cid"];
    NSString *gbcde = [SNUserLocationManager sharedInstance].currentChannelGBCode;
    if (!gbcde || gbcde.length == 0) {
        gbcde = [SNUserDefaults objectForKey:kAdGbcode];
    }
    [paramDict setObject:gbcde forKey:@"gbcode"];
    [paramDict setObject:@"12224" forKey:@"itemspaceid"];
    [paramDict setObject:@"1" forKey:@"adp_type"];
    CGRect adViewFrame = [self configAdFrameByAdSpaceId:@"12224"];
    [self addConfigParamsAndFrame:adViewFrame toParams:paramDict];
    
    return (NSDictionary *)paramDict;
}

- (NSDictionary *)getOpen12355AdFromNews
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:@"13" forKey:@"adsrc"];
    [paramDict setObject:[SNPreference sharedInstance].marketId forKey:@"appchn"];
    [paramDict setObject:[SNPreference sharedInstance].marketId forKey:@"h"];
    [paramDict setObject:@"1" forKey:@"adapter_id"];
    [paramDict setObject:@"1" forKey:@"apt"];
    [paramDict setObject:[SNUserManager getCid]?:@"" forKey:@"cid"];
    NSString *gbcde = [SNUserLocationManager sharedInstance].currentChannelGBCode;
    if (!gbcde || gbcde.length == 0) {
        gbcde = [SNUserDefaults objectForKey:kAdGbcode];
    }
    [paramDict setObject:gbcde forKey:@"gbcode"];
    [paramDict setObject:@"12355" forKey:@"itemspaceid"];
    [paramDict setObject:@"10" forKey:@"adp_type"];
    [paramDict setObject:@"30000001" forKey:@"adps"];
    
    return (NSDictionary *)paramDict;
}

#pragma mark - STADManagerDelegate

/**
 *  开机广告加载成功事件
 *
 *  @param localImgPath 开机广告展示VC
 *  @param oadInterval  开机广告展示时长
 */

- (void)stadOpenAssetDidFinishedLoading:(UIViewController *)openADVC interval:(NSTimeInterval)oadInterval
{
    if (openADVC) {
        self.openAdLoadFinishedBlock(YES,openADVC,oadInterval);
    }
}

/*! @brief 开机广告获取错误
 *
 * 开机广告load错误，无法正常获取广告物料
 *
 */
- (void)stadOpenAssetNotAvaliableWithOpenADViewCtrler:(UIViewController *)openVC
{
    self.openAdLoadFinishedBlock(NO,nil,0);
}

/*! @brief 开机广告结束，包括所有业务逻辑
 *
 */
- (void)stadOpenADFinishedWithOpenADViewCtrler:(UIViewController *)openVC
{
    self.openAdPlayFinishedBlock(YES,nil);
}

/*! @brief 视频开机广告播放错误
 *
 */
- (void)stadOpenADFailedWithOpenADViewCtrler:(UIViewController *)openVC
{
    self.openAdPlayFinishedBlock(NO,openVC);
}

/*! @brief 开机广告点击事件
 *
 */
- (void)stadOpenADClicked:(NSString *)loadingString
{
    self.openAdClickBlock(loadingString);
}

- (NSDictionary *)getShareInfo {
    return [[SNADManager sharedSTADManager] getNewsOpenShare] ? : nil;
}

- (void)switchOpenAD
{
    [[SNADManager sharedSTADManager] switchOpenAD];
}

// todo(Cae) 临时调试广告代码，记得删了
- (NSString *)buildAdUrlHost:(NSString *)spaceId
{
    return @"http://t.adrd.sohuno.com/adgtr/";
//    if ([@"12232" isEqualToString:spaceId] || [@"12237" isEqualToString:spaceId]) {
//        return @"http://t.adrd.sohuno.com/adgtr/";
//    }
//    else {
//        return [self adHostUrl];
//    }
}

/*! @brief 新闻开机&图文广告 成功展示
 *
 * @param itemspaceid广告位id
 *
 */
- (void)stadAdViewDidAppearForNewsWithItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview
{
    __block SNAdDataCarrier *ac = [self adDataCarrierForSpaceId:itemspaceid andAdView:adview];
    
    if (nil == ac)
    {
        return ;
    }
    
    ac.adView = adview;

    [ac loadAdImageFromAdInfo:^(UIImage *image, NSError *error, SNAdDataCarrier *ad)
     {
         if (nil != error || nil == image)
         {
             dispatch_async(dispatch_get_main_queue(), ^(){
                 ac.dataState = SNAdDataStateFailed;
                 [self removeAdDataCarrier:ac forSpaceId:itemspaceid];
             });
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^(){
                 ac.dataState = SNAdDataStateReady;
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     [[TTURLCache sharedCache] storeData:UIImagePNGRepresentation(image) forURL:[ad adImageUrl]];

                 });
                 
                 // 直接去回调
                 if (ac.delegate && [ac.delegate respondsToSelector:@selector(adViewDidAppearWithCarrier:)])
                 {
                     [ac.delegate adViewDidAppearWithCarrier:ac];
                 }
                 
                 // 成功之后 remove掉
                 [self removeAdDataCarrier:ac forSpaceId:itemspaceid];
             });

         }
     }];

}

/*! @brief 新闻开机&图文广告错误报告方法
 *
 * @param errorType为错误类型
 * @param itemspaceid广告位id
 *
 */
- (void)stadErrorForNews:(kStadErrorForNewsType)errorType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview andAdParam:(NSDictionary *)params
{
    SNAdDataCarrier *ac = [self adDataCarrierForSpaceId:itemspaceid andAdView:adview];
    
    if (nil == ac)
    {
        ac = params[UserData];
    }
    
    if (nil == ac || ![ac isKindOfClass:[SNAdDataCarrier class]])
    {
        return ;
    }
    
    ac.dataState = SNAdDataStateFailed;
    ac.errorType = errorType;
    ac.newsID = params[@"newsid"]?:ac.newsID;
    if (ac.filter[@"newscate"]) {
        ac.newsCate = ac.filter[@"newscate"];
    }
    if ([itemspaceid isEqualToString:@"12442"] || [itemspaceid isEqualToString:@"12838"]) {
        
    }
    //统计空广告位 5.0由客户端统计空广告
    else if (errorType == kStadErrorForNewsTypeNodata) {
        [ac reportForEmptyTrack];
    }
    
    // 直接去回调
    if (ac.delegate && [ac.delegate respondsToSelector:@selector(adViewDidFailToLoadWithCarrier:)]) {
        [ac.delegate adViewDidFailToLoadWithCarrier:ac];
    }
    
    // 无论什么原因 失败了 就直接remove掉
    [self removeAdDataCarrier:ac forSpaceId:itemspaceid];
}

/*! @brief 新闻开机&图文广告 文本信息回调方法
 *
 * 该方法会将SDK处理后的文本信息返回给App
 * @param textInfo文本信息
 * @param itemspaceid广告位id
 *
 *////////
- (void)stadTextInfoForNews:(NSDictionary *)textinfo andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview {

    SNAdDataCarrier *ac = [self adDataCarrierForSpaceId:itemspaceid andAdView:adview];
    
    if (nil == ac)
    {
        return ;
    }
    
    [ac onlySetAdInfo:textinfo];
    
    //ac.adInfoDic = textinfo;
}

#pragma mark - configure params

- (BOOL)isNightMode {
    // 夜间模式 客户端自己去alpha遮罩 不用sdk来做处理了
    return NO;
}

- (BOOL)isNoPicMode {
    // 这里不考虑做无图模式了 sdk的无图直接连图都不加载，不考虑本地已经有缓存的情况
    return NO;
//    return [[SNUtility getApplicationDelegate] shouldDownloadImagesManually];
}

- (void)cacheAdDataCarrier:(SNAdDataCarrier *)adDataCarrier forSpaceId:(NSString *)spaceId {
    if (adDataCarrier && spaceId) {
        NSMutableArray *cachedArray = [self.cachedAdCarriers objectForKey:spaceId ofClass:[NSMutableArray class] defaultObj:nil];
        if (!cachedArray) {
            cachedArray = [[NSMutableArray alloc] init];
            [self.cachedAdCarriers setObject:cachedArray forKey:spaceId];
        }
        
        [cachedArray removeObject:adDataCarrier];
        [cachedArray addObject:adDataCarrier];
    }
}

- (void)removeAdDataCarrier:(SNAdDataCarrier *)adDataCarrier forSpaceId:(NSString *)spaceId {
    if (adDataCarrier && spaceId) {
        NSMutableArray *cachedArray = [self.cachedAdCarriers objectForKey:spaceId ofClass:[NSMutableArray class] defaultObj:nil];
        if (cachedArray) {
            [cachedArray removeObject:adDataCarrier];
        }
    }
}

- (SNAdDataCarrier *)adDataCarrierForSpaceId:(NSString *)spaceId andAdView:(UIView *)adView {
    SNAdDataCarrier *adDataCarrierFound = nil;
    
    if (spaceId && adView) {
        NSMutableArray *cachedArray = [self.cachedAdCarriers objectForKey:spaceId ofClass:[NSMutableArray class] defaultObj:nil];
        for (SNAdDataCarrier *adDataCarrier in cachedArray) {
            if (adDataCarrier.adView == adView) {
                adDataCarrierFound = adDataCarrier;
                break;
            }
        }
    }
    
    return adDataCarrierFound;
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
        //客户端没开启完美适配，使用platformType判断机型再计算广告位分辨率
        NSInteger scale = [self scaleForPlatformType];
        
        long long size = abs(frame.size.width) * 10000 * scale + abs(frame.size.height) * scale;
        NSString *sizeString = [NSString stringWithFormat:@"%lld", size];
        [param setObject:sizeString forKey:@"adps"];
    }
}

- (NSUInteger)scaleForPlatformType {
    return [UIScreen mainScreen].scale;
}

#pragma mark - config ad frame
// code to update
- (CGRect)configAdFrameByAdSpaceId:(NSString *)spaceId {
    //loading页
    if ([spaceId isEqualToString:kSNAdSpaceIdLoading]) {
        return CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    }

    // 大图浏览模式下最后一帧广告
    else if ([spaceId isEqualToString:kSNAdSpaceIdSlideshowTail]) {
        UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
        if (t==UIDevice1GiPhone || t==UIDevice3GiPhone || t==UIDevice3GSiPhone ||
            t==UIDevice1GiPod || t==UIDevice2GiPod || t==UIDevice3GiPod ||
            t==UIDevice1GiPadMini || t==UIDevice1GiPad || t==UIDevice2GiPad) {
            return CGRectMake(0, 0, 320.0f, 480.0f);
        }
        else if (t==UIDevice4iPhone || t==UIDevice4SiPhone || t==UIDevice4GiPod ||
                 t==UIDevice2GiPadMini || t==UIDevice3GiPad || t==UIDevice4GiPad || t==UIDevice5GiPad) {
            return CGRectMake(0, 0, 320.0f, 480.0f);
        }
        else if (t==UIDevice5iPhone || t==UIDevice5CiPhone || t==UIDevice5SiPhone || t==UIDevice5GiPod || t==UIDeviceSEiPhone) {
            return CGRectMake(0, 0, 320.0f, 568.0f);
        }
        else if (t == UIDevice6iPhone || t == UIDevice7iPhone || t == UIDevice8iPhone) {
            return CGRectMake(0, 0, 375.0f, 667.0f);
        }
        else if (t == UIDevice6PlusiPhone || t == UIDevice7PlusiPhone || t == UIDevice8PlusiPhone) {
            return CGRectMake(0, 0, 360.0f, 640.0f);
        }
        else {
            return CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
        }
    }
    
    // 组图推荐最后两条
    else if ([spaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail]
             || [spaceId isEqualToString:SpaceId13371]
             || [spaceId isEqualToString:SpaceId12716]
             || [spaceId isEqualToString:@"99999"]) {
        CGFloat width = 228 / 2;
        CGFloat height = 148 / 2;
        UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
        if (t == UIDevice6iPhone || t == UIDevice6PlusiPhone || t == UIDevice7iPhone || t == UIDevice7PlusiPhone || t == UIDevice8iPhone || t == UIDevice8PlusiPhone)
        {
            CGFloat w_rate = width / 320.0;
            CGFloat h_rate = height / 480.0;
            width =  kAppScreenWidth * w_rate;
            height = (kAppScreenHeight - 146/2 - 44) * h_rate;
        }
        
        return  CGRectMake(0, 0, width, height);
    }
    //直播间冠名广告
    else if([spaceId isEqualToString:kSNAdSpaceIdLiveSponsorShip] ||
            [spaceId isEqualToString:kSNAdSpaceIdLiveSponsorShipTestServer]) {
        return CGRectMake(0, 0, kAdvertiseSponsorShipWidth, kAdvertiseLiveSponsorShipHeight);
    }

    
    return CGRectZero;
}

#pragma mark- cleanData
- (void)cleanCacheAdDataCarrier:(SNAdDataCarrier *)carrier {

    if (!carrier) {
        return;
    }
    
    SNAdDataCarrier *ac = [self adDataCarrierForSpaceId:carrier.adSpaceId andAdView:carrier.adView];
    if (ac) {
        ac.delegate = nil;
    }
    
    [self removeAdDataCarrier:carrier forSpaceId:carrier.adSpaceId];
}

/**
 *  passport id 上报接口
 *
 *  @param passportId passportId
 */
- (void)sendPassportIdForLoginSuccessed:(NSString *)passportId {
    if (passportId.length > 0 && ![passportId isEqualToString:@"-1"]) {
        [[SNADManager sharedSTADManager] stadLoginTrackWithPassport:passportId];
    }
}

#pragma mark - 非标广告/渠道广告

/**
 获取渠道广告物料
 */
- (void)updateChannelADs:(NSDictionary *)jsonData {
    int shareADSwicth = [jsonData intValueForKey:kNonstandardShareAD defaultValue:0];
    int searchADSwicth = [jsonData intValueForKey:kNonstandardSearchAD defaultValue:0];
    if (shareADSwicth) {
        NSArray * shareADDatas = [jsonData arrayValueForKey:kNonstandardShareADResource defaultValue:nil];
        if (shareADDatas.count > 0) {
            id shareAd = shareADDatas[0];
            if ([shareAd isKindOfClass:[NSDictionary class]]) {
                self.sharePageAD = [[SNChannelsAdData alloc] initWithDic:(NSDictionary *)shareAd adType:SNChannelADTypeShareMenu];
            }
        }
    }
    if (searchADSwicth) {
        NSArray * searchADDatas = [jsonData arrayValueForKey:kNonstandardSearchADResource defaultValue:nil];
        if (searchADDatas.count > 0) {
            id searchAd = searchADDatas[0];
            if ([searchAd isKindOfClass:[NSDictionary class]]) {
                self.searchPageAD = [[SNChannelsAdData alloc] initWithDic:(NSDictionary *)searchAd adType:SNChannelADTypeSearchHeader];
            }
        }
    }
}

@end
