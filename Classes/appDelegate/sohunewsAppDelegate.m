//
//  sohunewsAppDelegate.m
//  sohunews
//
//  Created by zhu kuanxi on 5/16/11.
//  Copyright 2011 sohu. All rights reserved.
//

#import "sohunewsAppDelegate.h"
#import "SNMessageStatusBar.h"
#import "SNDBManager.h"
#import "SNAPNSHandler.h"
#import "JRSwizzle.h"
#import "SNQQHelper.h"
#import "SNCheckManager.h"
#import "SNLiveSubscribeService.h"
#import "SNWeatherCenter.h"
#import "SNCacheCleanerManager.h"
#import "SNSSOAdapter.h"
#import "SNStatusBarMessageCenter.h"
#import "SNWindow.h"
#import "TTRequestLoader_extend.h"
#import "SNUserLocationManager.h"
#import "SNNewsPreloader.h"
#import "SNInterceptConfigManager.h"
#import "SNNavigatorMap.h"
#import "SNDBMigrationController.h"
#import "SNDBExportor.h"
#import "SNUserManager.h"
#import "WSMVVideoPlayerConst.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNNewsExposureManager.h"
#import "SNLocalNotifReminder.h"
#import "SNAppstoreRateHelper.h"
#import "SNUpgradeHelper.h"
#import "SNClientRegister.h"
#import "SNPopupActivityCenter.h"
#import "SNAppMonitorsManager.h"
#import "SNSamplingFrequencyGenerator.h"
#import "SNRollingNewsPublicManager.h"
#import "SNDownloadScheduler.h"
#import "SNToast.h"
#import "SNNewUserGuideViewController.h"
#import "SNExternalLinkHandler.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNBusinessStatisticsManager.h"
#import "UCPostLog.h"
#import "SNQRUtility.h"
#import "SNUserPortrait.h"
#import <SohuLiveSDK-News/SohuLiveSDK-News.h>
//#import <SohuLiveSDK-News/SohuLiveSDK-News.h>
//#import <SohuLiveSDK-News/SLUserCoreInfoModel.h>
#if DEBUG_MODE
#import <VZInspector.h>
#endif
#import "SNSSOSinaWrapper.h"
#import "SNMySDK.h"
#import "SNWDefine.h"
#import "SNPickStatisticRequest.h"
#import "SNOpenWayManager.h"
#import "SNUserSearchable.h"
#import "SNNewsUninterestedService.h"
#import "SNNewMeViewController.h"
#import "SNStoryPageViewController.h"
#import "SNPushGuideAlert.h"
#import "SNScreenshotRequest.h"
#import "SNFavoriteViewController.h"
#if defined SDK_ARCKTRACKER
#if !TARGET_IPHONE_SIMULATOR
#import "AHMonitor.h"
#endif
#endif

#import <WatchConnectivity/WatchConnectivity.h>
#import <notify.h>
#import "SNAppStateManager.h"
#import "SNLogManager.h"
#import "SNStatisticsManager.h"
#import "SNPushAlert.h"
#import "SNAlertStackManager.h"
//CLL add

#import <JsKitFramework/JsKitFramework.h>
#import "SNNewsGrabAuthority.h"
#import "SHH5CommonApi.h"
#import "SHH5WidgetApi.h"
#import "SHH5ADApi.h"

#import "SNRedPacketManager.h"

#define NotificationLock CFSTR("com.apple.springboard.lockcomplete")
#define NotificationChange CFSTR("com.apple.springboard.lockstate")
#define NotificationPwdUI CFSTR("com.apple.springboard.hasBlankedScreen")

#import "APOpenAPI.h"
#import "SNAPOpenApiHelper.h"
#import "SNRedPacketModel.h"

#import "Main.h"
#import "SNCacheManager.h"
#import "SNWeiboHelper.h"

#import "SNNewsSSOOpenUrl.h"
#import "SNNewsCheckToken.h"

#import "SNStoryUtility.h"
#import <AlipaySDK/AlipaySDK.h>

//#import <iflyMSC/iflyMSC.h>
#import "SNNewAlertView.h"
#import "SNAdvertiseManager.h"
#import "SNSoundManager.h"
#import <SCMobileAds/SCMobileAds.h>
#import "SNSpecialActivity.h"
#import "SNDynamicPreferences.h"

#import "SNNewsPPLogin.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
static UIBackgroundTaskIdentifier __backgroundTask;
static BOOL isLaunchingFinish = NO;

//iOS10 点击通知处理 5.7.2 by wangchuanwe
@interface sohunewsAppDelegate ()<SNSplashViewDelegate,SKStoreProductViewControllerDelegate, WCSessionDelegate, JKZipArchiveDelegate, UNUserNotificationCenterDelegate> {
    Reachability *_networkReachability;
    CGRect _rectNavigation;
    BOOL _isGuideViewShow;
    BOOL _didInitH5Framework;
    dispatch_semaphore_t _handOff_dispatch_group;
    BOOL _ignoreSplashView;
    /**
     *  提供watch会话
     */
    WCSession *_session;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNUserNotificationCenter *_notifacationCenter;
    //iOS10 点击通知处理 5.7.2 by wangchuanwe
#endif
        
#if defined SDK_ARCKTRACKER
#if !TARGET_IPHONE_SIMULATOR
    AHMonitor *tracker; //用于打渠道包时统计使用, 需要的时候需要手动添加库文件
#endif
#endif
}

@property (nonatomic, copy) NSString *handoffNewUrl;
@property (nonatomic, strong) SNNewUserGuideViewController *userGuideViewController;
@property (nonatomic, strong) UIImageView *screenImageView;

@end

@implementation sohunewsAppDelegate

#pragma mark - Lifecycle
- (id)init {
    if (self = [super init]) {
        _pushNotificationQueue = [[SNLineraQueue alloc] init];
        _localNotifInfo = [[NSMutableDictionary alloc] init];
        _hadReceiveRemoteNotificationAfterAppKilledOrInstallFirstly = NO;
        _didColdStart = YES;
        _hotStart = NO;
        _becomeAcitveByIcon = YES;
        [SNNotificationManager
         addObserver:self
         selector:@selector(handleShowSplashViewNotification:)
         name:kShowSplashViewNotification
         object:nil];
        
        _handOff_dispatch_group = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)setStartCount {
    NSString *oldShortVer = [[NSUserDefaults standardUserDefaults] stringForKey:kBundleVersionKey];
    NSString *newVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey];
    
    _startCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    
    if ([newVersion isEqualToString:oldShortVer]) {
        _startCount++;
    } else {
        _startCount = 1;
    }
    
    if (1 == _startCount) {
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:kNewUserGuideHadBeenShown];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newVersion
                                              forKey:kBundleVersionKey];
    [[NSUserDefaults standardUserDefaults] setInteger:_startCount
                                               forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#if defined SDK_ARCKTRACKER
#if !TARGET_IPHONE_SIMULATOR
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^) (UIBackgroundFetchResult))completionHandler {
    [[AHMonitor shareInstanceWithAppkey:@"shios3"] startMonitor];
    completionHandler(UIBackgroundFetchResultNewData);
}
#endif
#endif

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册消息处理异常函数的处理方法
    registerExceptionHandler();
    ///记录App开始执行代码的时间
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t0"];
    _becomeAcitveByIcon = NO;
    
    [SNOpenWayManager sharedInstance].hotstart = NO;
#if defined SDK_ARCKTRACKER
#if !TARGET_IPHONE_SIMULATOR
    //启动监测
    if (nil == tracker) {
        tracker = [AHMonitor shareInstanceWithAppkey:@"shios3"];
        [tracker startMonitor];
    }
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
#endif
#endif
    
    //注册北研统计SDK
    [SNUtility registCompassSDK];
    
    /**
     * 主线程中初始化App网络状态
     * 1）initNetworkCheck内部Reachability内部实现依赖CFRunLoopGetCurrent()
     * 2）后续网络请求(SplashModel等)会依赖isNetworkReachable状态
     */
    [self initNetworkReability];

    /**
     * 注册设备并返回cid
     * 否则会导致后续使用SNClientRegister的成员变量值不同步。
     */
    [[SNClientRegister sharedInstance] updateClientInfoToServer];
    
    /**
     *  新品算广告SDK 配置
     */
    [[SCADAdsManager sharedInstance] setup]; // 启动广告服务

#if DEBUG_MODE
    //加载用于"设置App"里的配置信息
    SNPreferenceStatus *preferenceStatus = [[SNPreference sharedInstance] loadAndCheckChanged];
    if (preferenceStatus.needRegisterClient) {
        [[SNClientRegister sharedInstance] reset];
    }

    //是否开启app监测
    BOOL appInspector = [SNPreference sharedInstance].appInspectorEnabled;
    if (appInspector) {
        [VZInspector setShouldHookNetworkRequest:NO];
        [VZInspector setShouldHandleCrash:YES];
        [VZInspector showOnStatusBar];
    }
    /**
     *  广告SDK 配置
     */
    [SNADManager sharedSTADManager].adHostType = [SNPreference sharedInstance].adScreenshotSwitch ? SNADRequestADHostTypeAppScreen: ([[SNPreference sharedInstance] testModeEnabled] ? SNADRequestADHostTypeDebug : ([SNPreference sharedInstance].simulateOnLineEnabled ? SNADRequestADHostTypePre : SNADRequestADHostTypeRelease));
    
    /**
     *  新品算广告SDK 配置
     */
    BOOL testMode = [[SNPreference sharedInstance] testModeEnabled] || [SNPreference sharedInstance].simulateOnLineEnabled;
    [SCADAdsManager sharedInstance].debugLogEnabled = testMode ? YES : NO;// 是否打开调试日志
    [SCADAdsManager sharedInstance].testServerEnabled = testMode ? YES : NO;// 是否打开测试服务
