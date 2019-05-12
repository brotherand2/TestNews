//
//  SNSSOAdapter.h
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSSOWrapper.h"
#import "SinaWeibo.h"
//#import "WBApi.h"

// sina weibo app id 1
// qq weibo app id 2
// qzone app id 6

@interface SNSSOAdapter : NSObject {
    SNSSOWrapper *_ssoClient;
}

@property(nonatomic, strong)SNSSOWrapper *ssoClient;

+ (SNSSOAdapter *)shareAdapter;

/**
 * appId对应的账号是否支持sso
 */
- (BOOL)isSupportForAppId:(NSString *)appId;

/**
 * start sso
 */
- (void)loginForAppId:(NSString *)appId;

/*
 * 接收 app delegate 回调：
 
 - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url; 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
 
 * 如果当前的sso成功接收url 返回YES；否则返回NO；
 */
+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 * 接收 app delegate 回调：
 
 - (void)applicationDidBecomeActive:(UIApplication *)application;
 
 * 没多少重要的用处，新浪微博的sdk需要支持一下；
 */
+ (void)handleApplicationDidBecomeActive;

@end
