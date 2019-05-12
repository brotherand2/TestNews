//
//  SNPreference.m
//  sohunews
//
//  Created by Dan Cong on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNPreference.h"
#import "SNDBManager.h"
#import "TTImageView.h"

@implementation SNPreference

+ (SNPreference *)sharedInstance {
    static SNPreference *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNPreference alloc] init];
    });
    
    return _sharedInstance;
}


- (SNPreferenceStatus *)loadAndCheckChanged
{
    SNPreferenceStatus *preferenceStatus = [[SNPreferenceStatus alloc] init];
    preferenceStatus.devModeChanged = NO;
    preferenceStatus.needRegisterClient = NO;
    
	if (![[NSUserDefaults standardUserDefaults] objectForKey:kCustomUserdefault]) {
		NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
									  @"", kProfileClientIDKey,
									  @"", kProfileDevicetokenKey,
									  @"", kProfileCookieKey,
									  @"0", kCoverViewType,
									  @"0", kRestAllSubScribe,
									  @"0", kProfileGuideOnFirstRun,
									  @"0", kCustomManageSub,
                                      kDONT_REMIND_ME_RECOMMEND_SUBS_N, kDONT_REMIND_ME_RECOMMEND_SUBS,
									  nil];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kCustomUserdefault];
		[[NSUserDefaults standardUserDefaults] setObject:kUNKNOWN_REGISTERED forKey:kIS_NEW_REGISTERED_DEVICE];
	}
    
    // webp
    self.webpEnabled = YES;
    
    //Even if default values for all keys are defined in your bundle, these settings aren’t automatically loaded.
    //So we have to load it manually everytime.
    //See http://ijure.org/wp/archives/179
    [self registerDefaultsFromSettingsBundle];

    self.testModeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_test_mode_enabled"];
    BOOL lastTestModeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"last_preference_test_mode_enabled"];
    if (self.testModeEnabled != lastTestModeEnabled) {
        preferenceStatus.devModeChanged = YES;
        preferenceStatus.needRegisterClient = YES;
        [[NSUserDefaults standardUserDefaults] setBool:self.testModeEnabled forKey:@"last_preference_test_mode_enabled"];
    }
    
    self.basicAPIDomain = [[NSUserDefaults standardUserDefaults] stringForKey:@"preference_basic_api_domain"];
    self.circleAPIDomain = [[NSUserDefaults standardUserDefaults] stringForKey:@"preference_sns_api_domain"];
    
    NSString *productId = [[NSUserDefaults standardUserDefaults] stringForKey:@"preference_product_id"];
    NSString *lastProductId = [[NSUserDefaults standardUserDefaults] stringForKey:@"last_preference_product_id"];
    if (productId.length > 0) {
        if (![productId isEqualToString:lastProductId]) {
            preferenceStatus.needRegisterClient = lastProductId.length > 0;
            [[NSUserDefaults standardUserDefaults] setObject:productId forKey:@"last_preference_product_id"];
        }

        self.productId = productId;
    } else {
        self.productId = kProductID;
    }
    
    NSString *marketId = [[NSUserDefaults standardUserDefaults] stringForKey:@"preference_market_id"];
    NSString *lastMarketId = [[NSUserDefaults standardUserDefaults] stringForKey:@"last_preference_market_id"];
    if (marketId.length > 0) {
        if (![marketId isEqualToString:lastMarketId]) {
            preferenceStatus.needRegisterClient = lastMarketId.length > 0;
            [[NSUserDefaults standardUserDefaults] setObject:marketId forKey:@"last_preference_market_id"];
        }
        
        self.marketId = marketId;
    }
    else {
        self.marketId = [NSString stringWithFormat:@"%d", [SNUtility marketID]];
    }

    self.videoAdTestServerEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_use_videoad_testserver"];
    self.simulateRoadnaviEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_simulate_roadnavi_enabled"];
    self.simulateCloudSyncEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_simulate_cloudsync_enabled"];
    self.simulateOnLineEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_simulate_on_line_enabled"];
    
    self.debugModeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_debug_mode_enabled"];
    self.memUsageEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_mem_usage_enabled"];
    self.bandwidthEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_bandwidth_enabled"];
    self.touchDetectEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_touch_detect_enabled"];
    self.appInspectorEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_app_usage_enabled"];
    self.adScreenshotSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:@"advertising_screenshot_switch"];

    //每次启动默认设置频道tab为频道新闻
    [[NSUserDefaults standardUserDefaults] setObject:@"SNChannelSwitchTypeOther" forKey:kChannelManagerSwitchType];
    
    // 初始化无图模式设置
    NSString *picMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
    
    if (picMode == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kNonePictureModeKey];
        self.pictureMode = kPicModeAlways;
    } else {
        self.pictureMode = [picMode intValue];
    }
    
    //初始化视频播放设置
    NSString *vidMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNoneVideoModeKey];
    if (!vidMode) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kChannelVideoSwitchKey]) {
            self.videoMode = kPicModeWiFi;
        }
        else {
            self.videoMode = kPicModeAlways;
        }
    }
    else {
        self.videoMode = [vidMode intValue];
        if (self.videoMode == kPicModeNone) {
            self.videoMode = kPicModeWiFi; // 不再有kPicModeNone
        }
    }
    
    //字体设置
    NSString *fontCls = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    
    //设置默认字体
    if (!fontCls) {
        [[NSUserDefaults standardUserDefaults] setObject:kWordSmall forKey:kNewsFontClass];
    }
    
    // 新闻正文自动全屏
    NSString *autoFullscreenMode = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoFullscreenModeKey];
    if (autoFullscreenMode == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kAutoFullscreenModeKey];
        self.autoFullscreenMode = NO;
    } else {
        self.autoFullscreenMode = ([autoFullscreenMode intValue] != 0);
    }
    
    // 本地应用长期未启动提醒
    NSString *localNotifForAppNotLaunchedForLong = [[NSUserDefaults standardUserDefaults] objectForKey:kAppNotLaunchedForSomeTimeNotifyEnabled];
    if (localNotifForAppNotLaunchedForLong == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kAppNotLaunchedForSomeTimeNotifyEnabled];
    }
    
	//SNDebugLog(SN_String("INFO: kIS_NEW_REGISTERED_DEVICE状态值是：%@"), [[NSUserDefaults standardUserDefaults] valueForKey:kIS_NEW_REGISTERED_DEVICE]);
    
	//SNDebugLog(SN_String("INFO: %@--%@, current kIS_NEW_REGISTERED_DEVICE value is：%@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[NSUserDefaults standardUserDefaults] valueForKey:kIS_NEW_REGISTERED_DEVICE]);
    
    //解决check.do接口客户端使用时的bug，在升级之后先开启kUpgradeOffOn开关，直到check.do正确返回后再关闭
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey];
    if (![version length]) {
        version = @"other";
    }
    NSString *preVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kVersion];
    //SNDebugLog(@"%@,%@", preVersion, version);
    if (!preVersion || ![version isEqualToString:preVersion]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kClientInfoSynchronized];
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:kVersion];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUpgradeOffOn];
        
        if (preVersion) {
            [[NSUserDefaults standardUserDefaults] setObject:preVersion forKey:kPreVersion];

            // 3.5之前的版本升级到3.5后，从订阅数据库中移除‘猜你喜欢’，由服务器订阅接口作为功能插件提供
            if ([preVersion compare:@"3.5" options:NSNumericSearch] == NSOrderedAscending) {
                [[SNDBManager currentDataBase] deleteSubscribeCenterSubscribeObjectFromDatabaseBySubId:kYouMayLikeId];
            }
        } else {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kAdRefreshTime];
        
        //覆盖升级之后要将这两个重置，否则提示更新的逻辑会有问题
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"upgradeInfo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"upgradeDeniedTime"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"upgradeDeniedCount"];
        
        //3.5.1 去掉新手引导
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kProfileGuideOnFirstRun];

    }
    
    //3.2 我的订阅页新手mask引导
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kGuideMaskSubCenterMyList]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kGuideMaskSubCenterMyList];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];

    return preferenceStatus;
}

- (void)registerDefaultsFromSettingsBundle
{
    //SNDebugLog(@"Registering default values from Settings.bundle");
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle)
    {
        //SNDebugLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    
    for (NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key)
        {
            // check if value readable in userDefaults
            id currentObject = [defs objectForKey:key];
            if (currentObject == nil)
            {
                // not readable: set value from Settings.bundle
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                if (objectToSet && ![objectToSet isKindOfClass:[NSNull class]]) {
                    [defaultsToRegister setObject:objectToSet forKey:key];
                }
                //SNDebugLog(@"Setting object %@ for key %@", objectToSet, key);
            }
            else
            {
                // already readable: don't touch
                //SNDebugLog(@"Key %@ is readable (value: %@), nothing written to defaults.", key, currentObject);
            }
        }
    }
    
    [defs registerDefaults:defaultsToRegister];
    [defs synchronize];
}

- (void)setWebpEnabled:(BOOL)webpEnabled
{
    _webpEnabled = webpEnabled;
    [TTImageView setWebpEnabled:webpEnabled];
}

@end