#endif
    
    //替换某些系统方法的默认实现
    [self swizzleMethods];
    
    [self setStartCount];

    //初始化日夜间模式
    NSString *currentTheme = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeSelectedKey];
    if (currentTheme && [currentTheme length] > 0) {
        [[SNThemeManager sharedThemeManager] setCurrentTheme:currentTheme];
    } else {
        [[SNThemeManager sharedThemeManager] setCurrentTheme:kThemeDefault];
    }
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        [DKNightVersionManager nightFalling];
    } else {
        [DKNightVersionManager dawnComing];
    }
    
    //初始化TabBarViewController以及TabItem对应的ViewControllers
    _navigator = [TTNavigator navigator];
    _navigator.persistenceMode = TTNavigatorPersistenceModeNone;
    _navigator.window = [[SNWindow alloc] initWithFrame:TTScreenBounds()];
    _window = _navigator.window;
    [_window makeKeyAndVisible];
    [SNNavigatorMap mapTabBarAndTabItemControllers];
    [_navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
    [[self appTabbarController] loadTabs];
    [SNNavigatorMap mapBusinessViewControllers];
    
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    _ignoreSplashView = [self isIgnoreSplashURL:url];
    
    BOOL isNewVersion = ![[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadBeenShown];
    
    //测试
    //[SNUtility recordIsFirstInstallOrUpdateApp:YES];
    
    if (isNewVersion) {
        //新版本/覆盖安装
        //记录第一次使用客户端的时间
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:kRecordFirstOpenNewsKey];
        
        //数据库有效性检测和迁移
        [self checkDatabase];
        [[SNDBMigrationController sharedInstance] migrate];
        //新版本覆盖安装, 如果使用要闻改版, 保留要闻数据
        if ([SNNewsFullscreenManager newsChannelChanged]) {
            [[SNDBManager currentDataBase] clearRollingNewsListExceptChannelID:@"1"];
        } else {
            [[SNDBManager currentDataBase] clearRollingNewsList];
        }
        
        //首次安装启动App
        [SNUtility recordIsFirstInstallOrUpdateApp:YES];
        
        //覆盖安装，初次应显示编辑流
        [userDefaults setBool:YES forKey:kShouldShowEditModeNewsKey];
//        [userDefaults removeObjectForKey:kRecordEveryDayEnterAppDateKey];
//        [userDefaults removeObjectForKey:kRecordEnterBackgroundAppDateKey];
        [userDefaults synchronize];
                
        if (kNewUserGuideSwitch && !_ignoreSplashView) {
            ///展示引导页(新版本并且引导页开关OPEN)
            self.userGuideViewController = [[SNNewUserGuideViewController alloc] init];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNewUserGuideHadEndShown];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _userGuideViewController.delegate = self;
            [_navigator.window addSubview:_userGuideViewController.view];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewUserGuideHadBeenShown];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewUserGuideHadEndShown];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self splashViewDidShow];
            [[SNStatisticsManager shareInstance] recordAppStartStage:@"t6"];
        }
    } else {
        ///展示loading广告
        if (_isNetworkReachable && !_ignoreSplashView) {
            if (LoadingSwitch) {
                if (!_splashModel) {
                    self.splashModel = [[SNSplashModel alloc] initWithRefer:SNSplashViewReferAppLaunching delegate:self];
                }
                [_splashModel showSplashIsCountDown:YES];
            } else {
                if (![[SNAlertStackManager sharedAlertStackManager] isShowing]) {
                    if (!_splashViewController) {
                        self.splashViewController = [[SNSplashViewController alloc] initWithRefer:SNSplashViewReferAppLaunching delegate:self];
                    }
                    _splashViewController.isFirstShow = YES;
                    [_window addSubview:_splashViewController.view];
                } else {
                    [self splashViewDidShow];
                }
            }
        }else{
            [self splashViewDidShow];
        }
    }
    
    if (![SNUtility isFirstInstallOrUpdateApp] &&
        ![SNUtility isListGOSync]) {
        [SNUtility recordIsFirstInstallOrUpdateApp:YES];
    }
    
    //初始化千帆sdk wangshun 2017.5.4
    [self initSCApplication];

    dispatch_queue_t default_background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    BOOL isOpenAppFromPush = NO;
    [SNAppUsageStatManager sharedInstance].isFromLaunch = YES;
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSString *launchString = [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
    if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
        isOpenAppFromPush = YES;
        [SNRollingNewsPublicManager sharedInstance].isOpenNewsFromPush = YES;
        NSMutableDictionary *pushUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        NSString *url = [userInfo stringValueForKey:@"url" defaultValue:@""];
        if (url.length > 0) {
            if ([[url lowercaseString] hasPrefix:kProtocolNews] ||
                [[url lowercaseString] hasPrefix:kProtocolPhoto] ||
                [[url lowercaseString] hasPrefix:kProtocolVote]) {
                if ([self isUpdateNumTime:SNNews_Push_Back_FocusNews_ValidTime]) {
                    [pushUserInfo setObject:SNNews_Push_Back_FocusNews
                                     forKey:SNNews_Push_Back_Key];
                } else {
                    [pushUserInfo setObject:SNNews_Push_Back_RecomNews
                                     forKey:SNNews_Push_Back_Key];
                }
            }
        }
        
        [_pushNotificationQueue checkIn:pushUserInfo];
        [[SNAPNSHandler sharedInstance] didReceiveRemoteNotification:pushUserInfo];
        
        _hadReceiveRemoteNotificationAfterAppKilledOrInstallFirstly = YES;
        [[SNAppUsageStatManager sharedInstance] statAppLaunchingRefer:SNAppLaunchingRefer_Push];
        dispatch_async(default_background_queue, ^{
            [[SNAppUsageStatManager sharedInstance] statAppResigning];
        });
    } else {
        if (launchOptions) {
            UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
            if (localNotif) {
                isOpenAppFromPush = YES;
                _localNotif = localNotif;
            }
        }
        
        if (launchString.length == 0 || !launchString) {
            [[SNAppUsageStatManager sharedInstance] statAppLaunchingRefer:SNAppLaunchingRefer_iCon];
            dispatch_async(default_background_queue, ^{
                [[SNAppUsageStatManager sharedInstance] statAppResigning];
            });
        }
    }
    
    dispatch_async(default_background_queue, ^{
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if (url != nil) {
            NSString *urlStr = url.absoluteString;
            if ([[urlStr lowercaseString] hasPrefix:kSohuNewsIphoneNews] ||
                [[urlStr lowercaseString] hasPrefix:kSohuNewsIphonePhoto] ||
                [[urlStr lowercaseString] hasPrefix:kSohuNewsIphoneVote]) {
                [self setBackWhere];
            }
            //打开方式统计用
            if (isOpenAppFromPush == NO) {
                [[SNOpenWayManager sharedInstance] analysisAndPostURL:urlStr
                                                                 from:nil
                                                           openOrigin:kOther];
            }
        } else if (launchString.length > 0) {
            [self setBackWhere];
        } else {
            if ((launchString.length == 0 || !launchString) && isOpenAppFromPush == NO) {
                [[SNOpenWayManager sharedInstance] analysisAndPostURL:nil
                                                                 from:kAppIconTp openOrigin:kAppIcon];
            }
        }
        
        NSDate *date = [SNUtility getSettingValidTime:6];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:SNNews_Push_Back_FocusNews_ValidTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 判断pid是否在白名单下
        [SNNewsGrabAuthority newsGrabAuthority];
    });
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    _ignoreSplashView = [self isIgnoreSplashURL:url];
    if ([url.absoluteString hasPrefix:@"sohunewsvideosdk://"]) {
        [SNUtility shouldAddAnimationOnSpread:NO];
        [[ActionManager defaultManager] handleUrl:[url absoluteString]];
    }
    _becomeAcitveByIcon = NO;
    //为了让播放器暂停
    //为了解决Bug：播放过程中进入后台，然后通过微信等第三方App打开新的一个新闻页，之前播放的视频已不可以见了，但becomeActive时会自动播
    [self performSelector:@selector(pausePlayer) withObject:self afterDelay:0.1];

    [[SNAppUsageStatManager sharedInstance] statAppLaunchingRefer:SNAppLaunchingRefer_Other];
    
    if ([url.absoluteString isEqualToString:@"sohunewsiphone://com.sohu.newspaper.collection"]) { // 暂时先写死协议,用于新的widget打开收藏
        [SNNotificationManager postNotificationName:kCloseKeyboardNotification object:nil];

        if ([[TTNavigator navigator].topViewController isKindOfClass:[SNFavoriteViewController class]]) {
            UIViewController *favoritrVC = (SNFavoriteViewController *)[TTNavigator navigator].topViewController;
            [favoritrVC.flipboardNavigationController popViewControllerAnimated:NO];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://homeCorpus"] applyAnimated:YES] applyQuery:@{kIsWidgetOpen:@1}];
            [[TTNavigator navigator] openURLAction:_urlAction];
        });
    }
    
    //兼容老的包名
    if ([url.absoluteString hasPrefix:@"sohunewsiphone://"]) {
        NSMutableString *absURL = [NSMutableString stringWithString:url.absoluteString];
        NSRange range = {0, @"sohunewsiphone://".length};
        [absURL replaceCharactersInRange:range withString:@"sohunews://"];
        
        url = [NSURL URLWithString:absURL];
    }

    if ([url.absoluteString hasPrefix:kSchemeUrlSNS]) {
        [SNNotificationManager postNotificationName:kAppBecomeActivityNotification object:nil];
        
        SNSLib *lib = [SNSLib sharedInstance];
        if (!lib.delegate) {
            [[SNMySDK sharedInstance] setupSNS];
        }
        //视频app 分享直接进入 咱们app 首次启动 没有登录状态 原因:snmysdk.delegate=nil
        //狐友内部 登录状态是用[[[SNSLib sharedInstance].delegate getLoginStatusInfo][@"loginStatus"] boolValue]
        // wangshun
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^() {
            [SNUtility openSNSSchemeUrl:url.absoluteString];
        });
    }
    
    if ([url.absoluteString hasPrefix:@"aliauthsohu://"]) {
        [[SNRedPacketModel sharedInstance] handleOpenURL:url];
    }
    
    if ([url.absoluteString hasPrefix:@"alipayHuyou://"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                  }];
        return YES;
    }
    
    if ([url.absoluteString hasPrefix:@"aliStorySohu://"]) {
        //添加支付宝
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
        }];
        return YES;
    }
    
    if ([url.absoluteString hasPrefix:@"sohunews://pr/"]) {
        NSString *openWayURL = nil;
        NSRange range = [url.absoluteString rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            openWayURL = [url.absoluteString substringFromIndex:range.location + 1];
            NSString *urlStr = [url.absoluteString substringToIndex:range.location];
            if ([urlStr isContainChineseCharacter] || [urlStr containsString:@"{"] || [urlStr containsString:@"}"]) {
                urlStr = [NSString stringWithString:[urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                urlStr = [urlStr stringByAppendingFormat:@"?%@", openWayURL];
                url = [NSURL URLWithString:urlStr];
            }
            
            if ([urlStr hasPrefix:@"sohunews://pr/"] && ![url.absoluteString containsString:@"startfrom"]) {
                [[SNOpenWayManager sharedInstance] analysisAndPostURL:openWayURL
                                                                 from:nil
                                                           openOrigin:kOther];
            }
        } else {
            range = [url.absoluteString rangeOfString:@"todaywidget"];
            if (range.location != NSNotFound) {
                [[SNOpenWayManager sharedInstance] analysisAndPostURL:url.absoluteString from:kTodaywidget openOrigin:kOther];
            } else {
                [[SNOpenWayManager sharedInstance] analysisAndPostURL:openWayURL
                                                                 from:nil
                                                           openOrigin:kOther];
            }
            //适配视频页 by cuiliangliang
            if ([[self appTabbarController].tabbarView currentSelectedIndex] != TABBAR_INDEX_VIDEO) {
                  [SNNotificationManager postNotificationName:kOpenNewsFromWidgetNotification object:nil];
            }
        }
    }
    
    [[SNAppUsageStatManager sharedInstance] statAppResigning];

    //新浪微博(AppKey:1315804458)、腾讯微博(AppKey:801126133)、QQ；另注：腾讯微博在iOS低版本(5.0)采用SSO方式，iOS高版本(6.0及以上)采用OAuth方式认证
    if ([SNNewsSSOOpenUrl handleOpenURL:url sourceApplication:sourceApplication annotation:annotation]){
        return YES;
    } else if ([self handleOpenUrl:url]) {
        return YES;
    } else if ([APOpenAPI handleOpenURL:url
                               delegate:[SNAPOpenApiHelper sharedInstance]]) {
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //补丁：字号调整后，无条件设置setting参数，导致每次都重新绘制celltitle，在app后台时，设置NO
    [SNUtility customSettingChange:NO];
    
    self.leftDate = [NSDate date];
    
    _hotStart = YES;
    [SNOpenWayManager sharedInstance].hotstart = YES;
    _ignoreSplashView = NO;
    
    [[SNSkinMaskWindow sharedInstance] resignAppActive];
    UIViewController *controller = [[TTNavigator navigator] visibleViewController];
    _rectNavigation = controller.flipboardNavigationController.view.frame;
    if ([controller isKindOfClass:[SNThemeViewController class]]) {
        [((SNThemeViewController *)controller) viewControllerWillResignActive];
    }
    
    //取消定时检查快讯
    [_rollingNewsCheckTimer invalidate];

    //关闭广告Timer
    [SNCheckManager stopCheckService];
    
    //关闭长连接Push消息系统Timer
    //[[SNMessageMgr sharedInstance] stopTimer];
    
    //记录应用非激活状态开始时间
    [[SNAppStateManager sharedInstance] setInactiveDate:[NSDate date]];
    //app退后退时间，记录下次打开时间间隔
    [SNOpenWayManager setAppLeaveTime:[NSDate date]];
    _becomeAcitveByIcon = YES;
    
    if ([[SNQRUtility sharedInstanced] isScanning]) {
        [[SNQRUtility sharedInstanced] handleEnterBackground:^{}];
    }
    //存储特殊浮层广告展示状态
    [[SNSpecialActivity shareInstance] saveSpecialAdState];

    _openUrl = nil;
    _openUrlHandled = NO;
    
    [SNSLib appRunStatus:RunStatus_applicationWillResignActive];
    [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //推入后台，上报当前频道停留时长
    int totalSec = [[SNRollingNewsPublicManager sharedInstance] rollingNewsTotalTime];
    if (totalSec != 0) {
        [SNNewsReport reportChannelStayDuration:totalSec channelID:[SNUtility sharedUtility].currentChannelId];
    }
    [self setScreenShotImageView:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:[SNUtility changeNowDateToSysytemDate:[NSDate date]]
//                     forKey:kRecordEnterBackgroundAppDateKey];
    if ([[userDefaults objectForKey:kIntelligetnLocationSwitchKey] boolValue] &&
        ![userDefaults objectForKey:kRequestLocalChannelTimeKey]) {
        [userDefaults setObject:[NSDate date] forKey:kRequestLocalChannelTimeKey];
    }
    [userDefaults synchronize];
    
    [SNUtility sharedUtility].isEnterBackground = YES;

    [SNSLib appRunStatus:RunStatus_applicationDidEnterBackground];
    
    _hotStart = YES;
    [SNOpenWayManager sharedInstance].hotstart = YES;
    [self fixiOS6PinyinCrash];
    [[SNRollingNewsPublicManager sharedInstance] recordLeaveHomeTime];
    
    // 设置app长时间未使用本地提醒
    [SNLocalNotifReminder setupLocalNotifications];
    
    //挂起下载器
    [[SNDownloadScheduler sharedInstance] doSuspendIfNeeded];
    
    // 记住当前Tab
    [[self appTabbarController] saveCurrentTabIndex];
    
#if AUTO_CLEAR_CACHE_ENABLE
    [[SNCacheCleanerManager sharedInstance] cleanAutomatically];
#endif
    
    // 暂停wifi下自动离线
    [[SNNewsPreloader sharedLoader] pauseAllWifiDownloadOperations];
    
    //保存曝光记录到文件
    //[[SNNewsExposureManager sharedInstance] saveAllExposureNewsToFile];
    
    //向服务器发送访问时间
    [[SNAppUsageStatManager sharedInstance] statAppResigning];
    
    [application beginReceivingRemoteControlEvents];
    [[SNBusinessStatisticsManager shareInstance] upload];
    
    if (LoadingSwitch) {
        if (_splashModel && [_splashModel isSplashVisible]) {
//            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [_splashModel exitSplash];
        }
    } else {
        if (_splashViewController && [_splashViewController isSplashViewVisible]) {
//            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [_splashViewController enterApp];
        }
    }
    
    /*****************锁屏闪退的bug，modify by h*********************/
    if (__backgroundTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:__backgroundTask];
        __backgroundTask = UIBackgroundTaskInvalid;
    }
    __backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:__backgroundTask];
        __backgroundTask = UIBackgroundTaskInvalid;
    }];
    /******************** End by h ******************/
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[SNRollingNewsPublicManager sharedInstance] recordRollingNewsBeginTime];
    [SNUtility recordShowEditModeNewsFromBack:YES];
    [self setScreenShotImageView:NO];
    
    //app调起时，注册异常，重新注册p1
    if (![SNUtility isRightP1]) {
        [[SNClientRegister sharedInstance] registerClientAnyway];
    }
    
    dispatch_queue_t default_background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //请求密钥
    dispatch_async(default_background_queue, ^() {
        [[SNRedPacketManager sharedInstance] requestRedPacketKey];
    });
    
    dispatch_async(default_background_queue, ^() {
        if ([SNUtility isRightP1]) {
            //setting.go
            [[SNAppConfigManager sharedInstance] requestConfigAsync];
            //可定制化活动弹窗
            [[SNSpecialActivity shareInstance] requestActivityInfo];
        }
    });

    //记录应用激活状态时间
    [[SNAppStateManager sharedInstance] setActiveDate:[NSDate date]];
    
    //5.2.2 App进入后台或锁屏时间超过30分钟，所有频道重置刷新
    NSNumber *interval = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"kRefreshChannelInterval"];
    if ([[SNAppStateManager sharedInstance] reloadWithChannelNewsTime:interval.intValue]) {
        _didColdStart = NO;
        [[SNAppStateManager sharedInstance] removeAllChannelRefreshList];
        [SNRollingNewsPublicManager sharedInstance].resetHome = YES;
        
        [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = YES;
    }
    
    [SNSLib appRunStatus:RunStatus_applicationWillEnterForeground];

    if (__backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:__backgroundTask];
        __backgroundTask = UIBackgroundTaskInvalid;
    }
    
    _isEnterForeground = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [SNNotificationManager postNotificationName:kHideStatusbarWhenAppearNotification object:nil];
    
    [[SNAppUsageStatManager sharedInstance] statAppLaunching];
    
    NSString *token = [[NSUserDefaults standardUserDefaults]
                       objectForKey:kDevicetokenKey];
    
    if (nil == token && nil != [SNClientRegister sharedInstance].deviceToken) {
        [[NSUserDefaults standardUserDefaults] setObject:[SNClientRegister sharedInstance].deviceToken forKey:kDevicetokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[SNClientRegister sharedInstance] updateClientInfoToServer];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[SNUserSearchable sharedInstance] requestSpotlightData];
    }
    
    if ([SNUtility isAllowUseLocation]) {
        [SNUserLocationManager sharedInstance].isRefreshLocation = NO;
        [SNUserLocationManager sharedInstance].isRefreshChannelLocation = NO;
        [[SNUserLocationManager sharedInstance] updateLocation];
    }
    
    
    UIViewController *user_vc = [[TTNavigator navigator] topViewController];
    if ([user_vc isKindOfClass:[SNNewMeViewController class]]) {
        //用户画像 从后台进前台还要再刷一下
        SNNewMeViewController *me_vc = (SNNewMeViewController *)user_vc;
        [me_vc applicationWillEnterForeground];
    } else if ([user_vc isKindOfClass:[SNStoryPageViewController class]]) {
        SNStoryPageViewController *pageViewController = (SNStoryPageViewController *)user_vc;
        //户进入阅读页的时候进行埋点上报(首次进入和 切后台后再次进入)
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic_read&tp=pv&bookId=%@",pageViewController.novelId]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (_hotStart == YES && _becomeAcitveByIcon == YES) {
        [[SNOpenWayManager sharedInstance] analysisAndPostURL:nil
                                                         from:kAppIconTp openOrigin:kAppIcon];
        _becomeAcitveByIcon = NO;
    }
    //后台进入前台时，自动收起红包
    if ([SNRedPacketManager sharedInstance].redPacketShowing) {
        [SNNotificationManager postNotificationName:kGetUserRedPacketNotification
                                             object:nil];
    }
    
    if (_hotStart) {
        NSTimeInterval deltaTime = [[NSDate date] timeIntervalSinceDate:self.leftDate];
        deltaTime = deltaTime * 1000;//换算成毫秒
        NSTimeInterval settingTime = [[SNAppConfigManager sharedInstance] reShowSplashADInterval];
        if (deltaTime < settingTime) {
            [SNUserDefaults setBool:NO forKey:kShowLoadingPageKey];
        } else {
            if ([SHVideoForNewsSDK isPlayerBeingShowedInFullScreen]) {
                [SNUserDefaults setBool:NO forKey:kShowLoadingPageKey];
            } else {
                if (!_ignoreSplashView) {
                    if (LoadingSwitch) {
                        if (!_splashModel) {
                            self.splashModel = [[SNSplashModel alloc] initWithRefer:SNSplashViewReferWillEnterForeground delegate:self];
                            [self.splashModel showSplashIsCountDown:YES];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                         (int64_t)(2 * NSEC_PER_SEC)),
                                           dispatch_get_main_queue(), ^{
                                               UIViewController *rootViewController = [[TTNavigator navigator].topViewController.flipboardNavigationController rootViewController];
                                               if ([rootViewController respondsToSelector:@selector(showTabbarView)]) {
                                                   [rootViewController setTabbarViewLocked:NO];
                                                   [rootViewController showTabbarView];
                                               }
                                           });
                        } else {
                            self.splashModel.splashRefer = SNSplashViewReferWillEnterForeground;
                            [self.splashModel showSplashViewWhenActive];
                        }
                    } else {
                        if (![[SNAlertStackManager sharedAlertStackManager] isShowing]) {
                            if (!_splashViewController) {
                                self.splashViewController = [[SNSplashViewController alloc] initWithRefer:SNSplashViewReferWillEnterForeground delegate:self];
                                _splashViewController.isFirstShow = YES;
                                [_window addSubview:_splashViewController.view];
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                             (int64_t)(2 * NSEC_PER_SEC)),
                                               dispatch_get_main_queue(), ^{
                                                   UIViewController *rootViewController = [[TTNavigator navigator].topViewController.flipboardNavigationController rootViewController];
                                                   if ([rootViewController respondsToSelector:@selector(showTabbarView)]) {
                                                       [rootViewController setTabbarViewLocked:NO];
                                                       [rootViewController showTabbarView];
                                                   }
                                               });
                            } else {
                                self.splashViewController.splashViewRefer = SNSplashViewReferWillEnterForeground;
                                [_splashViewController showSplashViewWhenActive];
                            }
                        }
                    }
                }
            }
        }
    }
    
    //SNS
    [SNSLib appRunStatus:RunStatus_applicationDidBecomeActive];

    //处理红包和优惠卷口令
    [[SNRedPacketManager sharedInstance] dealPasteboard];
    
    //删除超过24小时的阅读记录
    [SNRollingNewsPublicManager deleteReadTimeOutNews];
    //上次日志搜集
    [[SNLogManager sharedInstance] logAndFileSend];
    
    //App激活时，检测是否需要自动切换日间模式
    //isLaunchingFinish 启动app时，设置夜间模式自动关闭不在激活处处理，否则tabbar显示为空
    if (isLaunchingFinish == YES) {
        [self dealAppCurrentTheme];
    }
    isLaunchingFinish = YES;
    
    [[SNSkinMaskWindow sharedInstance] becameAppActive];
    dispatch_queue_t default_background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    //清空push通知列表
    [self clearPushBadgeNumbers];
    
    if (_rectNavigation.origin.y < 0) {
        [self performSelector:@selector(showNavigationController)
                   withObject:self afterDelay:0.01];
    }
    
    if (!_isColdLaunch) {
        _isColdLaunch = YES;
        //启动时检验账号有效性
//        [[SNUserManager shareInstance] checkTokenValid];
        //delayRefreshShareManager = [SNNewsCheckToken checkTokenRequest];
        
        [SNNewsCheckToken checkTokenRequest];
    } else {
        [[SNClientRegister sharedInstance] updateClientInfoToServer];
    }
    
    //检查是否有新快讯
    [self performSelector:@selector(refreshRollingNews)
               withObject:nil afterDelay:2];
    
    if (_localNotif) {
        [self openLive:_localNotif.userInfo];
    }
    //废弃
