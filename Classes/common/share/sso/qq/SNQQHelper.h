//
//  SNQQHelper.h
//  sohunews
//
//  Created by wang yanchen on 13-5-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "SNWXHelper.h"

#define kQQAppId                (@"QQ05FA0C99") // to replace
#define kTencentAppId           (@"100273305")

@protocol SNQQHelperLoginDelegate <NSObject>
@optional
- (void)shareToThirdPartSuccess:(BOOL)isShareToQZone;
- (void)qqDidFailLoginWithError:(NSError *)error;
- (void)qqDidLogin;
@end

@interface SNQQHelper : NSObject

@property (nonatomic, strong) TencentOAuth *tencentAuth;
@property (nonatomic, weak) id<SNQQHelperLoginDelegate> loginDelegate;
@property (nonatomic, strong) NSMutableDictionary *loginUserInfoDic;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL isShareToQZone; // default NO, to QQ
@property (nonatomic, strong) NSString *shareUrl;

+ (SNQQHelper *)sharedInstance;

+ (void)initQQApi;
+ (BOOL)isQQApiReady;

// 是否支持QQ SSO 登陆
+ (BOOL)isSupportQQSSO;

+ (BOOL)handleOpenURL:(NSURL *)url;
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation;

// sso login
- (void)loginForQQWithDelegate:(id<SNQQHelperLoginDelegate>)delegate;
// web login
- (void)loginForQQWebWithDelegate:(id<SNQQHelperLoginDelegate>)delegate;

#pragma mark -
// 分享

- (void)shareTextToQQ:(NSString *)text;

//gif图
- (void)shareGifToQQ:(NSString *)gifUrl imageTitle:(NSString *)title description:(NSString *)description ;

// image最大10m -- qq api文档没有限制，保险起见  限制大小
- (void)shareImageToQQ:(NSData *)imageData imageTitle:(NSString *)title description:(NSString *)description;

// image最大32k -- qq api文档没有限制，保险起见  限制大小
- (void)shareNewsToQQ:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData webUrl:(NSString *)url;

// 增加一个 媒体分享的接口
- (void)shareMediaToQQ:(NSString *)content title:(NSString *)title thumbImage:(NSData *)imageData mediaUrl:(NSString *)mediaUrl mediaType:(QQApiURLTargetType)mediaType;

@end

