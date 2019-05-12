//
//  SNAppConfigManager.h
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNAppConfigVideoAd;
@class SNAppConfigActivity;
@class SNAppConfigVoiceCloud;
@class SNPopupActivity;
@class SNAppConfigRequestMonitorConditions;
@class SNAppConfigSplashPreLoading;
@class SNAppConfigFestivalIcon;
@class SNAppConfigFloatingLayer;
@class SNMyLoadingConfig;
@class SNCameraConfig;
@class SNAppConfigTabBar;
@class SNAppConfigTimeControl;
@class SNAppConfigHttpsSwitch;
@class SNAppConfigScheme;
@class SNAppConfigH5RedPacket;
@class SNAppConfigMPLink;
@class SNAppConfig;

@interface SNAppConfigManager : NSObject


@property (nonatomic, strong) NSDictionary *activeTipsInfo;
@property (nonatomic, strong) SNAppConfig *config;

+ (instancetype)sharedInstance;

/**
 * 加载配置信息。反复调用此方法可刷新最新的配置信息到内存。
 */
- (void)requestConfigAsync;

/**
 * 加载配置信息。同步方法，专门为了新用户引导，卡住主线程，为了能在用户引导前获取到数据
 */
- (void)requestConfigSync;

/**
 *是否显示用户引导页，YES显示，NO不显示
 */
- (BOOL)isNewUserGuideShow;

/*
 *2015年过年图片是否显示控制开关
 */
- (BOOL)isShowNewsPullBgImage;

/*
 *loading页节日图标
 */

- (NSString *)festivalIconUrl;

/**
 *下拉刷新活动
 */

- (SNAppConfigActivity *)activity;

/**
 *  获取视频广告相关配置
 *
 *  @return 视频广告相关配置
 */
- (SNAppConfigVideoAd *)videoAdConfig;

/**
 *  获取灵犀语音sdk连接相关配置
 *
 *  @return 灵犀语音sdk配置结构
 */
- (SNAppConfigVoiceCloud *)voiceCloudConfig;

/**
 *应用模板是否开启更多操作
 */

- (BOOL)isAppInterestOpen;

/**
 *搜索界面搜狗搜索button是否显示
 */

- (BOOL)searchSogouButtonShow;

/**
 *本地频道切换提示
 */

- (BOOL)updateLocalChannelShow;

/**
 *下拉新闻提示
*/
- (NSString *)showPullNewsTips;

/**
 *是否显示下拉广告的开关
 */
- (BOOL)pullAdSwitchOpen;

/**
 *支付宝相关开关生活圈
 */
- (BOOL)isShowAliPayShareTimeline;

/**
 *支付宝相关开关支付宝好友
 */
- (BOOL)isShowAliPayShareSession;

/**
 *  弹窗活动
 *
 *  @return 弹窗活动
 */
- (SNPopupActivity *)popupActivity;

/**
 * 请求监测的丑样条件
 *
 * @return 请求监测的丑样条件
 */
- (SNAppConfigRequestMonitorConditions *)requestMonitorConditions;

/**
 * 请求loading页预加载图片时机参数
 *
 * @return loading页预加载图片时机参数
 */
- (SNAppConfigSplashPreLoading *)splashPreLoading;

/**
 * 请求push检测开关的周期，以天为单位
 *
 * @return 天
 */
- (NSString *)checkPushPeriod;

/**
 *  退入后台,后台启动客户端,超时调起loading页
 *
 *  @return 超时时间 单位：毫秒
 */
- (NSTimeInterval)reShowSplashADInterval;

- (SNAppConfigFloatingLayer *)floatingLayer;

/**
 *  loading页自定义开机图的开关
 */
- (BOOL)showEditMySplashButton;

/**
 *  相机服务端控制tab
 */
- (NSString *)cameraTabString;

/**
 *红包滑动解锁次数
 */

- (int)redPacketSlideNum;

/**
 *频道流视频自动播放开关
 */

- (BOOL)channelVieoSwitch;

- (SNMyLoadingConfig *)myLoadingConfig;

/**
 *tab bar 文案配置
 */
- (SNAppConfigTabBar *)configTabBar;

/**
 *  获取优惠券
 */
- (NSString *)getMytabCouponTicketUrl;

/**
 *频道流编辑流和推荐流重置时间
 */
- (SNAppConfigTimeControl *)configTimeControl;

/**
 *启用Https开关
 */
- (SNAppConfigHttpsSwitch *)configHttpsSwitch;

/**
 *活动scheme配置
 */
- (SNAppConfigScheme *)configScheme;

/**
 加载我的页面活动提醒信息
 */
- (void)requestActivityTipsInfo;

- (NSDictionary *)getActiveTipsInfo;

/**
 流内红包活动页面
 */
- (SNAppConfigH5RedPacket *)configH5RedPacket;

/**
 MP link 发现搜狐公众号
 */
- (SNAppConfigMPLink *)configMPLink;

@end
