//
//  SNSohuLoginViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuLoginViewModel.h"

#import "SNSohuLoginRequest.h"
#import "SNNewsLoginManager.h"

#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNNewsRecordLastLogin.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginThirdAnalyse.h"
#import "SNNewsPPLoginEnvironment.h"


@interface SNSohuLoginViewModel ()
{
    BOOL isLoading;
    NSString* sourceID;
    NSString* screen;
    NSString* entrance;
}
@property (nonatomic,strong) NSDictionary* bindpreData;//绑定前已经拿到userInfo;
@property (nonatomic,strong) void (^successed_Method)(NSDictionary* resultDic);

@end

@implementation SNSohuLoginViewModel

- (void)sohuLogin:(NSDictionary *)params WithSuccessed:(void (^)(NSDictionary *))method{
    NSString* sohuaccount = [params objectForKey:@"sohuaccount"];
    NSString* password    = [params objectForKey:@"password"];
    
    sourceID = [params objectForKey:@"loginFrom"];
    entrance = [params objectForKey:@"entrance"];
    screen   = [params objectForKey:@"screen"];
    
    if (sohuaccount.length>0) {
        if (password.length>0) {
            [self souLoginRequest:params WithSuccessed:method];
            return;
        }
        else{
             [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入正确的用户名和密码" toUrl:nil mode:SNCenterToastModeError];
        }
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入正确的用户名和密码" toUrl:nil mode:SNCenterToastModeError];
    }
    
    NSDictionary* re_dic = @{@"success":@"0"};
    if (method) {
        method(re_dic);
    }
}

- (void)souLoginRequest:(NSDictionary*)params WithSuccessed:(void (^)(NSDictionary *))method{
    
    if (isLoading == YES) {
        return;
    }
    isLoading = YES;
    
    if (method) {
        self.successed_Method = method;
    }
    
    NSString* sohuaccount = [params objectForKey:@"sohuaccount"];
    NSString* password    = [[params objectForKey:@"password"] md5Hash];
    
    NSDictionary* dic = @{@"account":sohuaccount,@"password":password};

    sourceID = [params objectForKey:@"loginFrom"];
    
    if([SNNewsPPLoginEnvironment isPPLogin]){
        NSString* captcha     = [params objectForKey:@"captcha"];
        if (captcha) {
            dic = @{@"account":sohuaccount,@"password":password,@"captcha":captcha?:@""};
        }
        [SNNewsPPLogin sohuLogin:dic WithResult:^(NSDictionary *info) {
            [self analysePPLoginParams:dic Response:info];
        }];

        return;
    }
    
    [[[SNSohuLoginRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"resp:%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        
        [self analyseStatusCode:statusCode response:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        SNDebugLog(@"error:%@",error);
        isLoading = NO;
        
        NSDictionary* re_dic = @{@"success":@"0"};
        if (method) {
            method(re_dic);
        }
    }];
    
}

- (void)analyseStatusCode:(NSNumber*)statusCode response:(NSDictionary*)respDic{
    
    if (statusCode.integerValue == 10000000) {//成功
        
        NSNumber* bindMobileStatus = [respDic objectForKey:@"bindMobileStatus"];
        NSDictionary* userInfo = [respDic objectForKey:@"userInfo"];
        if (userInfo && bindMobileStatus == nil) {
            bindMobileStatus = [userInfo objectForKey:@"bindMobileStatus"];
        }
        
        if (bindMobileStatus.integerValue == 0) {//未绑定
            
            NSMutableDictionary* param = [NSMutableDictionary dictionary];
            [param setObject:@"bind" forKey:@"type"];
            NSString* passport = [userInfo objectForKey:@"passport"];
            if (passport) {
                [param setObject:passport?:@"" forKey:@"passport"];
            }
            
            [self openBindViewController:param];//去绑定
            
            self.bindpreData = respDic;
            
        }
        else{
            [self loginSuccessed:nil WithUserInfo:respDic];//登录成功
        }
        return;
    }
    else if (statusCode.integerValue == 10000020){//账户不存在
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"账户不存在" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000021){//登录密码错误
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录密码错误" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000022){//登录密码未设置
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录密码未设置" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000004){//登录失败
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录失败" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    
    isLoading = NO;//成功不允许再次点击登录 举报页弹好几个...
    
    [self burySuccess:@"-1"];
    
    NSDictionary* re_dic = @{@"success":@"0"};
    if (self.successed_Method) {
        self.successed_Method(re_dic);
    }
}

- (void)analysePPLoginParams:(NSDictionary*)params Response:(NSDictionary*)info{
    
    [SNNewsPPLoginThirdAnalyse sohuPPLoginParams:params Response:info Successed:^(NSDictionary *resultDic) {
        
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                
                [self ppLoginSuccessed:resultDic];
                return;
            }
            else if ([success isEqualToString:@"40323"]){
                isLoading = NO;
                
                NSMutableDictionary* pp_mDic = [NSMutableDictionary dictionaryWithDictionary:params];
                [pp_mDic setObject:@"bind" forKey:@"type"];
                [self openBindViewController:pp_mDic];
                return;
            }
            else{
                [self burySuccess:@"-1"];
                
                isLoading = NO;
                if (self.successed_Method) {
                    NSDictionary* re_dic = @{@"success":success};
                    self.successed_Method(re_dic);
                }
                return;
            }
        }
        
        [self burySuccess:@"-1"];
        isLoading = NO;
        if (self.successed_Method) {
            NSDictionary* re_dic = @{@"success":@"0"};
            self.successed_Method(re_dic);
        }
    }];
}

- (void)ppLoginSuccessed:(NSDictionary *)dic{
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"sohu",@"value":@"1"}];
    [self burySuccess:@"1"];
    
    [self performSelector:@selector(loginSuccessLater) withObject:nil afterDelay:1.0];
}

