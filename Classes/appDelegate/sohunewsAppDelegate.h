//
//  sohunewsAppDelegate.h
//  sohunews
//
//  Created by zhu kuanxi on 5/16/11.
//  Copyright 2011 sohu. All rights reserved.
//

#import "Three20.h"
#import "SNGuideMaskController.h"
#import "SNRollingNewsCheckLatest.h"
#import "SNTabBarController.h"
#import "SNSplashViewController.h"
#import "SNStopWatch.h"
#import "SNLineraQueue.h"
#import <StoreKit/StoreKit.h>
#import "SNBandwidthView.h"
#import "SNSplashModel.h"

extern CFAbsoluteTime StartTime;

@class FMDatabase;
@class Reachability;
@class SNSubCenterMainViewController;

@interface sohunewsAppDelegate : NSObject <UIApplicationDelegate, SNGuideMaskControllerDelegate, UIAlertViewDelegate> {
@private
    FMDatabase *_database;
	__weak TTNavigator *_navigator;
    
	UIWindow *_window;
	
	SNRollingNewsCheckLatest *_rollingNewsCheck;
    NSTimer *_rollingNewsCheckTimer;
    
    SNLineraQueue *_pushNotificationQueue;
    
    //本地通知
    UILocalNotification *_localNotif;
    //记录本地通知是否已显示过，解决同一条通知连续显示两次的问题
    NSMutableDictionary *_localNotifInfo;

    UILabel *_memory;
    
    BOOL _isColdLaunch;
    BOOL _hadReceiveRemoteNotificationAfterAppKilledOrInstallFirstly;
    BOOL _didColdStart;
    BOOL _openUrlHandled;
    BOOL _hotStart;//标识是否是热启动
    BOOL _isEnterForeground;//标记3DTouch是后台调起，还是启动客户端
    BOOL _becomeAcitveByIcon;//仅记录从后台激活，和hotstart配合使用
    
    NSURL *_openUrl;
    SNBandwidthView *_bandwidthView;
    NSString *_backWhere;  //记录端外启动正文返回方式
}

// 启动次数
@property (nonatomic) NSInteger startCount;

@property (nonatomic, strong) UIWindow *window;
@property (weak, nonatomic, readonly) TTNavigator *navigator;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, assign) BOOL isNetworkReachable;
@property (nonatomic, assign) BOOL needRefreshPhotoTags;
@property (nonatomic, strong) NSTimer *loopTimer;
@property (nonatomic, strong) SNLineraQueue *pushNotificationQueue;
@property (nonatomic, strong) NSMutableDictionary *localNotifInfo;
@property (nonatomic, strong) SNSplashViewController *splashViewController;
@property (nonatomic, strong) NSDictionary *receiveLocalDict;
@property (nonatomic, strong) NSString *receivePushURL;
@property (nonatomic, strong) NSDate * leftDate;

@property (nonatomic, strong) SNSplashModel *splashModel;

- (Reachability *)getInternetReachability;
- (BOOL)isWWANNetworkReachable;
- (BOOL)isCurrentNetworkReachable;
- (NetworkStatus)currentNetworkStatus;
- (NSString *)currentNetworkStatusString;

- (BOOL)isGuideViewShow;
- (BOOL)shouldDownloadImagesManually;
- (BOOL)canOpenInnerAppStoreWithAppId:(NSString *)appId;
- (SNTabBarController *)appTabbarController;

/**
 SNRollingNewsViewController -viewDidAppear
 */
- (void)mainViewDidAppear;

/**
 初始化H5 懒加载
 */
- (void)initH5Framework;

// 保存图片Delegate方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void)newUserGuideViewDidCloseNotification:(id)sender;
@end
