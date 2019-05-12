//
//  SNAppConfigService.m
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppConfigService.h"
#import "SNAppConfigConst.h"
#import "SNPopupActivity.h"
#import "SNConfigSettingRequest.h"
#import "SNClientRegister.h"
#import "SNPopupActivityCenter.h"
#import "SNRedPacketManager.h"
#import "SNRollingNewsTableController.h"
#import "SNRollingNewsViewController.h"
#import "SNAdvertiseManager.h"

@implementation SNAppConfigService

#pragma mark - Public- Request JSON
- (void)requestConfigAsync {
    [[[SNConfigSettingRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
                if (!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
                    NSError *error = [[NSError alloc] initWithDomain:[self errorDomain] code:SNAppConfigServiceErrorCode_EmptyResponseString userInfo:nil];
                    [self dispatchToDelegateWithError:error];
                } else {
                    NSString *configString = [responseObject translateDictionaryToJsonString];
                    SNAppConfig *config = [self parseConfigFromString:configString];
                    [self dispatchToDelegateWithConfig:config];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showRedPacketGuideView];
                        [SNNotificationManager postNotificationName:kFullscreenThemeDidFetchedkNotification object:nil];
                    });
                    
                    sohunewsAppDelegate *appDelegate = [SNUtility getApplicationDelegate];
                    [[appDelegate appTabbarController].tabbarView updateTabButtonTitle];
                    
                    if ([SNUserDefaults boolForKey:kNewUserGuideHadEndShown]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[SNPopupActivityCenter defaultCenter] popupActivityIfNeeded];
                        });
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SNUtility showBackThirdAppView];
                    });
                }
            } @catch (NSException *exception) {
                SNDebugLog(@"SNConfigSettingRequest exception reason--%@", exception.reason);
            } @finally {
            }
        });
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self dispatchToDelegateWithError:error];
    }];
}

- (void)requestConfigSync {
//    // 使用信号量来实现同步请求
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); // 创建信号量
//    __block NSString *configString = nil;
//    __block NSError *error;
//    
//    [[[SNConfigSettingRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
//        if (responseObject) {
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                configString = [responseObject translateDictionaryToJsonString];
//            } else {// 返回异常为 NSData 2017.3.10 liteng
//                configString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            }
//        }
//        dispatch_semaphore_signal(semaphore);   // 发送信号
//    } failure:^(SNBaseRequest *request, NSError *error) {
//        error = error;
//        dispatch_semaphore_signal(semaphore);   // 发送信号
//    }];
//    
//    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  // 等待
//    
//    if (configString.length == 0) {
//        //如果没有返回数据, 直接结束
//        return;
//    }
//    
//    if (error) {
//        SNDebugLog(@"Error ocurred with:%d,%@ in %@", error.code, error.localizedDescription, NSStringFromSelector(_cmd));
//        return;
//    }
//    NSData *configFileData = [configString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *configFilePath = [self configFilePath];
//    BOOL rst = [configFileData writeToFile:configFilePath atomically:YES];
//    
//    if (rst) {
//        @synchronized (self) {
//            SNAppConfig *config = [self parseConfigFromString:configString];
//            [self dispatchToDelegateWithConfig:config];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showRedPacketGuideView];
//            });
//        }
//    }
}


- (NSString *)errorDomain {
    return SNLinks_Domain_ProductDomain;
}

#pragma mark - Private - About delegate
- (void)dispatchToDelegateWithError:(NSError *)error {
    if (!([NSThread currentThread].isMainThread)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchToDelegateWithError:error];
        });
        return;
    }
}

