//
//  SNAppConfigManager.m
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppConfigManager.h"
#import "SNAppConfigService.h"
#import "SNClientRegister.h"
#import "SNActiveTipsService.h"

@interface SNAppConfigManager() <SNActiveTipsServiceDelegate> {
    SNAppConfigService *_asynAppConfigService;
    
    NSLock *_synLock;
    SNAppConfigService *_synAppConfigService;
    
    SNActiveTipsService *_activeTipsService;
}
@end

@implementation SNAppConfigManager

#pragma mark - Life cycle
+ (SNAppConfigManager *)sharedInstance {
    static SNAppConfigManager *appConfigManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appConfigManager = [[SNAppConfigManager alloc] init];
    });
    return appConfigManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _synLock = [[NSLock alloc] init];
    }
    return self;
}

- (SNAppConfig *)config {
    if (!_config) {
        _config = [[SNAppConfig alloc] init];
    }
    return _config;
}

#pragma mark - Public - Request Server Config
/**
 * 加载配置信息。反复调用此方法可刷新最新的配置信息到内存。
 */
- (void)requestConfigAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _asynAppConfigService.delegate = nil;
//        [_asynAppConfigService cancel];
        _asynAppConfigService = nil;
        
        _asynAppConfigService = [[SNAppConfigService alloc] init];
        [_asynAppConfigService setDelegate:self];
        [_asynAppConfigService requestConfigAsync];
    });
}

/**
 * 加载配置信息。同步方法，专门为了新用户引导，卡住主线程，为了能在用户引导前获取到数据
 */
- (void)requestConfigSync{
    [_synLock lock];
    
    _synAppConfigService.delegate = nil;
//    [_synAppConfigService cancel];
    _synAppConfigService = nil;
    _synAppConfigService = [[SNAppConfigService alloc] init];
    [_synAppConfigService setDelegate:self];
    [_synAppConfigService requestConfigSync];
    
    [_synLock unlock];
}

- (void)didSucceedToRequestConfig:(SNAppConfig *)config {
    // 如果服务器开启强制注册，则发起一次客户端注册请求
    if (config.redoRegisterClient) {
        [[SNClientRegister sharedInstance] registerClientAnyway];
    }
}

- (BOOL)isShowNewsPullBgImage
{
    return nil == self.config ? NO : self.config.newsPullBgImage;
}

- (BOOL)isAppInterestOpen
{
    return self.config.appInterestOpen;
}

- (BOOL)searchSogouButtonShow
{
    return self.config.sogouButtonShow;
}

- (BOOL)updateLocalChannelShow
{
    return self.config.localChannelUpdateShow;
}

- (NSString *)showPullNewsTips
{
    return self.config.pullNewsTips;
}

/**
 *是否显示下拉广告的开关
 */
- (BOOL)pullAdSwitchOpen {
    return self.config.pullAdSwitch;
}

- (BOOL)showEditMySplashButton {
    return self.config.loadingMySplashSwitch;
}

- (BOOL)isShowAliPayShareTimeline{
    if (self.config.shareAlipayOption && [self.config.shareAlipayOption isKindOfClass:[NSString class]]) {
        NSArray *array = [self.config.shareAlipayOption componentsSeparatedByString:@","];
        if (array && array.count > 0) {
            NSString *isOn = [array objectAtIndex:0];
            if ([isOn isEqualToString:@"0"]) {
                return YES;
            }
            if ([isOn isEqualToString:@"1"]) {
                return NO;
            }
        }
    }
    return NO;
}

- (BOOL)isShowAliPayShareSession{
    if (self.config.shareAlipayOption && [self.config.shareAlipayOption isKindOfClass:[NSString class]]) {
        NSArray *array = [self.config.shareAlipayOption componentsSeparatedByString:@","];
        if (array && array.count > 1) {
            NSString *isOn = [array objectAtIndex:1];
            if ([isOn isEqualToString:@"0"]) {
                return YES;
            }
            if ([isOn isEqualToString:@"1"]) {
                return NO;
            }
        }
    }
    return NO;
}