//    dispatch_async(default_background_queue, ^{
//        //更新本地通知信息
//        [[SNLiveSubscribeService sharedInstance] refreshSubscribeInfo];
//    });
    
    dispatch_async(default_background_queue, ^{
        //取消长时间未启动应用检测提醒
        [SNLocalNotifReminder cancelLocalNotifications];
    });
    
    [SNCheckManager startCheckService:DefaultRefreshInterval];
    
    //启动之后刷新下默认天气
    if ([SNClientRegister sharedInstance].isRegisted) {
        if ([[self appTabbarController].tabbarView currentSelectedIndex] != 1) {
            dispatch_async(default_background_queue, ^{
                [[SNWeatherCenter defaultCenter] refreshDefaultCityWeather:nil];
            });
        }
    }
    [self refreshVisibleController];
    
    //SSO Reset Some State.
//    [SNSSOAdapter handleApplicationDidBecomeActive];//已废弃
    
    if (!_openUrlHandled && _openUrl) {
        [self performSelector:@selector(handleOpenUrl:)
                   withObject:[NSURL URLWithString:[_openUrl absoluteString]]];
        _openUrlHandled = YES;//5.1修改widget bug 38950
    }
    
    dispatch_async(default_background_queue, ^{
        //继续wifi下自动离线
        [[SNNewsPreloader sharedLoader] resumeAllWifiDownloadOperation];
    });
    
    //4.0 用户行为拦截 启动到前台后及时刷新最新的拦截配置 by jojo
    if ([SNClientRegister sharedInstance].isRegisted &&
        [SNClientRegister sharedInstance].isDeviceModelAdapted) {
        //不能在后台线程中发送请求，后台线程的runloop默认没有启动，请求发不出去
        [SNInterceptConfigManager refreshConfig];
    }
    
    /**
     * 初始化视频下载器:
     * 1) 把之前没有下载完的数据库视频属性(进度、状态等)同步到内存
     * 2) 把Terminate时正在下载的视频状态更改为暂停并同步到数据库
     */
    dispatch_async(default_background_queue, ^{
        [SNVideoDownloadManager sharedInstance];
    });
    
    /**
     * 特别说明：
     * 冷启动都会刷新setting.go接口
     * 冷启动时：
     *      升级检查完毕时(didFinishUpgradeCheck)，如果无需升级会则先请求setting.go再调用“活动弹窗“；如果需升级提示则只请求setting.go接口数据。
     * 热启动：
     *      每次都要请求setting.go接口， 之后再调用“活动弹窗“。
     */
//    if (_hotStart) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////            setting.go
//            if ([SNUtility isRightP1]) {
//                [[SNAppConfigManager sharedInstance] requestConfigAsync];
//            }
//            
//            //可定制化活动弹窗
//            [[SNSpecialActivity shareInstance] requestActivityInfo];
//            
////            dispatch_async(dispatch_get_main_queue(), ^{
////                [[self appTabbarController].tabbarView updateTabButtonTitle];
////            });
////            if ([[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadEndShown]) {
////                dispatch_async(dispatch_get_main_queue(), ^{
////                    [[SNPopupActivityCenter defaultCenter] popupActivityIfNeeded];
////                });
////            }
//        });
//    }
    if (_hotStart && ![SNUtility isFromChannelManagerViewOpened]) {
        [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:[SNUtility sharedUtility].currentChannelId];
    }
    /// 检查是否有符合条件的弹窗
    if (![SNUtility sharedUtility].isOpenFromUniversalLinks) {
        [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];
    }

}

- (void)pausePlayer {
    SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    [timelineVideoPlayer stop];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [SNSLib appRunStatus:RunStatus_applicationWillTerminate];
    [self closeDatabase];
    [SNNotificationManager postNotificationName:kSaveChannelsToCacheNotification
                                         object:nil];
    [SNNotificationManager postNotificationName:kRollingChannelChangedNotification
                                         object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEnterChannelManageViewTag];

    //App退出时清空加载记录，App重新启动时，重置刷新 wyy
    [[SNAppStateManager sharedInstance] removeAllChannelRefreshList];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:@"getBarHeight_first"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:@"notifyLocalChange_first"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 此段代码是用于判断H5debug开关开启时长，app每次退出都去判断一下，时长一周后关闭 2017.3.13 liteng
    if ([[NSUserDefaults standardUserDefaults] stringForKey:SNH5DebugSwitchKey]) {
        NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970];
        NSString *switchKey = [[NSUserDefaults standardUserDefaults] stringForKey:SNH5DebugSwitchKey];
        if (1 == switchKey.integerValue) {
            NSString *keepTime = [[NSUserDefaults standardUserDefaults] objectForKey:SNH5DebugSwitchKeepTime];
            if ((currentDate - keepTime.doubleValue) > 60 * 60 * 24 * 7) {
                // 开关开启大于一周关闭
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SNH5DebugSwitchKey];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SNH5DebugSwitchKeepTime];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SNWeatherCenter defaultCenter] clean];
    [[TTURLCache sharedCache] removeAll:NO];
    [[SNThemeManager sharedThemeManager] dumpAllCachedImages];
    [[SNThemeManager sharedThemeManager] clearAllCachedImages];
    
    //清楚图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - === Begin: Public区段 ===
- (BOOL)isGuideViewShow {
    return _isGuideViewShow;
}

- (BOOL)shouldDownloadImagesManually {
    if ([SNPreference sharedInstance].pictureMode == kPicModeWiFi &&
        [self isWWANNetworkReachable]) {
        return YES;
    }
    return NO;
}

- (SNTabBarController *)appTabbarController {
    TTURLMap *map = _navigator.URLMap;
    id obj = [map objectForURL:@"tt://tabBar"];
    if (obj) {
        return (SNTabBarController *)obj;
    }
    return nil;
}

