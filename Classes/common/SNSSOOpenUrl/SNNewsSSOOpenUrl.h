//
//  SNNewsSSOOpenUrl.h
//  sohunews
//
//  Created by wang shun on 2017/4/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "SNQQHelper.h"
#import "WXApi.h"
#import "WXApiObject.h"

@class SNShareWeibo;
@class SNWeiboLogin;
@class SNWeiXinLogin;
@class SNQQLogin;
@class SNNewsScreenWeiXin;
@interface SNNewsSSOOpenUrl : NSObject<WeiboSDKDelegate,WXApiDelegate>

@property (nonatomic, assign) BOOL isLogin;

- (void)setWeiboShare:(SNShareWeibo*)sender;

- (void)setWeiboLogin:(SNWeiboLogin*)sender;
- (void)setWeiXinLogin:(SNWeiXinLogin*)sender;
- (void)setQQLogin:(SNQQLogin*)sender;
- (void)setScreenShare_WeiXinDel:(SNNewsScreenWeiXin*)sender;

+ (SNNewsSSOOpenUrl *)sharedInstance;

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
