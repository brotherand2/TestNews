//
//  SNAppConfig.h
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNCameraConfig.h"
#import "SNAppConfigVideoAd.h"
#import "SNAppConfigActivity.h"
#import "SNPopupActivity.h"
#import "SNAppConfigVoiceCloud.h"
#import "SNAppConfigRequestMonitorConditions.h"
#import "SNAppConfigFestivalIcon.h"
#import "SNAppConfigFloatingLayer.h"
#import "SNAppConfigTabBar.h"
#import "SNAppConfigTimeControl.h"
#import "SNAppConfigHttpsSwitch.h"
#import "SNAppConfigScheme.h"
#import "SNAppConfigH5RedPacket.h"
#import "SNAppConfigMPLink.h"
#import "SNNewsSettingConfig.h"
#import "SNNewsFullscreenManager.h"

@interface SNAppConfig : NSObject

@property (nonatomic, assign) BOOL isGuideInterestShow;

//视频广告相关配置
@property (nonatomic, strong) SNAppConfigVideoAd *videoAdConfig;

// 下拉刷新活动
@property (nonatomic, copy) NSString *activityType; //开启活动的类型
@property (nonatomic, strong) SNAppConfigActivity *activity;

@property (nonatomic, assign) BOOL appInterestOpen;

//弹窗活动
@property (nonatomic, strong) SNPopupActivity *popupActivity;

//听新闻推广位
@property (nonatomic, strong) SNAppConfigVoiceCloud *voiceCloud;

//搜索界面显示搜狗搜索Button
@property (nonatomic, assign) BOOL sogouButtonShow;

//是否需要强制注册客户端
@property (nonatomic, assign) BOOL redoRegisterClient;

//网络请求监控的丑样条件
@property (nonatomic, strong) SNAppConfigRequestMonitorConditions *requestMonitorConditions;

//loading页图片预加载参数
@property (nonatomic, strong) SNAppConfigSplashPreLoading *splashPreloading;

// 新闻列表的下拉背景图
@property (nonatomic, assign) BOOL newsPullBgImage;

// Loading页节日图标
@property (nonatomic, strong) SNAppConfigFestivalIcon * festivalIcon;

// 下拉提示显示
@property (nonatomic, strong) NSString *pullNewsTips;

//下拉广告开关
@property (nonatomic, assign) BOOL pullAdSwitch;

//本地频道切换提示
@property (nonatomic, assign) BOOL localChannelUpdateShow;

//支付宝相关开关 0,0  1表示关闭,0表示不关闭  第一位表示生活圈 ，第二位表示支付宝好友
@property (nonatomic, copy) NSString* shareAlipayOption;

//检测push开关周期
@property (nonatomic, strong) NSString *checkPushPeriod;

//后台超时调起loading页 超时时间  （毫秒）
@property (nonatomic, assign) NSTimeInterval reshowSplashInterval;

//浮层控制
@property (nonatomic, strong) SNAppConfigFloatingLayer *floatingLayer;

//红包活动开关 0,0  1表示关闭,0表示不关闭
@property (nonatomic, assign) BOOL redPacketSwitch;

//制作我的loading页开关，1标示关闭，0表示不关闭 "smc.client.loading.usercustom.switch"
@property (nonatomic, assign) BOOL loadingMySplashSwitch;

//红包解锁次数
@property (nonatomic, assign) int redPacketSlideNum;

//流内视频播放开关
@property (nonatomic, assign) BOOL channelVideoSwitch;

//扫一扫相机配置
@property (nonatomic, strong) SNCameraConfig *cameraConfig;
@property (nonatomic, strong) SNAppConfigTabBar *appConfigTabbar;
@property (nonatomic, strong) SNAppConfigTimeControl *appConfigTimeControl;
@property (nonatomic, strong) SNAppConfigHttpsSwitch *appConfigHttpsSwitch;
@property (nonatomic, strong) SNAppConfigScheme *appConfigScheme;
@property (nonatomic, copy) NSString *mytabCouponTicketUrl;
@property (nonatomic, strong) SNAppConfigH5RedPacket *appconfigH5RedPacket;
@property (nonatomic, strong) SNAppConfigMPLink *appConfigMPLink;
@property (nonatomic, strong) SNNewsSettingConfig *appNewsSettingConfig;


@property (nonatomic, strong) NSString* ppLoginOpen;//新版登录 开关 wangshun 2017.11.13

@end
