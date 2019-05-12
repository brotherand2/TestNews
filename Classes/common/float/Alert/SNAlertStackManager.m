//
//  SNAlertStackManager.m
//  sohunews
//
//  Created by TengLi on 2017/6/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNAlertStackManager.h"
#import "SNBaseAlertView.h"
#import "SNRollingNewsViewController.h"
#import "SNSplashViewController.h"
#import "SNQRUtility.h"
#import "SNSSOSinaWrapper.h"
#import "SNSpecialActivityAlert.h"
#import "SNCommonNewsController.h"
#import "SHH5NewsWebViewController.h"
#import "SNSLib.h"

#define kChannelFront @"1" // 首页流
#define kChannelRecommend @"13557" // 推荐流

@interface SNAlertStackManager ()

/**
   用于存所有下发的弹窗及数据
 */
@property (nonatomic, readwrite, strong) NSMutableArray <SNBaseAlertView *> *alertViewQueue;

/**
   用于记录当前正在弹出的弹窗
 */
@property (nonatomic, readwrite, strong) SNBaseAlertView *currentShowingAlert;

@end

@implementation SNAlertStackManager

static SNAlertStackManager *_sharedInstance;
+ (SNAlertStackManager *)sharedAlertStackManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNAlertStackManager alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alertViewQueue = [NSMutableArray array];
    }
    return self;
}

/**
 将弹窗加入队列

 @param alert 弹窗
 */
- (void)addAlertViewToAlertStack:(SNBaseAlertView *)alert {
    @synchronized (self.alertViewQueue) {
        
        if (self.alertViewQueue.count <= 0) { // 当前队列为空
            
            [self.alertViewQueue addObject:alert];
            
        } else if (![self checkIsAlreadyInStack:alert]) { // 不为空 && 当前队列中不存在将要加入队列的弹窗类型
            
            SNAlertViewType currentAlertType = alert.alertViewType;
            __block NSInteger insertIndex = 0;
            
            /// 反向遍历,按照枚举(弹窗类型)顺序获取到当前弹窗要插入的正确位置
            [self.alertViewQueue enumerateObjectsWithOptions:NSEnumerationReverse
                                                  usingBlock:^(SNBaseAlertView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SNAlertViewType alertType = obj.alertViewType;
                if (currentAlertType >= alertType) {
                    insertIndex = idx + 1;
                    *stop = YES;
                } else {
                    return;
                }
            }];
            
            [self.alertViewQueue insertObject:alert atIndex:insertIndex]; // 按照产品规定的优先级加入弹窗队列
        }
    }
    
    [self checkoutInStackAlertView];
}

/**
 检查当前队列中是否存在将要加入队列的弹窗类型(push除外)

 @param alert 将要加入队列的弹窗
 @return  YES,代表已经存在; NO,代表不存在
 */
- (BOOL)checkIsAlreadyInStack:(SNBaseAlertView *)alert {
    
    __block BOOL  instack = NO;
    __block NSInteger index = 0;
    SNAlertViewType currentAlertType = alert.alertViewType;
    
    if (currentAlertType != SNAlertViewPushType) {

        [self.alertViewQueue enumerateObjectsWithOptions:NSEnumerationReverse
                                              usingBlock:^(SNBaseAlertView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SNAlertViewType alertType = obj.alertViewType;
            if (currentAlertType == alertType) {
                //===========对广告弹窗做单独判断:同一种广告弹窗不重复添加===========//
                if (currentAlertType == SNAlertViewSpecialActivityType) {
                    SNSpecialActivityAlert *currentSpAlert = (SNSpecialActivityAlert *)alert;
                    SNSpecialActivityAlert *spAlert = (SNSpecialActivityAlert *)obj;
                    if (currentSpAlert.adType == spAlert.adType) {
                        instack = YES;
                        index = idx;
                        *stop = YES;
                    }
                //===========对广告弹窗做单独判断:同一种广告弹窗不重复添加===========//
                } else {
                    instack = YES;
                    index = idx;
                    *stop = YES;
                }
            }
        }];
    }
    if (instack) { // 如果当前队列里有同类型的弹窗,就替换为最新的(push除外)
        if (self.currentShowingAlert && self.currentShowingAlert.alertViewType == currentAlertType) {
            if (self.currentShowingAlert.alertViewType == SNAlertViewPasteBoardType) {
                return NO;
            } else {
                return instack;
            }
        }
        
        [self.alertViewQueue replaceObjectAtIndex:index withObject:alert];
    }
    return instack;
}

/**
 弹窗消失后将刚消失的弹窗从队列中清除
 */
- (BOOL)removeAlertViewFromAlertStack:(SNBaseAlertView *)dismissAlert {
    
    @synchronized (self.alertViewQueue) {
        if (self.currentShowingAlert && dismissAlert.alertViewType == self.currentShowingAlert.alertViewType) {
            [self.alertViewQueue removeObject:self.currentShowingAlert];
            self.currentShowingAlert = nil;
            return YES;
        }
        return NO;
    }
}

/**
 检查是否有符合条件的弹窗
 
 @return 返回YES,表示当前栈里有弹窗弹出;返回NO,表示队列里没有符合条件的弹窗
 */
