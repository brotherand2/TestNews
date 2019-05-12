//
//  SNShareWeibo.h
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSharePlatformBase.h"
#import "WeiboSDK.h"

@interface SNShareWeibo : SNSharePlatformBase<WeiboSDKDelegate>

@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbRefreshToken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

- (void)shareToWeibo:(NSDictionary*)dic;

+ (BOOL)isWeiboAppInstalled;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

@end