- (BOOL)canOpenInnerAppStoreWithAppId:(NSString *)appId {
    __block BOOL bRet = NO;
    if (appId.length > 0) {
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self;
        
        NSDictionary *productParameters = @{SKStoreProductParameterITunesItemIdentifier : appId};
        [SNNotificationCenter showLoadingAndBlockOtherActions:@"请稍后..."];
        
        [storeController loadProductWithParameters:productParameters
                                   completionBlock:^(BOOL result, NSError *error) {
            [SNNotificationCenter hideLoadingAndBlock];
            if (!result) {
                [SNNotificationCenter showExclamation:@"应用加载失败"];
            }
        }];
        
        //在LoadProductWithParameters Block 中弹出storeController，
        //连接不上appstore时会卡住UI
        [[[TTNavigator navigator] topViewController] presentViewController:storeController animated:YES completion:nil];
        bRet = YES;
    }
    
    return bRet;
}
#pragma mark === End: Public区段 ===

- (void)initH5Framework {
    if (!_didInitH5Framework) {
        NSURLCache *cache = [NSURLCache sharedURLCache];
        cache.memoryCapacity = 4 * 1024 * 1024;
        cache.diskCapacity = 32 * 1024 * 1024;
        [JKGlobalSettings defaultSettings].zipArchiveDelegate = self;
        [JsKitClient globelInit];
        [JsKitClient addGlobelJavascriptInterface:[SHH5CommonApi shareInstance]
                                          forName:@"commonApi"];
        [JsKitClient addGlobelJavascriptInterface:[SHH5WidgetApi shareInstance]
                                          forName:@"widgetApi"];
        [JsKitClient addGlobelJavascriptInterface:[SHH5ADApi shareInstance]
                                          forName:@"adApi"];
        _didInitH5Framework = YES;
    }
}

- (void)initSCApplication {
    //wangshun 2017.5.4
    SLNewsConfig *config = [[SLNewsConfig alloc] init];
    
    config.appLoginNotificationName = [SNSLib getSnsUserLoginNotiName];
    config.appLogoutNotificationName = [SNSLib getSnsUserLogoutNotiName];
    //提供返回用户主要信息的能力(包括passport 和 token)
    
    [[SCApplication sharedApplication] prepareUserInfo:^SCAppUserInfoModel *{
        NSDictionary* userInfoDic = [SNSLib getSnsUserInfo];
        SNDebugLog(@"userInfoDic:%@",userInfoDic);
        NSString* passport = [userInfoDic objectForKey:@"passport"];
        NSString* token    = [userInfoDic objectForKey:@"token"];
        NSString* gid      = [SNUserManager getGid];//GID拿我们的
        NSString* nickName = [userInfoDic objectForKey:@"name"];
        
        SCAppUserInfoModel* userCoreInfoModel = [[SCAppUserInfoModel alloc] initWithPassport:passport token:token gid:gid];
        
        userCoreInfoModel.nickName = nickName;
        userCoreInfoModel.appId = SNNewsPPLogin_APPID;
        userCoreInfoModel.UA    = [SNNewsPPLogin getUA];
        return userCoreInfoModel;
    }];
    
    //提供返回用户是否登录的能力
    [[SCApplication sharedApplication] prepareLoginState:^BOOL{
        return [SNSLib isSnsUserLogin];
    }];
    
    //设置当前主题以及主题变化通知名等配置信息
    config.appThemeSwitchNotificationName = kThemeDidChangeNotification;
    config.darkTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    [[SLNewsApplication sharedApplication] startService:config];
    //准备弹出分享方式
    
    [[SCApplication sharedApplication] receiveDoShare:^(SCShareModel *model, UIViewController *baseVC) {
        /**
         model.sRoomId 房间号
         model.sTitle 标题
         model.sDescription 摘要
         model.sImageUrl 图片地址
         model.sRoomUrl 房间H5地址
         */
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
            [SNUtility forceScreenPortrait];
        }
        
        NSString *shareProtocolString = [NSString stringWithFormat:@"%@link=%@&title=%@&content=%@&icon=%@&roomID=%@&shareOrigin=qianfan", kProtocolShare, [model.sRoomUrl URLEncodedString], [model.sTitle URLEncodedString], [model.sDescription URLEncodedString], [model.sImageUrl URLEncodedString], model.sRoomId];
        
        [SNUtility openProtocolUrl:shareProtocolString context:nil];
        [[SNUtility sharedUtility] setLastOpenUrl:nil];
    }];
    
    //准备隐藏分享方式
    [[SCApplication sharedApplication] receiveHideShare:^{
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            NSArray *subViews = [[TTNavigator navigator].window subviews];
            for (UIView *view in subViews) {
                if ([view isKindOfClass:[SNNewAlertView class]])
                    [view removeFromSuperview];
            }
        }
    }];
    
    [[SCApplication sharedApplication] prepareAppLoginPage:^(UIViewController *baseVC) {
        [SNUtility openProtocolUrl:@"login://backUrl=" context:nil];
    }];
}

- (void)didPopViewController {
    [[SNUtility sharedUtility] setLastOpenUrl:nil];
}


#pragma mark - === Begin: Delegate区段 ===
#pragma mark Delegate - SNSplashViewDelegate
//此处是用来在loading页显示出来之后做的整个程序的初始化操作
- (void)splashViewDidShow {
    [self setUpAPP];
}

- (void)splashViewWillExit {
    [self guideMaskDidFinish];
}

- (void)splashViewDidExit {
    [self setUpAPP];
    [self setUpAPPWithLowPriority];
    //从3DTouch启动搜索页面时, Loading页消失时通知显示键盘
    [SNNotificationManager postNotificationName:kIs3DTouchShowKeyboard object:nil];
}

#pragma mark - Delegate - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [SNNotificationCenter hideLoadingAndBlock];
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark === End: Delegate区段 ===

#pragma mark - === Begin: Private区段 ===
#pragma mark - Private - Normal
- (void)loadMainVCData {
    [SNNotificationManager postNotificationName:kSNRollingNewsViewControllerInitContentNotification object:nil];
}

- (void)mainViewDidAppear {
    ///无网络情况下启动以及没有splash页的情况下
    if (LoadingSwitch) {
        if (!_splashModel && !_userGuideViewController) {
            [self setUpAPPWithLowPriority];
        }
    } else {
        if (!_splashViewController && !_userGuideViewController) {
            [self setUpAPPWithLowPriority];
        }
    }
}

- (void)setUpAPP {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /////////////////////////////主线程处理 START/////////////////////////
        //注册通知
        [self registerRemoteNotification];
        
//        /**
//         *  新品算广告SDK 配置
//         */
//        BOOL testMode = [[SNPreference sharedInstance] testModeEnabled] || [SNPreference sharedInstance].simulateOnLineEnabled;
//        [[SCADAdsManager sharedInstance] setup]; // 启动广告服务
//        [SCADAdsManager sharedInstance].debugLogEnabled = testMode ? YES : NO;// 是否打开调试日志
//        [SCADAdsManager sharedInstance].testServerEnabled = testMode ? YES : NO;// 是否打开测试服务
        
        [[SNUserLocationManager sharedInstance] updateLocation];
        
        //为watch共享一些数据
        [self initAppGroupWithWatch];
        
        //0.初始化webView和h5的机制
        [self initH5Framework];
        
        //记录加载时访问时间
        [[SNAppUsageStatManager sharedInstance] statAppLaunching];
        
        //App重启，重置频道流 wangyy
        [[SNAppStateManager sharedInstance] removeAllChannelRefreshList];
        [SNRollingNewsPublicManager sharedInstance].resetHome = YES;
        [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
        
        //加载频道流数据
        [self loadMainVCData];
        
        [self dealAppCurrentTheme];
        
        //初始化网络请求采样机制
        [SNSamplingFrequencyGenerator sharedInstance];
        
        //弱网下启动SNS不能获取登录状态
        [[SNMySDK sharedInstance] setupSNS];
        
        //禁用网络请求时 系统状态栏上的小菊花 by jojo (PS. 不让别人轻易发现我们在发各种统计)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        //3DTouch
        NSString *platFormString = [[UIDevice currentDevice] platformForSohuNews];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 &&
            ![platFormString containsString:@"iPod"]) {
            //iPod 9.0.1 Crash
            if ([self.window.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
                if (self.window.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
                    [self createShortcutItem];
                }
            }
        }
        
        /////////////////////////////主线程处理 END/////////////////////////
        
        /////////////////////////////子线程处理 START/////////////////////////
        dispatch_queue_t default_background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(default_background_queue, ^(){
            if ([SNUtility isRightP1]) {
                //setting.go
                [[SNAppConfigManager sharedInstance] requestConfigAsync];
                //可定制化活动弹窗
                [[SNSpecialActivity shareInstance] requestActivityInfo];
            }
            
            //强制更新，避免SNS不返回
            [[self appTabbarController].tabbarView updateTabButtonTitle];
            
            [UCPostLog postLog];
            [[SNBusinessStatisticsManager shareInstance] upload];
            
            //请求密钥
            [[SNRedPacketManager sharedInstance] requestRedPacketKey];
            
            //初始化视频SDK
            [SHVideoForNewsSDK shareInstance];
            [SHMoviePlayerController registerAppKey:@"sohunews_2dxk4@(s!a;E8*0q"];
            
            [SNNotificationManager addObserver:self
                                      selector:@selector(didPopViewController)
                                          name:kPopViewControllerNotification
                                        object:nil];
            
            //Version 4.0 用户行为拦截 add by jojo
            [SNInterceptConfigManager initConfig];
            
            [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
            
            [[SNDBExportor sharedInstance] exportDB];
            
            [[TTURLCache sharedCache] setDisableImageCache:YES];
            
            [self showASIBandWidthIfNeeded];
            
            //清空用户评论列表
            [[SNDBManager currentDataBase] clearNewsComment];
            
            [SNUtility recordShowEditModeNewsFromBack:NO];
            
            [SNExternalLinkHandler sharedInstance].isAppLoad = YES;
            NSURL *url = [[SNExternalLinkHandler sharedInstance] loadExternalLinkFromConfigFile];
            if (nil != url) {
                [[SNExternalLinkHandler sharedInstance] setExternalLink:url];
            }
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kIntelligetnLocationSwitchKey] boolValue]) {
                [[SNUserLocationManager sharedInstance] notifyLocalChange];
            }
            
            //添加Spotlight支持
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                [[SNUserSearchable sharedInstance] requestSpotlightData];
            }
            
            //正文H5化，覆盖安装第一次打开H5页会获取不到夜间模式
            JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
            [jsKitStorage setItem:[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2] forKey:@"settings_fontSize"];
            [jsKitStorage setItem:[NSNumber numberWithBool:[[SNThemeManager sharedThemeManager] isNightTheme]] forKey:@"settings_nightMode"];
            NSString *imageMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
            if (imageMode.integerValue == 1) {
                imageMode = @"2";
            } else if (imageMode.integerValue == 2) {
                imageMode = @"1";
            }
            [jsKitStorage setItem:[NSNumber numberWithInteger:imageMode.integerValue] forKey:@"settings_imageMode"];
            [jsKitStorage setItem:[NSNumber numberWithInteger:SNAppABTestStyleNO] forKey:@"settings_abtest_mode"];
            
            // 添加截屏通知
            [SNNotificationManager addObserver:self
                                      selector:@selector(userDidTakeScreenshot:)
                                          name:UIApplicationUserDidTakeScreenshotNotification
                                        object:nil];
            //小说登录设置
            [SNStoryUtility loginTipCloseStateWithState:YES];
            
            //setting.go
//            [[SNAppConfigManager sharedInstance] requestConfigAsync];
        });
        /////////////////////////////子线程处理 END/////////////////////////
        
        /////////////////////////////DEBUG_MODE START/////////////////////////
#if DEBUG_MODE
        
        if ([SNPreference sharedInstance].simulateRoadnaviEnabled) {
            //h5 debug开关，便于h5调试
            [JKGlobalSettings defaultSettings].debugMode = YES;
        }
        
        if ([SNPreference sharedInstance].memUsageEnabled) {
            _memory = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 30)];
            _memory.backgroundColor = [UIColor clearColor];
            _memory.textColor = [UIColor blueColor];
            _memory.font = [UIFont systemFontOfSize:12.0];
            [_window addSubview:_memory];
            
            //注意：Timer放到子线程里是因为：Timer在主线程中使用会阻塞UI主线程。在子线程里启timer就可以解决这个问题，如果需要更新UI再回到主线程更新UI即可。
            dispatch_async(default_background_queue, ^{
                NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1] interval:0.5 target:self selector:@selector(getRemainMemery) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
            });
        }
#endif
        /////////////////////////////DEBUG_MODE END/////////////////////////
    });
}

- (void)setUpAPPWithLowPriority {
    ///这里处理优先级不高的启动事件
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //清空push通知列表
        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [self clearPushBadgeNumbers];
        [[SNAppConfigManager sharedInstance] requestActivityTipsInfo];
        [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
        
        /////////////////////////////延迟处理START/////////////////////////
        //处理handoff
        //确保self.handoffNewUrl被赋值之后 才在这里打开
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_wait(_handOff_dispatch_group, DISPATCH_TIME_FOREVER);
            //自测发现可能会白屏 发生在未显示广告倒计时时 延迟调用貌似能解决 ？
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.handoffNewUrl) {
                    [SNUtility openProtocolUrl:strongSelf.handoffNewUrl];
                }
            });
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([SNPushGuideAlert shouldShowPushGuideAlert]) {
                SNPushGuideAlert *guideAlert = [[SNPushGuideAlert alloc] initWithAlertViewData:nil];
                [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:guideAlert];
            }
            [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:[SNUtility sharedUtility].currentChannelId];
        });
        
        [SNUtility registerSharePlatform];
        /////////////////////////////延迟处理END/////////////////////////
    });
}

