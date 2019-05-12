//
//  SNSohuLoginViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuLoginViewModel.h"

#import "SNSohuLoginRequest.h"
#import "SNLoginLaterBingPhone.h"
#import "SNNewsLoginManager.h"

@interface SNSohuLoginViewModel ()
{
    BOOL isLoading;
}
@property (nonatomic,strong) NSDictionary* bindpreData;//绑定前已经拿到userInfo;
@property (nonatomic,strong) void (^successed_Method)(NSDictionary* resultDic);

@end

@implementation SNSohuLoginViewModel

- (void)sohuLogin:(NSDictionary *)params WithSuccessed:(void (^)(NSDictionary *))method{
    NSString* sohuaccount = [params objectForKey:@"sohuaccount"];
    NSString* password    = [params objectForKey:@"password"];
    
    if (sohuaccount.length>0) {
        if (password.length>0) {
            [self souLoginRequest:params WithSuccessed:method];
            return;
        }
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

    
    [[[SNSohuLoginRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"resp:%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        
        [self analyseStatusCode:statusCode response:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"error:%@",error);
        isLoading = NO;
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
            [self loginSuccessed:respDic];//登录成功
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
}

-(void)loginSuccessed:(NSDictionary*)responseObject{
    //搜狐登录成功
    SNDebugLog(@"%@",responseObject);
    
    if (responseObject == nil) {//只限于搜狐登录(邮箱密码)登录后需要进入绑定页面的
        responseObject = self.bindpreData;
    }
    
    NSDictionary* userInfoDic = [responseObject objectForKey:@"userInfo"];
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
    
//    [self notifyGetUserinfoSuccess:nil];
//    
//    [SNNotificationManager postNotificationName:kNotifyGetUserinfoSuccess object:nil];
//    [SNNotificationManager postNotificationName:kRollingChannelReloadNotification object:nil];
//    
//    [self notifyLoginSuccess];
    
    if (self.successed_Method) {
        NSDictionary* re_dic = @{@"success":@"1"};
        self.successed_Method(re_dic);
    }
}

-(void)openBindViewController:(NSDictionary *)dic{
    isLoading = NO;
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"data",self,@"third",@"1",@"sohulogin",nil];
    [SNNewsLoginManager bindData:query Successed:nil];
}

@end
