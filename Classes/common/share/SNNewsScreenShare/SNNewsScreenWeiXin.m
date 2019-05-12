//
//  SNNewsScreenWeiXin.m
//  sohunews
//
//  Created by wang shun on 2017/8/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenWeiXin.h"

#import "SNWXHelper.h"

#import "SNWeixinOauthRequest.h"
#import "SNShareWeiXin.h"

#import "SNNewsScreenShareUserInfoRequest.h"
#import "SNNewsScreenShareWXAuthRequest.h"
#import "SNNewsScreenShare.h"
#import "SNNewsSSOOpenUrl.h"

@interface SNNewsScreenWeiXin ()<SNWXHelpDelegate>

@property (nonatomic,strong) NSDictionary* weixin_userInfo;
@property (nonatomic,strong) NSDictionary* huyou_userInfo;

@property (nonatomic,copy) void (^weixinAuthCallBack)(NSDictionary*info);

@end

@implementation SNNewsScreenWeiXin

-(instancetype)init{
    if (self = [super init]) {
        self.isWeiXinAuth = @"0";
    }
    return self;
}

- (BOOL)isShowWeixin{
    if (self.weixin_userInfo) {
        return YES;
    }
    return NO;

}

- (BOOL)isShowSohu{
    if (self.huyou_userInfo) {
        return YES;
    }
    return NO;
    
}

- (void)analyseData:(NSDictionary*)responseObject{
    NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
    if (statusCode.integerValue == 200) {
        NSDictionary* data = [responseObject objectForKey:@"data"];
        NSDictionary* userInfos = [data objectForKey:@"userInfos"];
        
        self.weixin_userInfo = [userInfos objectForKey:@"weixin"];
        self.huyou_userInfo   = [userInfos objectForKey:@"huyou"];
        
        self.tips = [data objectForKey:@"tips"]?:@"";
        
        NSString* link2_ = [data objectForKey:@"link2"];
        NSString* backImg = [data objectForKey:@"background"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateLink2:Background:)]) {
            UIImage* img = nil;
            if (link2_ && link2_.length>0) {
                self.link2 = link2_;
                img = [SNNewsScreenShare createQRcodeImage:self.link2];
            }
            [self.delegate updateLink2:img Background:backImg];
        }
        
        //微信是否授权
        if (self.weixin_userInfo) {
            NSNumber* status = [self.weixin_userInfo objectForKey:@"status"];
            if (status.integerValue == 1) {
                self.isWeiXinAuth = @"1";
                
                NSString* avator = [self.weixin_userInfo objectForKey:@"avator"];
                NSString* nick   = [self.weixin_userInfo objectForKey:@"nickName"];
                NSString* openid = [self.weixin_userInfo objectForKey:@"openid"];
                
                self.weixin_nickName = nick;
                self.weixin_headImage_Url = avator;
                self.openID = openid;
            }
            else if (status.integerValue == 2){//过期
                self.isWeiXinAuth = @"2";
            }
            else{
                self.isWeiXinAuth = @"0";
            }
        }
        else{
            self.isWeiXinAuth = @"0";
        }
        
        if (self.huyou_userInfo) {
            NSString* avator = [self.huyou_userInfo objectForKey:@"avator"];
            NSString* nick   = [self.huyou_userInfo objectForKey:@"nickName"];
            
            self.huyou_nickName = nick;
            self.huyou_headImage_Url = avator;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(getAuthUserInfo:)]) {
            [self.delegate getAuthUserInfo:nil];
        }
        
        if([self.isWeiXinAuth isEqualToString:@"1"]){
            if (self.weixinAuthCallBack) {
                self.weixinAuthCallBack(nil);
                self.weixinAuthCallBack = nil;
            }
        }
        self.weixinAuthCallBack = nil;
    }
    else{
        
    }
}

-(void)setWeiXinURLWithCode:(NSString *)code{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:code forKey:@"code"];
    
    if (isINHOUSE) {//等重构吧 inhouse 和 appstore 不是一个bundleid passport不想兼容俩
        [WXApi registerApp:kWX_APP_ID_Inhouse enableMTA:NO];
    }
    
    [[[SNWeixinOauthRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id requestDict) {
        NSString *access_token = [requestDict objectForKey:@"access_token"];
        NSString *refresh_token = [requestDict objectForKey:@"refresh_token"];
        NSString *openid = [requestDict objectForKey:@"openid"];
        
        self.openID = openid;
        self.access_Token = access_token;
        self.refresh_Token = refresh_token;
        
        [self getWXInfo];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }];
    
    [[SNNewsSSOOpenUrl sharedInstance] setScreenShare_WeiXinDel:nil];
}