#pragma mark - Public - SNAppConfigAdvAccessor
/**
 *是否显示用户引导页，YES显示，NO不显示
 */
- (BOOL)isNewUserGuideShow
{
    return self.config.isGuideInterestShow;
}

- (SNAppConfigActivity *)activity {
    return self.config.activity;
}

/**
 加载我的页面活动提醒信息
 */
- (void)requestActivityTipsInfo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self activeTipsService] setDelegate:self];
        [[self activeTipsService] requestActivityInfo];
    });
}

- (SNActiveTipsService *)activeTipsService
{
    if (!_activeTipsService) {
        _activeTipsService = [[SNActiveTipsService alloc] init];
    }
    return _activeTipsService;
}

- (NSDictionary *)getActiveTipsInfo
{
    return self.activeTipsInfo;
}

- (void)didSucceedToRequestActiveTips:(NSDictionary *)activityInfo
{
    self.activeTipsInfo = activityInfo;

    [self releaseActiveTipsService];
}

- (void)didFailedToRequestActiveTips
{
    [self releaseActiveTipsService];
}

- (void)releaseActiveTipsService {
    _activeTipsService.delegate = nil;
    _activeTipsService = nil;
}

-(void)dealloc
{
}

#pragma mark - SNAppConfigVideoAd

- (SNAppConfigVideoAd *)videoAdConfig {
    return self.config.videoAdConfig;
}

#pragma mark - SNAppConfigVoiceCloud
- (SNAppConfigVoiceCloud *)voiceCloudConfig {
    return self.config.voiceCloud;
}

#pragma mark - SNPopupActivity
- (SNPopupActivity *)popupActivity {
    return self.config.popupActivity;
}

#pragma mark - SNAppConfigRequestMonitorConditions
- (SNAppConfigRequestMonitorConditions *)requestMonitorConditions {
    return self.config.requestMonitorConditions;
}

#pragma mark - SNAppConfigPreLoading
- (SNAppConfigSplashPreLoading *)splashPreLoading {
    return self.config.splashPreloading;
}

#pragma mark - SNAppConfigFestivalIcon
- (NSString *)festivalIconUrl{

    return self.config.festivalIcon.festivalIconUrl;
}

#pragma mark push check period
- (NSString *)checkPushPeriod {
    return self.config.checkPushPeriod;
}

#pragma mark reShowSplashADInterval
- (NSTimeInterval)reShowSplashADInterval {
    return self.config.reshowSplashInterval;
}

#pragma mark floatingLayer

- (SNAppConfigFloatingLayer *)floatingLayer{
    return self.config.floatingLayer;
}

#pragma mark redPacketSlideNum

- (int)redPacketSlideNum{
    return self.config.redPacketSlideNum;
}
#pragma mark channelVieoSwitch
- (BOOL)channelVieoSwitch {
    return [SNUserDefaults boolForKey:kChannelVideoSwitchKey];
}

#pragma mark camera config
- (NSString *)cameraTabString{
    return self.config.cameraConfig.tabStr;
}

- (NSString *)getMytabCouponTicketUrl{
     return self.config.mytabCouponTicketUrl;
}

#pragma mark tab bar config
- (SNAppConfigTabBar *)configTabBar {
    return self.config.appConfigTabbar;
}

#pragma mark time control config

- (SNAppConfigTimeControl *)configTimeControl {
    return self.config.appConfigTimeControl;
}

#pragma mark https switch

- (SNAppConfigHttpsSwitch *)configHttpsSwitch {
    return self.config.appConfigHttpsSwitch;
}

#pragma mark scheme
- (SNAppConfigScheme *)configScheme {
    return self.config.appConfigScheme;
}

#pragma mark h5 redPacket url
- (SNAppConfigH5RedPacket *)configH5RedPacket {
    return self.config.appconfigH5RedPacket;
}

#pragma mark MP Link
- (SNAppConfigMPLink *)configMPLink {
    return self.config.appConfigMPLink;
}

@end