- (void)updateLocalTermId {
    NSDictionary *_pushNotificationData = (NSDictionary *)[_pushNotificationQueue objectAtIndex:0];
    if (!_pushNotificationData) {
        return;
    }
    NSString *pushURLStr = [_pushNotificationData objectForKey:kNotifyUrlKey];
    if (nil == pushURLStr) {
        pushURLStr = [_pushNotificationData objectForKey:kNotifyKey]; //v3.0.1以前都看pushurl属性，仍然收快讯报纸
        pushURLStr = [pushURLStr stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
    }

    if (_pushNotificationData && _pushNotificationData.count > 0 &&
        pushURLStr &&
        ![@"" isEqualToString:pushURLStr]) {
        if (pushURLStr.length && ([pushURLStr hasPrefix:kProtocolPaper] || [pushURLStr hasPrefix:kProtocolDataFlow])) {
            NSString *schema = ([pushURLStr hasPrefix:kProtocolPaper] ? kProtocolPaper : kProtocolDataFlow);
            NSMutableDictionary *userInfo = [SNUtility parseProtocolUrl:pushURLStr schema:schema];
            NSString *_subid = [userInfo objectForKey:@"subId"]; //此处实际上是pubId
            NSString *_termid = [userInfo objectForKey:@"termId"];
            if (userInfo && userInfo.count > 0 && _subid && _termid) {
                NSString *__pubId = _subid;
                NSString *__termId = _termid;
                NSMutableDictionary *changeInfo = [NSMutableDictionary dictionary];
                [changeInfo setObject:__termId forKey:TB_SUB_CENTER_ALL_SUB_TERM_ID];
                
                //去掉刊物‘新’标记
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectByPubId:__pubId];
                                
                if (subObj) {
                    [subObj setStatusValue:[kNO_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
                    [changeInfo setObject:subObj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
                }
                
                [changeInfo setObject:@"yes" forKey:@"manulSetStatus"];
                
                [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectByPubId:__pubId withValuePairs:changeInfo];
                
                //通知
                [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:nil];
            }
        }
    }
}

// 在直播间内收到该场比赛的push
- (BOOL)isLiveGameVisible:(NSString *)liveId {
    BOOL bWatching = NO;
    UIViewController *controller = [[TTBaseNavigator globalNavigator] visibleViewController];
    if ([controller isKindOfClass:[SNThemeViewController class]]) {
        bWatching = [((SNThemeViewController *)controller) isLiveGameShowing:liveId];
    }
    return bWatching;
}

- (BOOL)checkForLivePush:(NSDictionary *)userInfo {
    NSString *pushURLStr = [userInfo objectForKey:kNotifyUrlKey];
    if ([pushURLStr startWith:kProtocolLive]) {
        NSDictionary *dict = [SNUtility parseURLParam:pushURLStr schema:kProtocolLive];
        NSString *liveId = [dict stringValueForKey:@"liveId" defaultValue:nil];
        if ([self isLiveGameVisible:liveId]) {
            [_pushNotificationQueue checkOut];
            
            // 如果是直播邀请，发送邀请通知消息
            NSString *busi = [dict stringValueForKey:@"busi" defaultValue:nil];
            if (busi) {
                [SNNotificationManager postNotificationName:kSNLiveInviteNotification object:nil];
            }
            return YES;
        }
    }
    return NO;
}

- (void)dismissAlertOrActionSheet {
    if ([SNAppstoreRateHelper sharedInstance].rateAlertView &&
        [[SNAppstoreRateHelper sharedInstance].rateAlertView isVisible]) {
        [[SNAppstoreRateHelper sharedInstance].rateAlertView dismissWithClickedButtonIndex:2 animated:YES];
    }
    
    // 关闭actioinSheet
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"_UIAlertOverlayWindow")]) {
            NSArray *arr =[self allSubViews:window];
            UIActionSheet *actionSheet = nil;
            for (UIView *v in arr) {
                if ([v isKindOfClass:[UIActionSheet class]]) {
                    actionSheet = (UIActionSheet *)v;
                    break;
                }
            }
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
        }
    }
}

- (BOOL)isIgnoreSplashURL:(NSURL *)url {
    NSString * urlKey = url.absoluteString;
    if (urlKey.length > 0 && [urlKey containsString:@"ignoreLoadingAd=1"]) {
        return YES;
    }
    return NO;
}

#pragma mark -iOS10以前 通知处理 begin
//热启动时（后台挂起之后进入）查看推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)receivedUserInfo {
    [SNSLib clearSNSBadgeNumberWithRemoteNotification:receivedUserInfo];
    [self clearPushBadgeNumbers];
    
    //5.9.0以下、iOS10以下版本不接收新版push
    id pushAlert = nil;
    NSDictionary *apsDict = [receivedUserInfo objectForKey:kPushAPS];
    pushAlert = [apsDict objectForKey:kPushAlert];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") && [pushAlert isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    self.receivePushURL = [receivedUserInfo objectForKey:kNotifyUrlKey];
    if ([self.receivePushURL hasPrefix:kProtocolSNS]) {
        if (application.applicationState == UIApplicationStateActive) {
            //前台收到SNS相关push不显示，SNS需求
            return;
        }
        else {//通知栏调起，上报
            NSDictionary *snsDict = [SNSLib parameterForPushProtocalUrl:self.receivePushURL];
            if (snsDict) {
                NSString *msgID = [snsDict stringValueForKey:@"msgId" defaultValue:@""];
                NSString *pushType = [snsDict stringValueForKey:@"pushType" defaultValue:@""];
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"newsId=%@&s1=huyou&s2=push&s3=%@&uid=%@", msgID, pushType, [SNUserManager getUserId]]];
            }
        }
    }
    
    //下面代码别删，用来测试服务器下发的push数量的功能代码，push服务端总出问题。
//    id badge = [apsDict objectForKey:@"badge"];
//    if(nil != badge){
//        if([badge isKindOfClass:[NSNumber class]]){
//            [[SNToast shareInstance] showToastWithTitle:[NSString stringWithFormat:@"%ld",[badge intValue]] toUrl:nil mode:SNToastUIModeFeedBackCommon];
//        }else{
//            [[SNToast shareInstance] showToastWithTitle:badge toUrl:nil mode:SNToastUIModeFeedBackCommon];
//        }
//    }
    
    //有红包时，不显示消息推送
    if ([SNRedPacketManager sharedInstance].redPacketShowing) {
        return;
    }
    // 狐友界面,部分页面拦截掉push(具体由狐友控制)
    if (![SNSLib isPushViewShouldOpenInSNSView] && application.applicationState == UIApplicationStateActive) {
        return;
    }
    
    //正文页有右滑返回提示不显示推送
    if ([SNUtility sharedUtility].isShowRightSlipeTips) {
        return;
    }
    
    //视频播放页面不显示消息推送
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"VideoDetailViewController")]) {
        return;
    }
    
    [[SNAppUsageStatManager sharedInstance] statAppLaunchingRefer:SNAppLaunchingRefer_Push];
    
    [[SNOpenWayManager sharedInstance] analysisAndPostURL:[receivedUserInfo objectForKey:@"url"] from:kApplePushTp openOrigin:kAppPush];
    _becomeAcitveByIcon = NO;
    

    self.receiveLocalDict = [SNUtility parseURLParam:[receivedUserInfo objectForKey:@"url"] schema:kProtocolChannel];
    
    NSMutableDictionary *userInfo = nil;
	if ((receivedUserInfo && _isEnterForeground) || application.applicationState == UIApplicationStateActive) {
        userInfo = [NSMutableDictionary dictionaryWithDictionary:receivedUserInfo];
        [userInfo setObject:@"1" forKey:@"fromPush"];
        if (!(application.applicationState == UIApplicationStateActive)) {
            userInfo = [self treatmentUserInfo:userInfo];
        }

        [_pushNotificationQueue checkIn:userInfo];

        [[SNAPNSHandler sharedInstance] didReceiveRemoteNotification:userInfo];
	}
    
    //只会在后台挂起(UIApplicationStateBackground)的时候运行，即程序后台挂起的时候接收到了通知
	if (application.applicationState != UIApplicationStateActive) {
        [SNRollingNewsPublicManager sharedInstance].isOpenNewsFromPush = YES;
        //收到了通知 发个notify
        [SNNotificationManager postNotificationName:kNotifyDidReceive object:nil userInfo:userInfo];
        [self updateLocalTermId];
        BOOL showPayPasswordPage = [[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"SNVoucherCenterViewController")] && application.applicationState == UIApplicationStateInactive;
        if ([[self appTabbarController].tabbarView currentSelectedIndex] == 1 || showPayPasswordPage) {
            [_pushNotificationQueue checkOut];
            return;
        }
        
        CGFloat delayTime = 1.0;
        if ([SNUtility sharedUtility].isEnterBackground) {
            delayTime = 0.5;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SNUtility shouldUseSpreadAnimation:NO];
            [[SNAPNSHandler sharedInstance] handleReciveNotifyWithFromBack:YES];
        });
        
        NSString *pushURLStr = [userInfo objectForKey:kNotifyUrlKey];//v3.0.1开始看url属性，为了兼容老版本不能接收即时新闻推送
        if (nil == pushURLStr) {
            pushURLStr = [userInfo objectForKey:kNotifyKey]; //v3.0.1以前都看pushurl属性，仍然收快讯报纸
        }
        
        [[SNUserTrackRecorder sharedRecorder] setPushPage:[SNUserTrack trackWithPage:notify_push link2:pushURLStr]];
        
        NSString *actionID = nil;
        if ([pushURLStr containsString:@"pushType=7"]) {
            //智能报盘
            actionID = @"13";
        } else {
            actionID = @"3";
        }
        [SNNewsReport reportPDotGo:actionID msgID:[SNUtility getPushMsgID:pushURLStr]];
        
        if ([[self.receiveLocalDict objectForKey:@"channelId"] isEqualToString:kLocalChannelUnifyID]) {
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=push2channel&_tp=pv&tochannelid=%@&track=%@", kLocalChannelUnifyID, [pushURLStr URLEncodedString]]];//push 频道统计
        }
	}
    //程序运行中接收到了通知
	else {
        // 若当前正在此比赛的直播间观看，则不显示alertview
        if ([self checkForLivePush:userInfo]) {
            return;
        }

		id apsDic = [userInfo objectForKey:kPushAPS];
        if (apsDic) {
            if ([apsDic isKindOfClass:[NSDictionary class]]) {
                pushAlert = [apsDic objectForKey:kPushAlert];
            } else if ([apsDic isKindOfClass:[NSString class]]) {
                pushAlert = apsDic;
            }
            
            [self processPushWithPushAlert:pushAlert receiveDict:receivedUserInfo];
        }
	}
}

- (void)processPushWithPushAlert:(id)pushAlert
                     receiveDict:(NSDictionary *)receiveDict {
    NSString *pushTitle = nil;
    NSString *pushContent = nil;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        if (pushAlert && [pushAlert isKindOfClass:[NSDictionary class]]) {
            pushTitle = [pushAlert objectForKey:kPushTitle];
            pushContent = [pushAlert objectForKey:kPushBody];
        }
    }
    else {
        if (pushAlert && [pushAlert isKindOfClass:[NSString class]]) {
            pushContent = pushAlert;
        }
    }
    
    if (pushContent.length == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCustomPushWithUserInfo:receiveDict
                                 message:pushContent title:pushTitle];
    });
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self clearPushBadgeNumbers];
    if (!(application.applicationState == UIApplicationStateActive)) {
        SNDebugLog(@"### didReceiveLocalNotification ### app not active");
        
        //notification.applicationIconBadgeNumber = 0;
        
        NSString *liveId = [notification.userInfo objectForKey:kLiveIdKey];
        if (liveId) {
            [self openLive:notification.userInfo];
            [[SNLiveSubscribeService sharedInstance] refreshSubscribeInfo];
        }
    }
    //程序运行中接收到了通知
    else {
        //notification.applicationIconBadgeNumber = 0;
        
        NSString *liveId = [notification.userInfo objectForKey:kLiveIdKey];
        if (liveId) {
            BOOL bHasShowed = [[_localNotifInfo objectForKey:liveId] boolValue];
            
            NSString *alertStr = notification.alertBody;
            if (!bHasShowed && alertStr && [alertStr length]) {
                // 若当前正在此比赛的直播间观看，则不显示alertview
                BOOL bWatching = [self isLiveGameVisible:liveId];

                if (!bWatching) {
                    [self dismissAlertOrActionSheet];
                
                    [_localNotifInfo setObject:@"1" forKey:liveId];
                    NSString *title = NSLocalizedString(@"liveRoom", @"liveRoom");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showCustomPushWithUserInfo:notification.userInfo
                                                 message:alertStr title:title];
                    });
                }
            }
            [[SNLiveSubscribeService sharedInstance] refreshSubscribeInfo];
        }
    }
}
    
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    NSString *pushUrlString = [userInfo objectForKey:@"url"];
    [self notificationActionIdentifierWithIdentifier:identifier pushUrlString:pushUrlString];
    
    if (completionHandler) {
        completionHandler();
    }
}
#pragma mark -iOS10以前 通知处理 end