- (void)getWXInfo{
    
    [[[SNNewsScreenShareWXAuthRequest alloc] initWithDictionary:@{@"openid":self.openID?:@"",@"accessToken":self.access_Token?:@""}] send:^(SNBaseRequest *request, id responseObject) {
        
        NSDictionary* data = [responseObject objectForKey:@"data"];
        
        if (responseObject && data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [self analyseData:responseObject];
                } @catch (NSException *exception) {
                    SNDebugLog(@"SNNewsScreenShareWXAuthRequest exception reason--%@", exception.reason);
                } @finally {
                
                }
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(weixinAuthFailed)]) {
                    [self.delegate weixinAuthFailed];
                    
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"获取微信头像昵称失败" toUrl:nil mode:SNCenterToastModeError];
                }
            });
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(weixinAuthFailed)]) {
                [self.delegate weixinAuthFailed];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"获取微信头像昵称失败" toUrl:nil mode:SNCenterToastModeError];
            }
        });
    }];
}

-(void)didload:(NSDictionary *)dic{
    NSString* gid = [dic objectForKey:@"gid"];
    NSString* newsid = [dic objectForKey:@"newsId"];
    if (gid && gid.length>0) {
        newsid = @"-1";
    }
    else{
        gid = @"-1";
    }
    
    NSDictionary* param = @{@"newsId":newsid?:@"-1",@"gid":gid?:@"-1"};
    
    
    [[[SNNewsScreenShareUserInfoRequest alloc] initWithDictionary:param] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject) {
            [self analyseData:responseObject];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }];
}

- (void)weiXinAuth:(void (^)(NSDictionary*))method{
    
    if (method) {
        self.weixinAuthCallBack = method;
    }
    
    [[SNNewsSSOOpenUrl sharedInstance] setScreenShare_WeiXinDel:self];
    if (isINHOUSE) {
        [WXApi registerApp:kWX_APP_ID enableMTA:NO];
    }
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";//必须
    req.state = @"111111";//不必须
    [WXApi sendReq:req];
}


- (BOOL)isInstallWeiXin{
    
    if (![SNShareWeiXin isInstalledWeiXin]) {
        NSString* toastTitle = NSLocalizedString(@"Weixin not installed", @"");
        [[SNCenterToast shareInstance] showCenterToastWithTitle:toastTitle toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    
    return YES;
}


- (BOOL)isCanShare:(NSString*)iconTitle{
    if ([iconTitle isEqualToString:kShareTitleWechatSession] || [iconTitle isEqualToString:SNNewsShare_Icons_WeChat] || [iconTitle isEqualToString:kShareTitleWechat] || [iconTitle isEqualToString:SNNewsShare_Icons_Timeline]) {//微信
        BOOL b = [self isInstallWeiXin];
        if (b == NO) {//未安装微信
            return NO;
        }
        else{
            if (self.isCheckBoxSelected == YES) {//已勾选
                if ([self.isWeiXinAuth isEqualToString:@"1"]) {//已授权
                    //
                    if (self.delegate && [self.delegate respondsToSelector:@selector(weixinShareCallBack:)]) {
                        [self.delegate weixinShareCallBack:iconTitle];
                    }
                    return YES;
                }
                else{//未授权已勾选 分享
                    //自动分享
                    __weak SNNewsScreenWeiXin* weakSelf = self;
                    [self weiXinAuth:^(NSDictionary *info) {
                        
                        [weakSelf continueShare:iconTitle];
                    }];
                    return NO;
                }
            }
            else{//安装微信 未勾选 直接分享
                if (self.delegate && [self.delegate respondsToSelector:@selector(shareLater:)]) {
                    [self.delegate shareLater:iconTitle];
                }
                return YES;
            }
        }
    }
    else if([iconTitle isEqualToString:kShareTitleMySohu] || [iconTitle isEqualToString:SNNewsShare_Icons_Sohu]){//狐友
        //
        if (self.isCheckBoxSelected == YES) {
            if (self.huyou_userInfo) {//有数据刷头像
                if (self.delegate && [self.delegate respondsToSelector:@selector(sohuShareCallBack:)]) {
                    [self.delegate sohuShareCallBack:nil];
                    return NO;
                }
            }
        }

        if (self.delegate && [self.delegate respondsToSelector:@selector(shareLater:)]) {
            [self.delegate shareLater:kShareTitleMySohu];
        }
        return YES;
    }
    
    return YES;
}

- (void)continueShare:(NSString*)title{
    if (self.delegate && [self.delegate respondsToSelector:@selector(weixinShareCallBack:)]) {
        [self.delegate weixinShareCallBack:title];
    }
    //[self performSelector:@selector(shareLater:) withObject:title afterDelay:1.5];
}

//延时一下 为了先把头像刷了 url
//- (void)shareLater:(NSString*) title{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(share:)]) {
//        [self.delegate share:title];
//    }
//}


@end