- (SNAppConfig *)parseConfigFromString:(NSString *)configString {
    SNAppConfig *config = [[SNAppConfigManager sharedInstance] config];
    id configData = [NSJSONSerialization JSONObjectWithString:configString options:NSJSONReadingMutableContainers error:NULL];
    
    //默认的配置信息数据
    if (configString.length <= 0 ||
        !configData ||
        ![configData isKindOfClass:[NSDictionary class]]) {
        config.isGuideInterestShow = NO;
        config.activityType = @"";
        config.appInterestOpen = NO;
        config.sogouButtonShow = NO;
        config.redoRegisterClient = NO;
        config.pullAdSwitch = NO;
        config.reshowSplashInterval = MAXFLOAT;
        config.redPacketSlideNum = 5;
        config.channelVideoSwitch = YES;
        config.ppLoginOpen = @"0";//
    }
    //来自服务器或存在本地的json文件的配置信息数据
    else {
        NSDictionary *configDic       = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)configData];
        config.isGuideInterestShow    = [configDic[keyIsGuideInterestShow] isEqualToString:@"1"] ? YES : NO;
        config.appInterestOpen        = [configDic[keyAppInterestShow] isEqualToString:@"1"] ? YES : NO;
        config.sogouButtonShow        = [configDic[kSougouButtonShow] isEqualToString:@"1"] ? YES : NO;
        config.newsPullBgImage        = [configDic[kNewsPullBgImage] isEqualToString:@"1"] ? YES : NO;
        config.pullAdSwitch           = [configDic[kPullAdSwitch] isEqualToString:@"1"]? YES : NO;
        config.localChannelUpdateShow = [configDic[kLocalChannelUpdateOn] isEqualToString:@"1"] ? YES : NO;
        config.pullNewsTips           = [configDic stringValueForKey:kPullNewsTips defaultValue:nil];
        config.checkPushPeriod        = [configDic stringValueForKey:kCheckPushPeriod defaultValue:nil];
        config.reshowSplashInterval   = [[configDic stringValueForKey:kReshowSplashInterval defaultValue:[NSString stringWithFormat:@"%f",MAXFLOAT]] doubleValue];
        config.shareAlipayOption      =  configDic[kShareAlipayOption];
        config.redPacketSwitch        = [configDic[kRedpackSwitch] isEqualToString:@"0"] ? YES : NO;
        config.loadingMySplashSwitch  = [configDic[kLoadingMySplashSwitch] isEqualToString:@"0"]? YES : NO;
        
        //新版登录开关 wangshun 2017.11.13
        config.ppLoginOpen  = [[configDic stringValueForKey:@"smc.client.login.useNew" defaultValue:@"0"] isEqualToString:@"1"]?@"1":@"0";
       
        //loading页节日图标
        [config.festivalIcon updateWithDic:configDic];
        
        ///渠道/非标广告位
        [[SNAdvertiseManager sharedManager] updateChannelADs:configDic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SNRedPacketManager postRedPacketNotificationName:config.redPacketSwitch];
            if (LoadingSwitch) {
                SNSplashModel *splashModel = [(sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate] splashModel];
                [splashModel updateSettingsWithConfig:config];
            } else {
                SNSplashViewController * splashViewController = [(sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate] splashViewController];
                [splashViewController updateSettingsWithConfig:config];
            }
        });
        
        [SNRedPacketManager setRedPacketTips:[configDic stringValueForKey:kPullNewsRedPacketTips defaultValue:nil]];
        config.redPacketSlideNum = [configDic intValueForKey:kRedPacketSlideNum defaultValue:5];

        NSDictionary *channelVideoDict = [configDic objectForKey:kChannelVideoConfig];
        config.channelVideoSwitch = [[channelVideoDict stringValueForKey:@"autoPlay" defaultValue:@""] integerValue];
        NSString *loadingTimeOut = [configDic stringValueForKey:kClientLoadingTimeOut defaultValue:@"6"];
        [SNUserDefaults setObject:loadingTimeOut forKey:kLoadingTimeOut];
        
        [SNUserDefaults setObject:[configDic stringValueForKey:kLoadingSCSwitch defaultValue:@"0"] forKey:kLoadingSCSDKSwitch];

        [SNUserDefaults setBool:config.channelVideoSwitch forKey:kChannelVideoSwitchKey];
        
        [SNUserDefaults setBool:[[configDic stringValueForKey:kCompassSDKSwitch defaultValue:@"0"] boolValue] forKey:kCompassSDKSwitchKey];

        config.mytabCouponTicketUrl = [configDic stringValueForKey:kMytabCouponTicketUrl defaultValue:nil];
        //扫一扫相关
        [config.cameraConfig updateWithDic:configDic];
        
        //视频广告相关
        [config.videoAdConfig updateWithDic:configDic];
        
        //灵犀语音sdk下载
        [config.voiceCloud updateWithDic:configDic];
        
        //下拉刷新活动
        config.activityType = [configDic stringValueForKey:keyActivityOn
                                              defaultValue:nil];
        
        //弹窗活动相关控制数据
        [config.popupActivity updateWithDic:configDic];
        
        //强制注册客户端
        BOOL redoRegisterClient = [configDic[kRedoRegisterClient] isEqualToString:@"1"] ? YES : NO;
        config.redoRegisterClient = redoRegisterClient;
        
        //网络请求监控抽样条件
        [config.requestMonitorConditions updateWithDic:configDic];
        
        //浮层控制
        [config.floatingLayer updateWithDic:configDic];
        
        //tab bar 文案配置
        [config.appConfigTabbar updateWithDict:configDic];
        
        //频道流重置刷新时间
        [config.appConfigTimeControl updateWithDict:configDic];
        
        //https 开关
        [config.appConfigHttpsSwitch updateWithDict:configDic];
        
        //活动scheme配置
        [config.appConfigScheme updateWithDict:configDic];
        
        //流内红包
        [config.appconfigH5RedPacket updateWithDict:configDic];
        
        //MP Link
        [config.appConfigMPLink updateWithDict:configDic];
        
        //abtest app样式风格
        NSString *defaltStyle = [NSString stringWithFormat:@"%d", [SNUtility getCurrentAbTestStlye:YES]];
        NSString *style = [configDic stringValueForKey:kABTestAppStlye
                                          defaultValue:defaltStyle];
        [SNUtility changeABTestAppStyle:[style intValue]];
        
        [config.appNewsSettingConfig updateWithDic:configDic];
    }
    return config;
}

- (void)dispatchToDelegateWithConfig:(SNAppConfig *)config {
    if ([self.delegate respondsToSelector:@selector(didSucceedToRequestConfig:)]) {
        [self.delegate didSucceedToRequestConfig:config];
    }
}

#pragma mark - Private - About config file path
- (void)showRedPacketGuideView {
    //显示红包引导活动页面
    if ([[TTNavigator navigator].rootViewController isKindOfClass:[SNTabBarController class]]) {
        SNTabBarController *tabBarVc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
        if ([[tabBarVc.viewControllers objectAtIndex:0] isKindOfClass:[SNNavigationController class]]) {
            SNNavigationController *naviVc = ((SNNavigationController *)[tabBarVc.viewControllers objectAtIndex:0]);
            if ([naviVc.currentViewController isKindOfClass:[SNRollingNewsViewController class]]) {
                SNRollingNewsViewController *vc = (SNRollingNewsViewController *)(((SNNavigationController *)[tabBarVc.viewControllers objectAtIndex:0]).currentViewController);
                if ([vc isHomePage]) {
                    [[SNPopupActivityCenter defaultCenter] popupRedPacketActivityIfNeeded];
                }
            }
        }
    }
}

- (void)dealloc {
    if (self.delegate) {
        self.delegate = nil;
    }
}

@end
