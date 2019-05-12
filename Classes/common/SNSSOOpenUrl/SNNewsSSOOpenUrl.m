//
//  SNNewsSSOOpenUrl.m
//  sohunews
//
//  Created by wang shun on 2017/4/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsSSOOpenUrl.h"

#import "SNShareWeibo.h" //weiboshare

#import "SNWeiboLogin.h"
#import "SNWeiXinLogin.h"
#import "SNQQLogin.h"
#import "SNNewsScreenWeiXin.h"

@interface SNNewsSSOOpenUrl ()

@property (nonatomic, strong) SNShareWeibo *shareWeibo;
@property (nonatomic, strong) SNWeiboLogin *loginWeibo;
@property (nonatomic, strong) SNWeiXinLogin*loginWeixin;
@property (nonatomic, strong) SNQQLogin* loginQQ;
@property (nonatomic, strong) SNNewsScreenWeiXin* screen_weixin;//截屏分享
@end

@implementation SNNewsSSOOpenUrl

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if (sourceApplication && [sourceApplication compare:@"com.sina.weibo"] == NSOrderedSame) {
        return [WeiboSDK handleOpenURL:url delegate:[SNNewsSSOOpenUrl sharedInstance]];
        
    } else if ([WXApi handleOpenURL:url delegate:[SNNewsSSOOpenUrl sharedInstance]]) {
        return YES;
        
    } else if ([SNQQHelper handleOpenURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    }
    
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Weibo delegate

/**
 收到一个来自微博客户端程序的请求
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

/**
 收到一个来自微博客户端程序的响应
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    if (self.isLogin) {//登录回调
        [self.loginWeibo didReceiveWeiboResponse:response];
        self.isLogin = NO;
    }
    else{//分享回调
        [self.shareWeibo didReceiveWeiboResponse:response];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - WeiXin delegate

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 */
- (void)onReq:(BaseReq*)req{
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 */
- (void)onResp:(BaseResp*)resp{
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {//登录
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.code) {
            if (self.screen_weixin) {
                [self.screen_weixin setWeiXinURLWithCode:authResp.code];
                return;
            }
            [self.loginWeixin setURLWithCode:authResp.code];
        }
    }
    else{//分享
       [[SNWXHelper sharedInstance] onResp:resp];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (SNNewsSSOOpenUrl *)sharedInstance {
    static SNNewsSSOOpenUrl *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNNewsSSOOpenUrl alloc] init];
    });
    
    return _instance;
}

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setWeiboShare:(SNShareWeibo*)sender{
    if ([sender isKindOfClass:[SNShareWeibo class]]) {
        self.shareWeibo = nil;
        if (self.shareWeibo != sender) {
            self.shareWeibo = sender;
            self.isLogin = NO;
        }
    }
}
- (void)setWeiboLogin:(SNWeiboLogin*)sender{
    if ([sender isKindOfClass:[SNWeiboLogin class]]) {
        self.loginWeibo = nil;
        if (self.loginWeibo != sender) {
            self.loginWeibo = sender;
        }
        
    }
}

- (void)setWeiXinLogin:(SNWeiXinLogin*)sender{
    if ([sender isKindOfClass:[SNWeiXinLogin class]]) {
        self.loginWeixin = nil;
        if (self.loginWeixin != sender) {
            self.loginWeixin = sender;
            self.screen_weixin = nil;
        }
    }
}

- (void)setQQLogin:(SNQQLogin*)sender{
    if ([sender isKindOfClass:[SNQQLogin class]]) {
        self.loginQQ = nil;
        if (self.loginQQ != sender) {
            self.loginQQ = sender;
        }
    }
}

- (void)setScreenShare_WeiXinDel:(SNNewsScreenWeiXin*)sender{
    if ([sender isKindOfClass:[SNNewsScreenWeiXin class]]) {
        self.screen_weixin = nil;
        if (self.screen_weixin != sender) {
            self.screen_weixin = sender;
        }
    }
}



@end