-(void)loginSuccessed:(NSDictionary*)responseObject WithUserInfo:(NSDictionary*)userInfo_{
    //搜狐登录成功
    SNDebugLog(@"%@",responseObject);
    
    if (userInfo_ == nil) {//只限于搜狐登录(邮箱密码)登录后需要进入绑定页面的
        userInfo_ = self.bindpreData;
    }
    
    NSDictionary* userInfoDic = [userInfo_ objectForKey:@"userInfo"];
    if (userInfoDic == nil) {
        return;
    }
    
    NSString *userID = [userInfoDic objectForKey:@"passport"];//passport 就是userID
    NSString *token  = [userInfoDic objectForKey:@"token"];
    NSString *pid    = [userInfoDic objectForKey:@"pid"];
    NSString *nick   = [userInfoDic objectForKey:@"nick"];
    
    SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
    userInfo.userName = userID;
    userInfo.pid = [NSString stringWithFormat:@"%@", pid];
    userInfo.token = token;
    userInfo.nickName = nick;
    
    //wangshun
    [userInfo parseUserinfoFromDictionary:userInfoDic];
    [userInfo saveUserinfoToUserDefault];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:kUserCenterLoginAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"sohu",@"value":@"1"}];
    
    [self burySuccess:@"1"];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录成功" toUrl:nil mode:SNCenterToastModeOnlyText];
    
    [self performSelector:@selector(loginSuccessLater) withObject:nil afterDelay:1.0];
}

- (void)loginSuccessLater{
    if (self.successed_Method) {
        NSDictionary* re_dic = @{@"success":@"1"};
        self.successed_Method(re_dic);
    }
}

-(void)openBindViewController:(NSDictionary *)dic{
    isLoading = NO;
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"data",self,@"third",@"1",@"sohulogin",entrance?:@"",@"entrance",sourceID,@"loginFrom",@"sohu",@"local_plat",screen,@"screen",nil];
    [SNNewsLoginManager bindData:query Successed:nil Failed:nil];
}

- (void)burySuccess:(NSString*)type{
    
    if ([type isEqualToString:@"1"]) {
        NSString* agif = @"_act=login&s=sns_sohu";
        if(entrance){
            agif = [agif stringByAppendingFormat:@"&entrance=%@",entrance];
        }
        [SNNewsReport reportADotGif:agif];
    }
    
    if (!sourceID || sourceID.length == 0) {
        return;
    }
    
    //埋点 wangshun login
    NSDictionary* dic = @{@"loginSuccess":type,@"loginType":@"sohu",@"cid":[SNUserManager getP1],@"screen":screen};
    if ([type isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":type,@"loginType":@"sohu",@"errType":@"0",@"cid":[SNUserManager getP1],@"screen":screen};
    }
    SNDebugLog(@"狐友 sourceChannelID ::::%@ dic:%@",sourceID,dic);
    if (sourceID && ![sourceID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceID bodyDic:dic];
    }
    

}


@end