#pragma mark -iOS10 通知处理 begin
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//iOS10 点击通知处理 5.7.2 by wangchuanwen
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    UNNotificationRequest *request = response.notification.request;
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //远程通知处理
        NSString *pushUrlString = [request.content.userInfo objectForKey:@"url"];
        NSString *identifier = response.actionIdentifier;
        if ([identifier isEqualToString:kCustomPushShareIdentifier] ||
           [identifier isEqualToString:kCustomPushNoInterestIdentifier]) {
            //点击通知其他按钮
            [self notificationActionIdentifierWithIdentifier:identifier pushUrlString:pushUrlString];
        } else if ([identifier rangeOfString:@"ificationDefaultActionIdentifier"].length > 0) {
            //点击通知进入
            [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:request.content.userInfo];
        }
    } else {
        //本地通知处理
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = request.content.userInfo;
        [self application:[UIApplication sharedApplication] didReceiveLocalNotification:localNotification];
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [self application:application didReceiveRemoteNotification:userInfo];
}
#endif

#pragma mark -iOS10 通知处理 end
// 5.7.2 iOS10兼容 update by wangchuanwen begin
- (void)notificationActionIdentifierWithIdentifier:(NSString *)identifier
                                     pushUrlString:(NSString *)pushUrlString {
    if ([identifier isEqualToString:kCustomPushShareIdentifier]) {
        if ([[self appTabbarController].tabbarView currentSelectedIndex] == 1) {
            [_pushNotificationQueue checkOut];
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //延迟1s执行，防止未启动app，分享时打开正文页白屏
            [SNUtility openProtocolUrl:pushUrlString];
            //调起分享浮层
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SNNotificationManager postNotificationName:kFromPushOpenShareFloatViewNotification object:nil];
            });
            [SNNewsReport reportADotGif:@"_act=pv&stat=s&st=tongzhilan&newsfrom=10"];
        });
    } else if ([identifier isEqualToString:kCustomPushNoInterestIdentifier]) {
        //不感兴趣
        NSString *schema = nil;
        NSString *newsKey = nil;
        if ([pushUrlString hasPrefix:kProtocolNews]) {
            schema = kProtocolNews;
            newsKey = @"newsId";
        }
        else if ([pushUrlString hasPrefix:kProtocolPhoto]) {
            schema = kProtocolPhoto;
            newsKey = @"newsId";
        }
        else if ([pushUrlString hasPrefix:kProtocolLive]) {
            schema = kProtocolLive;
            newsKey = @"liveId";
        }
        else if ([pushUrlString hasPrefix:kProtocolSub]) {
            schema = kProtocolSub;
            newsKey = @"subId";
        }
        else if ([pushUrlString hasPrefix:kProtocolVote]) {
            schema = kProtocolVote;
            newsKey = @"newsId";
        }
        else if ([pushUrlString hasPrefix:kProtocolChannel]) {
            schema = kProtocolChannel;
            newsKey = @"channelId";
        }
        
        NSMutableDictionary *userInfo = [SNUtility parseProtocolUrl:pushUrlString schema:schema];
        NSString *newsType = [userInfo objectForKey:@"newsType"];
        if (newsType.length == 0) {
            newsType = @"3";
        }
        [[SNNewsUninterestedService sharedInstance] uninterestedNewsWithType:newsType newsId:[userInfo objectForKey:newsKey]];
        
        [SNNewsReport reportADotGif:@"_act=cc&page=0&topage=&fun=70"];
    }
}


- (void)showCustomPushWithUserInfo:(NSDictionary *)userInfo
                           message:(NSString *)message
                             title:(NSString *)title {
    NSString *pushUrlString = [userInfo objectForKey:@"url"];
    NSString *showType = nil;
    if ([pushUrlString containsString:@"showType=0"]) {
        showType = @"0";
    } else {
        showType = @"1";
    }
    if ([showType isEqualToString:@"1"]) {
        //强提示
        SNPushAlert *pushAlert = [[SNPushAlert alloc] initWithAlertViewData:userInfo];
        [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:pushAlert];
    } else {//弱提示
        [[SNToast shareInstance] showToastWithTitle:message toUrl:pushUrlString userInfo:nil mode:SNToastUIModeFeedBackCommon];
    }
}


/**
 * 递归遍历view的所有子view直到找到UIActionSheet
 */
- (NSArray *)allSubViews:(UIView *)v {
    NSMutableArray *tmp = [NSMutableArray array];
    for (UIView *v1 in v.subviews) {
        [tmp addObject:v1];
        if ([v1 isKindOfClass:[UIActionSheet class]]) {
            return tmp;
        }
        [tmp addObjectsFromArray:[self allSubViews:v1]];
    }
    return tmp;
}

- (void)openLive:(NSDictionary *)notificationDict {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSString *liveId = [notificationDict objectForKey:kLiveIdKey];
    NSString *liveType = [notificationDict objectForKey:kLiveTypeKey];
    
    if (liveId) {
        [userInfo setObject:liveId forKey:kLiveIdKey];
    }
    
    if (liveType) {
        [userInfo setObject:liveType forKey:kLiveTypeKey];
    }
    
    if (liveId) {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://live"] applyAnimated:YES] applyQuery:userInfo];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	if ([SNClientRegister sharedInstance].deviceToken) {
		[SNClientRegister sharedInstance].deviceToken = nil;
	}
    
    NSMutableString *tokenString = [NSMutableString stringWithString:[[NSString stringWithFormat:@"%@", deviceToken] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]]];
    
    for (NSInteger i = tokenString.length - 1; i >= 0; i--) {
        if ([tokenString characterAtIndex:i] == ' ') {
            NSRange r = {i, 1};
            [tokenString deleteCharactersInRange:r];
        }
    }
    
	[SNClientRegister sharedInstance].deviceToken = [tokenString trim];
	
    //重要日志，采用NSLog输出
	SNDebugLog(@"apn token = %@", [SNClientRegister sharedInstance].deviceToken);
	
	NSString *deviceTokenSaved = [[NSUserDefaults standardUserDefaults] objectForKey:kDevicetokenKey];
	if ([SNClientRegister sharedInstance].deviceToken == nil
        || ![[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadBeenShown]  // 第一次启动必须报
        || ([SNClientRegister sharedInstance].deviceToken
            && ![[SNClientRegister sharedInstance].deviceToken isEqualToString:deviceTokenSaved])) {
		//Save token
        [SNClientRegister sharedInstance].deviceTokenChanged = YES;
		[[NSUserDefaults standardUserDefaults] setObject:[SNClientRegister sharedInstance].deviceToken forKey:kDevicetokenKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[SNClientRegister sharedInstance] updateClientInfoToServer];
        [SNClientRegister sharedInstance].deviceTokenChanged = NO;
	}
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //重要日志，采用NSLog输出
	SNDebugLog(@"Error in registration. Error: %@", error);
    
    [SNClientRegister sharedInstance].deviceToken = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDevicetokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SNClientRegister sharedInstance] updateClientInfoToServer];
}

#pragma mark - Private - Network Reachablity
- (void)initNetworkReability {
    [SNNotificationManager addObserver:self selector:@selector(reachabilityChanged:)
                                  name:kReachabilityChangedNotification object:nil];
    _networkReachability = nil;
	_networkReachability = [Reachability reachabilityForInternetConnection];
	[_networkReachability startNotifier];
	self.isNetworkReachable = [_networkReachability currentReachabilityStatus] != NotReachable;
}

- (Reachability *)getInternetReachability {
    return _networkReachability;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    if ([curReach isKindOfClass:[Reachability class]]) {
        if ([curReach currentReachabilityStatus] != NotReachable &&
            ![SNUtility isRightP1]) {
            [[SNClientRegister sharedInstance] registerClientAnyway];
        }
        if (curReach == _networkReachability) {
            self.isNetworkReachable = [_networkReachability currentReachabilityStatus] != NotReachable;
            if (!_isNetworkReachable) {
                if ([[self appTabbarController].tabbarView currentSelectedIndex] == 1) {
                    return;
                }
                [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            } else {
                [[SNClientRegister sharedInstance] setupCookie];
            }
        }
    }
}

- (BOOL)isCurrentNetworkReachable {
    NetworkStatus status = [_networkReachability currentReachabilityStatus];
    return (status == ReachableViaWWAN ||
            status == ReachableVia2G ||
            status == ReachableVia3G ||
            status == ReachableVia4G ||
            status == ReachableViaWiFi);
}

- (BOOL)isWWANNetworkReachable {
    NetworkStatus status = [_networkReachability currentReachabilityStatus];
    return (status == ReachableViaWWAN ||
            status == ReachableVia2G ||
            status == ReachableVia3G ||
            status == ReachableVia4G);
}

- (NetworkStatus)currentNetworkStatus {
    return [_networkReachability currentReachabilityStatus];
}

- (NSString *)currentNetworkStatusString {
    return [[SNAdvertiseManager sharedManager] getCurrentNetworkType];
}

#pragma mark - Private - DataBase
- (void)checkDatabase {
    SNStopWatch *watch = [SNStopWatch watch];
    if ([SNPreference sharedInstance].debugModeEnabled) {
        [watch begin];
    }
    
    BOOL bCorrupted = [[SNDBMigrationManager sharedInstance] isDatabaseCorrupted];
    
    if ([SNPreference sharedInstance].debugModeEnabled) {
        [watch stop];
        [watch print:@"check DB"];
    }
    
    if (bCorrupted) {
        SNDebugLog(@"===DB is corrupted after migration.");
        [[SNDBMigrationManager sharedInstance] migrateBaseOnSqliteFileInBunle];
    }
}

- (void)closeDatabase {
	[self.database close];
}

#pragma mark - Loading页保存图片的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    if (error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"PhotoDownloadFail_IOS6", @"") toUrl:nil mode:SNCenterToastModeWarning];
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"PhotoSavedToAlbum", @"Photo Saved To Album") toUrl:nil mode:SNCenterToastModeSuccess];
    }
}

#pragma mark - 升级检查回调
//冷启动升级检查时会回调到这里
- (void)didFinishUpgradeCheck:(BOOL)needAlertUpgradeMessage {
    [SNUpgradeHelper sharedInstance].delegate = nil;
    
    [[self appTabbarController].tabbarView updateTabButtonTitle];
    
//    //无升级提示时需要进行“活动弹窗“(有活动就弹、无就不弹)
//    if (!needAlertUpgradeMessage) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [[SNAppConfigManager sharedInstance] requestConfigSync];
//            
//            [[self appTabbarController].tabbarView updateTabButtonTitle];
//            SNPopupActivity *activity = [[SNAppConfigManager sharedInstance] popupActivity];
//            if (activity.identifier.length <= 0 || [activity.identifier isEqualToString:@"0"]) {
//                return;
//            }
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(activity.popupActivityTimeDelayAfterShowLoading * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [[SNPopupActivityCenter defaultCenter] popupActivityIfNeeded];
//            });
//        });
//    } else {
//        [[self appTabbarController].tabbarView updateTabButtonTitle];
//    }
}

#pragma mark - Private 
- (void)guideMaskDidFinish {
    // 改方法是在子线程中调用，检查升级需要在主线程中 ?
    dispatch_async(dispatch_get_main_queue(), ^{
        //检查升级，并顺带检查网络是否可用然后负责提示出来
        [SNUpgradeHelper sharedInstance].delegate = self;
        [[SNUpgradeHelper sharedInstance] checkUpgrade];
    });
}

- (void)getRemainMemery {
    if ([SNPreference sharedInstance].memUsageEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _memory.text = [NSString stringWithFormat:@"mem:%.2fm", [UIDevice getAvailableMemory]];
        });
    }
}

- (void)fixiOS6PinyinCrash {
    // iOS6中文输入后锁屏之后就会crash，加上之后不会
    if (__backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:__backgroundTask];
        __backgroundTask = UIBackgroundTaskInvalid;
    }
    __backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:__backgroundTask];
        __backgroundTask = UIBackgroundTaskInvalid;
    }];
}

- (void)swizzleMethods {
    NSError *error = nil;
    [UIImage jr_swizzleClassMethod:@selector(imageNamed:) withClassMethod:@selector(altImageNamed:) error:&error];
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        [UIFont jr_swizzleClassMethod:@selector(systemFontOfSize:) withClassMethod:@selector(altSystemFontOfSize:) error:&error];
        [UIFont jr_swizzleClassMethod:@selector(boldSystemFontOfSize:) withClassMethod:@selector(altBoldSystemFontOfSize:) error:&error];
    }
    [UIButton jr_swizzleMethod:@selector(setTitleColor:forState:) withMethod:@selector(altSetTitleColor:forState:) error:&error];
    // For crashlytics log by jojo
    [TTRequestLoader swithExtendMethod];
}

//当整个应用BecomeActive时，“刊物”、“滚动新闻”、“组图”视图可见时，就刷新列表数据
- (void)refreshVisibleController {
    if (_didColdStart) {
        _didColdStart = NO;
        return;
    }
    
    UIViewController *_vc = [TTNavigator globalNavigator].visibleViewController;
    if ([_vc isKindOfClass:[SNThemeViewController class]]) {
        [((SNThemeViewController *)_vc) refreshTableViewDataWhenAppBecomeActive];
    } 
}

// 检查新闻快讯
- (void)refreshRollingNews {
    if (_rollingNewsCheck == nil) {
        _rollingNewsCheck = [[SNRollingNewsCheckLatest alloc] init];
    }
    if (_rollingNewsCheckTimer == nil) {
        _rollingNewsCheckTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(refreshRollingNews) userInfo:nil repeats:YES];
    }
    
    if (_hadReceiveRemoteNotificationAfterAppKilledOrInstallFirstly) {
        _hadReceiveRemoteNotificationAfterAppKilledOrInstallFirstly = NO;
        return;
    }
    [_rollingNewsCheck checkExpressNews];
}

