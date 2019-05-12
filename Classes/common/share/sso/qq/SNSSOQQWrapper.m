//
//  SNSSOQQWrapper.m
//  sohunews
//
//  Created by jojo on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSSOQQWrapper.h"

#import "SNLoginLaterBingPhone.h"
#import "SNNewsThirdLoginEnable.h"
#import "SNSLib.h"
#import "SNUserManager.h"
#import "SNNewsRecordLastLogin.h"

@interface SNSSOQQWrapper ()<SNLoginLaterBingPhoneDelegate>

@property (nonatomic,strong) SNLoginLaterBingPhone* bingPhone;
@property (nonatomic,strong) NSDictionary* resp_qq;

@end

@implementation SNSSOQQWrapper

- (void)login {
    [[SNQQHelper sharedInstance] loginForQQWithDelegate:self];
}

- (BOOL)handleOpenUrl:(NSURL *)url {
    return [SNQQHelper handleOpenURL:url];
}

- (void)dealloc {
    [SNQQHelper sharedInstance].loginDelegate = nil;
}

#pragma mark - SNQQHelperLoginDelegate

/** user info json dic
 {
 figureurl = "";
 "figureurl_1" = "";
 "figureurl_2" = "";
 "figureurl_qq_1" = "";
 "figureurl_qq_2" = "";
 gender = "";
 "is_lost" = 0;
 "is_yellow_vip" = 0;
 "is_yellow_year_vip" = 0;
 level = 0;
 msg = "";
 nickname = "jojo ";
 ret = 0;
 vip = 0;
 "yellow_vip_level" = 0;
 }
 */

- (void)qqDidLogin {

    [SNNewsThirdLoginEnable sharedInstance].isLanding = YES;
    
    [[SNCenterToast shareInstance] showWithTitle:@"正在登录.."];
    
    self.userName = [[SNQQHelper sharedInstance].loginUserInfoDic stringValueForKey:@"nickname" defaultValue:nil];
    self.userId = [SNQQHelper sharedInstance].tencentAuth.openId;
    self.accessToken = [SNQQHelper sharedInstance].tencentAuth.accessToken;
    self.expirationDate = [SNQQHelper sharedInstance].tencentAuth.expirationDate;
    
    NSString* expire = [NSString stringWithFormat:@"%zd",(long long)[self.expirationDate timeIntervalSince1970]];
    
    //[self syncTokenLoginInfo:response];
    //wangshun
    //原来直接同步信息
    //现在加入绑定流程 wangshun 2017.3.6
    
    if (self.bingPhone != nil) {
        self.bingPhone = nil;
    }
    
    NSDictionary* params = @{@"openId":self.userId,@"token":self.accessToken,@"expire":expire,@"appId":@"qq",@"from":@"login"};
    
    self.bingPhone = [[SNLoginLaterBingPhone alloc] initWithDelegate:self];
    [self.bingPhone bindThirdPartyLogin:params];
    
}

- (void)qqDidFailLoginWithError:(NSError *)error {
    
    self.lastErrorMessage = [error localizedDescription];
    self.lastError = error;
    
    if ([_delegate respondsToSelector:@selector(ssoDidFailLogin:)]) {
        [_delegate ssoDidFailLogin:self];
    }
}

- (void)syncTokenLoginInfo:(NSDictionary *)response{
    
    self.userName = [[SNQQHelper sharedInstance].loginUserInfoDic stringValueForKey:@"nickname" defaultValue:nil];
    self.userId = [SNQQHelper sharedInstance].tencentAuth.openId;
    self.accessToken = [SNQQHelper sharedInstance].tencentAuth.accessToken;
    self.expirationDate = [SNQQHelper sharedInstance].tencentAuth.expirationDate;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if (self.userName) {
        [userInfo setObject:self.userName forKey:@"nick"];
    }
    
    NSString *gender = [[SNQQHelper sharedInstance].loginUserInfoDic stringValueForKey:@"gender" defaultValue:nil];
    if (gender) {
        if ([gender isEqualToString:@"男"]) {
            gender = @"1";
        }
        else if ([gender isEqualToString:@"女"]) {
            gender = @"2";
        }
        [userInfo setObject:gender forKey:@"gender"];
    }
    
    NSString *headUrl = [[SNQQHelper sharedInstance].loginUserInfoDic stringValueForKey:@"figureurl_qq_2" defaultValue:nil];
    if (headUrl) {
        [userInfo setObject:headUrl forKey:@"headUrl"];
    }
    
    //5.2 add
    if (self.accessToken) {
        [userInfo setObject:self.accessToken forKey:@"accessToken"];
    }
    
    [[SNShareManager defaultManager] qqSyncTokenWithAppId:@"6" openId:self.userId userInfo:userInfo];
}


////////////////////////////////////////////////////////////////////////////////////

#pragma mark - sns 埋点

- (void)burySuccess:(NSString*)sender{
    NSString* loginType = @"qq";
    NSString* sourceChannelID = [SNShareManager defaultManager].loginFrom;
    NSDictionary* dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"cid":[SNUserManager getP1]};
    if ([sender isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"errType":@"0",@"cid":[SNUserManager getP1]};
    }
    
    SNDebugLog(@"第三方 sourceChannelID ::::%@ dic:%@",sourceChannelID,dic);
    
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}

#pragma mark - SNLoginLaterBingPhoneDelegate

- (void)loginSuccessed:(NSDictionary*)data{
//    [self syncTokenLoginInfo:self.resp_qq];
    [[SNCenterToast shareInstance] hideToast];
    [[SNCenterToast shareInstance] showWithTitle:@"登录成功"];
    
    [self burySuccess:@"1"];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    
    if (data == nil) {
        data = self.userInfoDic;
    }
    
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"6";//微博
    [self.thirdLoginSuccess loginSuccessed:data WithThirdData:self.resp_qq];
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"qq",@"value":@"1"}];
}

- (void)openBingPhoneViewControllerData:(NSDictionary*)dic{
    [[SNCenterToast shareInstance] hideToast];
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    self.userInfoDic = userinfo;
    [[SNCenterToast shareInstance] hideToast];
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

////////////////////////////////////////////////////////////////////////////////////

@end
