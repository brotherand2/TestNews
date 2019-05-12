//
//  SNMySDK.h
//  sohunews
//
//  Created by Cae on 14-12-14.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSLib.h"
#import "SNShareManager.h"
#import "SNCitySelectorController.h"
#import "SNChannel.h"

@interface SNMySDK : NSObject<SNSProtocol, SNShareManagerDelegate, SNCitySelectorControllerDelegate>

+ (SNMySDK *)sharedInstance;

// 这么写真恶心，但是没办法。登录流程太复杂了，暂时理不顺.
@property (nonatomic, copy) NSString *openId;

- (void)showMySDK:(UIViewController *)parentController;
- (void)updateAppTheme;
- (void)logout;
- (void)updateLocation:(SNChannel *)channel;
- (void)bindAccount:(NSString *)appId openId:(NSString *)openId;
- (void)unbindAccount:(NSString *)appId;
- (void)bindPhone:(NSString *)phone;
- (void)clickTabLastSelsct:(int)lastIndex andClickSelext:(int)index;
- (SNNavigationController *)getNav;
- (void)setupSNS;
- (void)updateSinaWeiBo:(NSString *)openId
                  token:(NSString *)token
             expireTime:(NSDate *)time;

//返回 登录接口所需appid和appkey  passport接口 wangshun 2017.11.17
//http://wiki.sohu-inc.com/display/PAS/Passport-v4
- (NSDictionary*)getPassportParams:(id)sender;

//后台统计
- (void)addLog:(NSString *)string;
//更新位置
- (void)reLocation;
//重新设置universal links
- (void)resetOpenInSafariView;

/**
 更新sns的session，tabbar切换时更新（包含点击切换及二代协议切换）
 目前是切到新闻tab及狐友tab时更新
 */
- (void)updateSnsSessionWithTabbarSelectedIndex:(NSUInteger)selectedIndex;

/**
 获取CTTelephonyNetworkInfo信息，生命周期内只允许创建一次
 */
- (CTTelephonyNetworkInfo *)creatTelephonyNetworkInfo;

@end