- (BOOL)handleOpenUrl:(NSURL *)openUrl {
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"VideoDetailViewController")]) {
        [SHVideoForNewsSDK quitMovieFullScreenCompletetion:^{}];
    }
    [SNUtility forceScreenPortrait];
    [SNUtility shouldUseSpreadAnimation:NO];
    
//    if ([[self appTabbarController].tabbarView currentSelectedIndex] == TABBAR_INDEX_VIDEO && [openUrl.absoluteString rangeOfString:kSchemeUrlSNS].location == NSNotFound && [openUrl.absoluteString rangeOfString:kProtocolTab].location == NSNotFound) {
//         _openUrlHandled = NO;
//        _backWhere = nil;
//         return _openUrlHandled;
//    }
    
    if ([[openUrl absoluteString] hasPrefix:kSohuNewsUrlSchema]) {
        _openUrlHandled = NO;
        _openUrl = openUrl;
        
        if (_isColdLaunch) {
            NSString *urlStr = [[_openUrl absoluteString] stringByReplacingOccurrencesOfString:kSohuNewsUrlSchema withString:@""];
            
            //sohunewsiphone://pr/二代协议，主要供H5页面里调用，可确保从H5里打开新一级的H5浏览器
            if ([urlStr hasPrefix:@"pr/"]) {
                //sohunewsiphone://pr/news://termId=xxx&newsId=yy
                urlStr = [urlStr stringByReplacingOccurrencesOfString:@"pr/" withString:@""];
                
                // 为了加快闪屏速度，修改了loading页的加载时机和其他初始化的逻辑，于是产生了一个bug
                // 该bug会导致外在客户端没启动时，部调起客户端的二代协议失效。 这里打个补丁。推迟0.5秒，等待客户端初始化完毕再调用
                // add by Cae
                CGFloat delayTime = 0.5;
                if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
                    delayTime = 1.0;
                }
                
                urlStr = [self treatmentUrl:urlStr];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * delayTime), dispatch_get_main_queue(), ^() {
                    NSDictionary *userInfo = [SNUtility parseURLParam:urlStr schema:kProtocolNews];
                    [SNUtility shouldUseSpreadAnimation:NO];
                    if ([urlStr hasPrefix:kProtocolChannel]) {
                        [SNRollingNewsPublicManager sharedInstance].channelProtocolNewsID = [userInfo stringValueForKey:@"newsId" defaultValue:@""];
                    }
                    
                    _openUrlHandled = [SNUtility openProtocolUrl:urlStr context:@{kOpenAppOriginFromKey:[NSNumber numberWithInteger:SNOpenAppOriginFromUniversalLink]}];
                    _backWhere = nil;
                });
                
                SNCCPVPage page = [SNUtility parseLinkPage:urlStr];
                if (page == -1) {
                    _openUrlHandled = NO;
                } else {
                    //过滤http
                    BOOL hasHttp = [SNAPI isWebURL:urlStr];
                    if (page == sohu_http_web && !hasHttp) {
                        _openUrlHandled = NO;
                    } else {
                        _openUrlHandled = YES;
                    }
                }
                // 原来这里是返回_openUrlHandled = [SNUtility openProtocolUrl:urlStr];的，但是打了不定之后就变得无意义了。直接写死NO
                return _openUrlHandled;
            }
            //sohunewsiphone://news/${newsId} 早期的单独处理article的，已作废，有死循环bug
            else {
                NSArray *urlParams = [urlStr componentsSeparatedByString:@"/"];
                if ([urlParams count] > 1) {
                    NSString *openType = [urlParams objectAtIndex:0];
                    if ([openType compare:@"news" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                        NSString *newsId = [urlParams objectAtIndex:1];
                        NSMutableDictionary *query = [NSMutableDictionary dictionary];
                        [query setObject:newsId forKey:kNewsId];
                        [query setObject:@"1" forKey:kChannelId];
                        [query setObject:kNewsOnline forKey:kNewsMode];
                        
                        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://h5NewsWebView"] applyAnimated:YES] applyQuery:query];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[TTNavigator navigator] openURLAction:action];
                            _backWhere = nil;
                        });
                        return (_openUrlHandled = YES);
                    }
                }
            }
        }
    }
    return NO;
}

//监控流量
- (void)showASIBandWidthIfNeeded {
    if ([SNPreference sharedInstance].bandwidthEnabled) {
        if (!_bandwidthView) {
            _bandwidthView = [[SNBandwidthView alloc] initWithFrame:CGRectMake(260, 20, 60, 20)];
            [[UIApplication sharedApplication].keyWindow addSubview:_bandwidthView];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while(YES) {
                sleep(1);
                //过去5秒内的平均值
                NSInteger _bindwidthBytes = [ASIHTTPRequest averageBandwidthUsedPerSecond];
                CGFloat _bandwidth = _bindwidthBytes / 1024.0f;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_bandwidthView setText:[NSString stringWithFormat:@"%.1fK/S", _bandwidth]];
                });
            }
        });
    }
}

- (void)showNavigationController {
    UIViewController *controller = [[TTNavigator navigator] visibleViewController];
    controller.flipboardNavigationController.view.frame = _rectNavigation;
}

- (void)newUserGuideViewDidCloseNotification:(id)sender {
    // 就是给用户行为拦截和未来的统计增加个切入的机会 by jojo
}

//iOS8 model页面转屏后导致下层viewcontroller 转屏方式失效
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    //查看当前视图是否是千帆直播间，如果是则由千帆sdk决定旋转设置
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        SNTabBarController *rootTab = (SNTabBarController *)self.window.rootViewController;
        SNNavigationController *currentNavi = rootTab.selectedViewController;
        if (currentNavi.viewControllers.count > 0) {
            UIViewController *topVC = currentNavi.topSubcontroller;
            if ([NSStringFromClass([topVC class]) isEqualToString:@"SLLiveRoomViewController"]) {
                return [[SLNewsApplication sharedApplication] supportedInterfaceOrientations];
            }
        }
    }
    
    if ([[SHVideoForNewsSDK getKeyWindowTopViewContorller] isEqualToString:@"JKWSafariViewController"]) {
        return UIInterfaceOrientationMaskAll;
    }

    if ([SHVideoForNewsSDK isPlayerBeingShowedInFullScreen]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)handleShowSplashViewNotification:(NSNotification *)notify {
    if (LoadingSwitch) {
        id obj = notify.object;
        SNSplashViewRefer refer = SNSplashViewReferRollingNewsHorizontalSliding;
        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
            NSString * referString = [(NSDictionary *)obj stringValueForKey:@"refer" defaultValue:@""];
            if (referString.length > 0 && [referString isEqualToString:@"userCenter"]) {
                refer = SNSplashViewReferUserCenter;
            }
            else if (referString.length > 0 && [referString isEqualToString:@"slide"]) {
                refer = SNSplashViewReferRollingNewsHorizontalSliding;
            }
        }
        if (!_splashModel) {
            self.splashModel = [[SNSplashModel alloc] initWithRefer:refer delegate:self];
            [self.splashModel showSplashIsCountDown:NO];
        } else {
            _splashModel.splashRefer = refer;
            [self.splashModel showSplashIsCountDown:NO];
        }
    } else {
        id obj = notify.object;
        SNSplashViewRefer refer = SNSplashViewReferRollingNewsHorizontalSliding;
        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
            NSString * referString = [(NSDictionary *)obj stringValueForKey:@"refer" defaultValue:@""];
            if (referString.length > 0 && [referString isEqualToString:@"userCenter"]) {
                refer = SNSplashViewReferUserCenter;
            }
            else if (referString.length > 0 && [referString isEqualToString:@"slide"]) {
                refer = SNSplashViewReferRollingNewsHorizontalSliding;
            }
        }
        if (![[SNAlertStackManager sharedAlertStackManager] isShowing]) {
            if (!_splashViewController) {
                self.splashViewController = [[SNSplashViewController alloc] initWithRefer:refer delegate:self];
                [_navigator.window addSubview:_splashViewController.view];
            }
            if ([_splashViewController respondsToSelector:@selector(showSplashView)]) {
                _splashViewController.splashViewRefer = refer;
                [_splashViewController showSplashView];
            }
        }
    }
}

#pragma mark - Remote Notification
- (void)registerRemoteNotification {
    if (!SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    //iOS10 点击通知处理 5.7.2 by wangchuanwe
    if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        _notifacationCenter = center;
        _notifacationCenter.delegate = self;
        UNNotificationAction *shareAction = [UNNotificationAction actionWithIdentifier:kCustomPushShareIdentifier title:kCustomPushShareTitle options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *noInterestAction = [UNNotificationAction actionWithIdentifier:kCustomPushNoInterestIdentifier title:kCustomPushNoInterestTitle options:UNNotificationActionOptionDestructive];
        
        NSArray *actionArray = [NSArray arrayWithObjects:shareAction,noInterestAction, nil];
        UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:kCustomPushCategoryIdentifier actions:actionArray intentIdentifiers:@[kCustomPushShareIdentifier,kCustomPushNoInterestIdentifier] options:UNNotificationCategoryOptionNone];
        [_notifacationCenter setNotificationCategories:[NSSet setWithObjects:notificationCategory, nil]];
        
        [_notifacationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                }];
            }
        }];
    } else {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[self setCustomPushSetting]];
        } else {
            UIRemoteNotificationType types = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound| UIRemoteNotificationTypeAlert;
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
        }
    }
}

- (UIUserNotificationSettings *)setCustomPushSetting {
    UIMutableUserNotificationAction *shareAction = [[UIMutableUserNotificationAction alloc] init];
    shareAction.identifier = kCustomPushShareIdentifier;//按钮标识
    shareAction.title = kCustomPushShareTitle;//按钮标题
    shareAction.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
    shareAction.destructive = NO;//YES按钮为红色
    
    UIMutableUserNotificationAction *noInterestAction = [[UIMutableUserNotificationAction alloc] init];
    noInterestAction.identifier = kCustomPushNoInterestIdentifier;
    noInterestAction.title = kCustomPushNoInterestTitle;
    //当点击的时候不启动程序，在后台处理
    noInterestAction.activationMode = UIUserNotificationActivationModeBackground;
    noInterestAction.destructive = NO;
    
    //创建动作的类别集合
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = kCustomPushCategoryIdentifier;//这组动作的唯一标识
    [category setActions:@[shareAction, noInterestAction] forContext:(UIUserNotificationActionContextMinimal)];
    
    //创建UIUserNotificationSettings,并设置消息的显示类型
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:[NSSet setWithObjects:category, nil]];
    return settings;
}

//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
#pragma mark User Activity Continuation protocol adopted by UIApplication delegate
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    [[SNAppUsageStatManager sharedInstance] statAppLaunchingRefer:SNAppLaunchingRefer_Other];
    [[SNAppUsageStatManager sharedInstance] statAppResigning];
    NSDictionary *userInfo = [userActivity userInfo];
    _becomeAcitveByIcon = NO;
    if (userInfo) {
        //如果是通过Spotlight搜索打开文章页
        if ([userActivity.activityType isEqualToString:@"com.apple.corespotlightitem"]) {
            //埋点
            NSString *newID = [[userInfo[@"kCSSearchableItemActivityIdentifier"] componentsSeparatedByString:@"newsId="] lastObject];
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=spotlight&_tp=read&newsId=%@&channelId=", newID]];
            //打开文章
            [self handleOpenUrl:[NSURL URLWithString:userInfo[@"kCSSearchableItemActivityIdentifier"]]];
            _backWhere = nil;
            return YES;
        }
        
        if ([userInfo[snw_handoff_version] isEqualToString:snw_handoff_current_version]) {
            [[SNOpenWayManager sharedInstance] analysisAndPostURL:userInfo[snw_handoff_news_url] from:kAppleWatchTP openOrigin:kOther];
            // 只有热启动时 才在这处理二代协议
            if (_hotStart) {
                if ([[self appTabbarController].tabbarView currentSelectedIndex] == 1) {
                } else {
                    [self performSelector:@selector(pausePlayer) withObject:self afterDelay:0.1];
                    [SNUtility openProtocolUrl:userInfo[snw_handoff_news_url]];
                }
            } else {
                self.handoffNewUrl = userInfo[snw_handoff_news_url];
                // 发信号去
                dispatch_semaphore_signal(_handOff_dispatch_group);
            }
            _backWhere = nil;
            return YES;
        }
        //Universal Links
        if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
            [SNUtility sharedUtility].isOpenFromUniversalLinks = YES;
            [[SNOpenWayManager sharedInstance] analysisAndPostURL:userInfo[snw_handoff_news_url] from:kAppFromH5Tp openOrigin:kAppH5];
            NSURL *webpageURL = userActivity.webpageURL;
            NSString *host = webpageURL.host;
            if ([host isEqualToString:FixedHost_Applink]) {
                NSMutableString *url = [NSMutableString stringWithString:webpageURL.absoluteString];
                NSString *replaceStr = nil;
                if ([SNAPI isWebURL:url]) {
                    replaceStr = [NSString stringWithFormat:@"%@%@?url=",[SNAPI rootSchemeUrl:url], host];
                }
                
                if (url.length >= replaceStr.length + 1) {
                    NSRange range = {0, replaceStr.length + 1};
                    [url replaceCharactersInRange:range withString:@""];
                }
                else {
                    return NO;
                }
                
                if ([[url URLDecodedString] hasPrefix:kProtocolChannel]) {
                    UIViewController* topController = [TTNavigator navigator].topViewController;
                    [SNUtility popToTabViewController:topController];
                    [SNUtility openProtocolUrl:[url URLDecodedString] context:@{kOpenAppOriginFromKey:[NSNumber numberWithInteger:SNOpenAppOriginFromUniversalLink]}];
                } else {
                    if ([[url URLDecodedString] hasPrefix:kSchemeUrlSNS]) {
                        [SNNotificationManager postNotificationName:kAppBecomeActivityNotification object:nil];
                    }
                    
                    CGFloat delayTime = 0.5;
                    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
                        delayTime = 1.0;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * delayTime),dispatch_get_main_queue(), ^{
                        NSString *openUrl = [self treatmentUrl:[url URLDecodedString]];
                        //wangshun
                        [SNUtility openProtocolUrl:openUrl context:@{kOpenAppOriginFromKey:[NSNumber numberWithInteger:SNOpenAppOriginFromUniversalLink]}];
                        _backWhere = nil;
                    });
                }
                if ([[UIDevice currentDevice].systemVersion floatValue] > 9.0) {
                    [SNUtility banUniversalLinkOpenInSafari];
                }
            } else {
                [[UIApplication sharedApplication] openURL:webpageURL];
                _backWhere = nil;
            }
            
            return YES;
        }
    }
    return NO;
}
//#endif