- (BOOL)checkoutInStackAlertView {
    
    /// 如果当前app处于后台就不触发相关弹窗.
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) return NO;
    
    __block BOOL result = NO;
    if (!self.isShowing && self.alertViewQueue.count > 0) {
        
        UIViewController *topVc = [TTNavigator navigator].topViewController; // 当前的控制器
        NSString *currentChannelId = [SNUtility getCurrentChannelId]; // 当前的频道id
        NSInteger tabBarIndex = [[SNUtility getApplicationDelegate] appTabbarController].tabbarView.currentSelectedIndex; // 当前所在tab
        SNSplashViewController *splashViewController = [SNUtility getApplicationDelegate].splashViewController; // loading页是否存在
        SNSplashModel *splashModel = [SNUtility getApplicationDelegate].splashModel;
        __weak typeof(self)weakself = self;
        [self.alertViewQueue enumerateObjectsUsingBlock:^(SNBaseAlertView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SNAlertViewType alertType = obj.alertViewType;
            switch (alertType) {
                case SNAlertViewPasteBoardType:
                    if (tabBarIndex == TABBAR_INDEX_NEWS && ([currentChannelId isEqualToString:kChannelFront] || [currentChannelId isEqualToString:kChannelRecommend]) && [topVc isKindOfClass:[SNRollingNewsViewController class]] && (LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible)) { // 首页或推荐流
                        
                        SNRollingNewsViewController *rollingVc = (SNRollingNewsViewController *)topVc;
                        [rollingVc hideChannelManageView];
                        weakself.currentShowingAlert = obj;
                        [obj showAlertView];
                        result = YES;
                        *stop = YES;
                    } else {
                        return;
                    }
                    break;
                    
                case SNAlertViewFontSettingType:
                case SNAlertViewCloudSynType:
                    if (1 == currentChannelId.integerValue && [topVc isKindOfClass:[SNRollingNewsViewController class]] && (LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible)) { // 要闻流
                        
                        SNRollingNewsViewController *rollingVc = (SNRollingNewsViewController  *)topVc;
                        [rollingVc hideChannelManageView];
                        weakself.currentShowingAlert = obj;
                        [obj showAlertView];
                        result = YES;
                        *stop = YES;
                    } else {
                        return;
                    }
                    break;
                    
                case SNAlertViewUpgradeType:
                case SNAlertViewNomalActivityType:
                case SNAlertViewPushGuideType:
                    if (tabBarIndex == TABBAR_INDEX_NEWS && [topVc isKindOfClass:[SNRollingNewsViewController class]] && (LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible)) { // 频道流
                        
                        SNRollingNewsViewController *rollingVc = (SNRollingNewsViewController  *)topVc;
                        [rollingVc hideChannelManageView];
                        weakself.currentShowingAlert = obj;
                        [obj showAlertView];
                        result = YES;
                        *stop = YES;
                    } else {
                        return;
                    }
                    break;
                    
                case SNAlertViewSpecialActivityType:
                {
                    SNSpecialActivityAlert * spAlert = (SNSpecialActivityAlert *)obj;
                    switch (spAlert.adType) {
                        case SNFloatingADTypeHomePage:
                        {
                            if (tabBarIndex == TABBAR_INDEX_NEWS && 1 == currentChannelId.integerValue && [topVc isKindOfClass:[SNRollingNewsViewController class]] && (LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible)) {//首页要闻
                                weakself.currentShowingAlert = obj;
                                [spAlert showAlertView];
                                result = YES;
                                *stop = YES;
                            } else {
                                return;
                            }
                        }
                            break;
                        case SNFloatingADTypeChannels:
                        {
                            if (tabBarIndex == TABBAR_INDEX_NEWS && [topVc isKindOfClass:[SNRollingNewsViewController class]] && (LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible)) {//频道流
                                weakself.currentShowingAlert = obj;
                                [spAlert showAlertView];
                                result = YES;
                                *stop = YES;
                            } else {
                                return;
                            }
                        }
                            break;
                        case SNFloatingADTypeNewsDetail:
                        {
                            if ([topVc isKindOfClass:[SNCommonNewsController class]] || [topVc isKindOfClass:[SHH5NewsWebViewController class]]) {//正文页
                                weakself.currentShowingAlert = obj;
                                [spAlert showAlertView];
                                result = YES;
                                *stop = YES;
                            } else {
                                return;
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case SNAlertViewPushType:
                    ///  端内/不是视频tab/不存在loading页/不是视频全屏状态/不是appstore界面/视频播放界面/正在执行二维码扫描/微博web登录页面
                    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && tabBarIndex != TABBAR_INDEX_VIDEO && (LoadingSwitch ? !splashModel.isSplashVisible : !splashViewController.isSplashViewVisible) && ![topVc isKindOfClass:[SKStoreProductViewController class]] && ![SNUserDefaults boolForKey:kAticleVideoIsFullScreenKey] && ![topVc isKindOfClass:NSClassFromString(@"VideoDetailViewController")] && ![[SNQRUtility sharedInstanced] isScanning] && ![SNSSOSinaWrapper sharedInstance].isSinaWebOpen && [SNSLib isPushViewShouldOpenInSNSView]) {
                        weakself.currentShowingAlert = obj;
                        [obj showAlertView];
                        result = YES;
                        *stop = YES;
                    } else {
                        return;
                    }
                    break;
                default:
                    break;
            }
        }];
        
    }
    return result;
}


@end