- (void)setBackWhere {
    if ([self isUpdateNumTime:SNNews_Push_Back_FocusNews_ValidTime]) {
        _backWhere = SNNews_Push_Back_FocusNews;
    } else {
        _backWhere = SNNews_Push_Back_RecomNews;
    }
}

- (NSMutableDictionary *)treatmentUserInfo:(NSMutableDictionary *)userInfo {
    NSMutableDictionary *pushUserInfo = userInfo;
    if (![pushUserInfo objectForKey:SNNews_Push_Back_Key]) {
        if ([self isUpdateNumTime:SNNews_Push_Back_FocusNews_ValidTime]) {
            [pushUserInfo setObject:SNNews_Push_Back_FocusNews forKey:SNNews_Push_Back_Key];
            NSDate *date = [SNUtility getSettingValidTime:6];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:SNNews_Push_Back_FocusNews_ValidTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSTimeInterval deltaTime = [[NSDate date] timeIntervalSinceDate:self.leftDate];
            deltaTime = deltaTime * 1000;//换算成毫秒
            NSTimeInterval settingTime = [[SNAppConfigManager sharedInstance] reShowSplashADInterval];
            if (deltaTime > settingTime) {
                [pushUserInfo setObject:SNNews_Push_Back_RecomNews forKey:SNNews_Push_Back_Key];
            }
        }
    }
    return pushUserInfo;
}

- (NSString *)treatmentUrl:(NSString *)openUrl {
    NSString *openUrlStr = openUrl;
    if ([[openUrl lowercaseString] hasPrefix:kProtocolNews] ||
        [[openUrl lowercaseString] hasPrefix:kProtocolPhoto] ||
        [[openUrl lowercaseString] hasPrefix:kProtocolVote]) {
        if ([_backWhere isEqualToString:SNNews_Push_Back_RecomNews]) {
            openUrlStr = [openUrl stringByAppendingString:@"&backWhere=1"];
        } else if ([_backWhere isEqualToString:SNNews_Push_Back_FocusNews]) {
            openUrlStr = [openUrl stringByAppendingString:@"&backWhere=2"];
        } else {
            if ([self isUpdateNumTime:SNNews_Push_Back_FocusNews_ValidTime]) {
                openUrlStr = [openUrl stringByAppendingString:@"&backWhere=2"];
                NSDate *date = [SNUtility getSettingValidTime:6];
                [[NSUserDefaults standardUserDefaults] setObject:date forKey:SNNews_Push_Back_FocusNews_ValidTime];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                NSTimeInterval deltaTime = [[NSDate date] timeIntervalSinceDate:self.leftDate];
                deltaTime = deltaTime * 1000;//换算成毫秒
                NSTimeInterval settingTime = [[SNAppConfigManager sharedInstance] reShowSplashADInterval];
                if (deltaTime > settingTime) {
                    openUrlStr = [openUrl stringByAppendingString:@"&backWhere=1"];
                }
            }
        }
    }
    return openUrlStr;
}

#pragma mark Apple Watch
- (void)initAppGroupWithWatch {
    [self initSession];
}

- (void)initSession {
    if ([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
    }
}

/**
 *  WCSession Delegate
 *
 *  @param session      [WCSession defaultSession]
 *  @param message      watch 传过来的info
 *  @param replyHandler 需要App 返回给 watch 的reply
 */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    NSString *sessionType = message[@"sessionType"] ? : @"";
    if ([sessionType isEqualToString:@"sessionType_getAppInfo"]) {
        NSString *p1 = [SNUtility getP1];
        NSString *rootUrl = [SNPreference sharedInstance].testModeEnabled ? [SNPreference sharedInstance].basicAPIDomain : SNLinks_Domain_ProductDomain;
        rootUrl = [[SNAPI rootScheme] stringByAppendingString:rootUrl];
        
        NSDictionary *reply = @{@"p1" : p1,
                                @"rootUrl" : rootUrl};
        replyHandler(reply);
    } else {
        replyHandler(nil);
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    if (applicationContext[snw_host_userLog]) {
        // 做用户埋点
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:@"41" forKey:@"fun"];
        [params setValue:[NSString stringWithFormat:@"14%@",applicationContext[snw_host_logParams] ? : @""] forKey:@"page"];
        [params setValue:@"14" forKey:@"topage"];
        [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
        
        [SNUtility missingCheckReportWithUrl:[SNAPI aDotGifUrlWithParameters:[params toUrlString]]];
    }
}

- (void)setIsNetworkReachable:(BOOL)isNetworkReachable {
    if (isNetworkReachable != _isNetworkReachable) {
        _isNetworkReachable = isNetworkReachable;
        if (!isNetworkReachable) {
            [SNNotificationManager postNotificationName:kNetworkDidChangedNotify object:nil];
        }
    }
}

- (void)createShortcutItem {
    UIApplicationShortcutIcon *searchIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"icotouch_search_v5"];
    UIApplicationShortcutIcon *collectIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"icotouch_collect_v5"];
    
    UIMutableApplicationShortcutItem *searchItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.sohu.newspaper.search" localizedTitle:@"搜索" localizedSubtitle:nil icon:searchIcon userInfo:nil];
    UIMutableApplicationShortcutItem *collectItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.sohu.newspaper.collection" localizedTitle:@"收藏" localizedSubtitle:nil icon:collectIcon userInfo:nil];
    
    [UIApplication sharedApplication].shortcutItems = @[searchItem,collectItem];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    NSDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithBool:YES] forKey:kIs3DTouchOpen];
    
    [[SNOpenWayManager sharedInstance] analysisAndPostURL:nil
                                                     from:kOther
                                               openOrigin:kOther];
    
    //适配视频页 by cuiliangliang
    if ([[self appTabbarController].tabbarView currentSelectedIndex] == TABBAR_INDEX_VIDEO) {
        if (![self.navigator.topViewController isKindOfClass:[SVChannelsViewController class]]) {
            return;
        }
    }
    
    //不管在任何界面，都先popToRootViewController
    [self.navigator.topViewController.flipboardNavigationController popToRootViewControllerAnimated:NO];
    //tab切换到新闻
    [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    
    [SNNotificationManager postNotificationName:kChannelManagerViewCloseNotification object:nil];
    [SNNotificationManager postNotificationName:kOpenClientFrom3DTouchNotification object:nil];
    [SNNotificationManager postNotificationName:k3DTouchHomeKeyBoardClose object:nil];

    [SNUtility shouldUseSpreadAnimation:NO];
    
    if ([shortcutItem.type isEqualToString:@"com.sohu.newspaper.search"]) {
        //SNSearchWebViewController
        [SNNewsReport reportADotGif:@"_act=3d&_tp=search&channelId="];
        if (_isEnterForeground) {
            [dict setValue:[NSNumber numberWithBool:YES] forKey:@"isEnterForeground"];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://search"] applyAnimated:YES] applyQuery:dict];
            [[TTNavigator navigator] openURLAction:urlAction];
        });
    } else if ([shortcutItem.type isEqualToString:@"com.sohu.newspaper.collection"]) {   //SNMyCorpusViewController
        [SNNewsReport reportADotGif:@"_act=3d&_tp=favorite&channelId="];
        [SNNotificationManager postNotificationName:kCloseKeyboardNotification object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://homeCorpus"] applyAnimated:YES] applyQuery:dict];
            [[TTNavigator navigator] openURLAction:_urlAction];
        });
    }
}

#pragma mark - LogCenterDelegate
- (BOOL)isPlayingVideo {
    return [SHVideoForNewsSDK isPlayerBeingShowed];
}

#pragma mark - JKZipArchiveDelegate
- (BOOL)unzipFileAtPath:zipPath toDestination: unzipPath{
    return [Main unzipFileAtPath:zipPath toDestination:unzipPath];
}

#pragma mark shot screen 
- (void)setScreenShotImageView:(BOOL)show {
    //修改crash，下个版本删除，已基本不会出现黑屏
    return;
    //解决频繁切换前后台，闪一下黑屏问题
    if (show) {
        //第三方登录bug http://jira.sohuno.com/browse/NEWSCLIENT-18436 wangshun 2017.5.23
        UIViewController *vc = [TTNavigator navigator].topViewController;
        if ([NSStringFromClass([vc class]) isEqualToString:@"SNLoginRegisterViewController"]) {
            return;
        }

        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        //判断这个KeyWindow是否存在异常Frame的现象
        if (CGRectIsEmpty(keyWindow.bounds) ||
            CGRectIsNull(keyWindow.bounds)) {
            return;
        }
        
        CGSize size = keyWindow.bounds.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
        
        UIDevice *device = [UIDevice currentDevice];
        float sysVersion = [device.systemVersion floatValue];
        
        if (sysVersion < 9.0f) {
            //这个会出现SSO回来后卡死 iOS 7, iOS 8
            [keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
        } else {
            CGRect rec = CGRectMake(0, 0, size.width, size.height);
            //lijian 2017.11.23 这个方法在ios10的各系统版本中，内存吃紧时会增加崩溃几率(如正文页叠加过多时)。
            [keyWindow drawViewHierarchyInRect:rec afterScreenUpdates:NO];
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //如果出现多添加的情况，先删除一遍
        if (self.screenImageView) {
            [self.screenImageView removeFromSuperview];
            self.screenImageView = nil;
        }
        self.screenImageView = [[UIImageView alloc] initWithImage:image];
        
        [keyWindow addSubview:self.screenImageView];
        [keyWindow bringSubviewToFront:self.screenImageView];
    } else {
        if (self.screenImageView == nil) {
            return;
        }
        [UIView animateWithDuration:0.1 animations:^{
          self.screenImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.screenImageView removeFromSuperview];
            self.screenImageView = nil;
        }];
    }
}

#pragma mark - ScreenshotNotification
- (void)userDidTakeScreenshot:(NSNotification *)noti {
    [SNScreenshotRequest getScreenShotToFeedBack];
}

#pragma mark - ChangeAppTheme
- (BOOL)isSettingTime:(NSString *)state {
    NSDate *validDate = [[NSUserDefaults standardUserDefaults] objectForKey:state];
    if (validDate == nil) {
        return NO;
    }
    
    NSDate *nowDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
    NSComparisonResult result = [validDate compare:nowDate];
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isUpdateNumTime:(NSString *)state {
    NSDate *validDate = [[NSUserDefaults standardUserDefaults] objectForKey:state];
    if (validDate == nil) {
        return YES;
    }
    
    NSDate *nowDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
    NSComparisonResult result = [validDate compare:nowDate];
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

- (void)dealAppCurrentTheme {
    NSNumber *switche = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsThemeNightSwitch];
    BOOL switchValue = NO;
    if (switche == nil) {
        switchValue = YES; //默认开关打开
    } else {
        switchValue = [switche boolValue];
    }
    
    //第一次启动App时[[SNThemeManager sharedThemeManager] currentTheme]为空，所以改用此方法
    NSString *currentTheme = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeSelectedKey];
    BOOL isNightTheme = currentTheme && [currentTheme length] > 0 && [currentTheme isEqualToString:kThemeNight];
    
    //智能关闭夜间模式开关打开，且当前是夜间模式，进入app时间晚于早上7点，切换为日间模式
    if (switchValue && isNightTheme && [self isSettingTime:kNewsThemeNightValidTime]) {
        [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeDefault];
        JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        [jsKitStorage setItem:[NSNumber numberWithBool:NO]
                       forKey:@"settings_nightMode"];
        [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"0"];
        
        [DKNightVersionManager dawnComing];
        
        BOOL firstWarning = [[NSUserDefaults standardUserDefaults] boolForKey:@"NewsThemeNightSwithchFirst"];
        if (firstWarning == NO) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已为您智能切换日间模式" toUrl:nil mode:SNCenterToastModeOnlyText];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NewsThemeNightSwithchFirst"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else if (switchValue && isNightTheme) {
        //覆盖安装时，getUserSet.go不调用，无法设置ValidTime。在此处设置夜间模式关闭时间 wyy
        NSDate *validDate = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsThemeNightValidTime];
        if (validDate == nil) {
            NSDate *date = [SNUtility getSettingValidTime:7];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:kNewsThemeNightValidTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)clearPushBadgeNumbers {
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [SNUtility clearPushCount];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

@end
