//
//  SNPhoneLoginViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPhoneLoginViewModel.h"
#import "SNValidateMobileNumModel.h"
#import "SNMobileSmsLoginRequest.h"

#import "SNUserManager.h"
#import "SNSLib.h"
#import "SNNewsRecordLastLogin.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginThirdAnalyse.h"
#import "SNNewsPPLoginEnvironment.h"

@interface SNPhoneLoginViewModel ()
{
    BOOL isLoading;
    BOOL isPhoneLoginViewModel;
}
@property (nonatomic,copy) void (^successed_Method)(NSDictionary* resultDic);

@property (nonatomic,strong) SNValidateMobileNumModel* isValidateMobile;

@end

@implementation SNPhoneLoginViewModel

- (instancetype)init{
    if (self = [super init]) {
        self.isValidateMobile = [[SNValidateMobileNumModel alloc] init];
    }
    return self;
}

- (void)loginWithPhoneAndVcode:(NSDictionary*)params Successed:(void (^)(NSDictionary* resultDic))method{
    if (isLoading == YES) {
        return;
    }
    isLoading = YES;
    
    NSString* phonelogin = [params objectForKey:@"isPhoneLoginViewModel"];
    if ([phonelogin isEqualToString:@"1"]) {
        isPhoneLoginViewModel = YES;
    }
    else{
        isPhoneLoginViewModel = NO;
    }
    
    NSString* phone = [params objectForKey:@"phone"];
    if (phone && phone.length>0) {
        NSString* vcode = [params objectForKey:@"vcode"];
        if (vcode && vcode.length>0) {//发起登录
            __weak SNPhoneLoginViewModel* weakSelf = self;
            //验证手机号有效
            [self.isValidateMobile isValidateMobileNum:phone Successed:^(NSDictionary *resultDic) {
                //手机号有效则 登录
                NSString* success = [resultDic objectForKey:@"success"];
                if ([success isEqualToString:@"1"]) {
                    [weakSelf phoneLoginRequest:params Successed:method];
                    return;
                }
                else{//无效
                    isLoading = NO;
                    NSDictionary* re_dic = @{@"success":@"0"};
                    [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic];
                }
            }];
            
            return;
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    
    isLoading = NO;
    NSDictionary* re_dic = @{@"success":@"0"};
    [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic afterDelay:1.8];
}

- (void)phoneLoginRequest:(NSDictionary*)params Successed:(void (^)(NSDictionary*resultDic))method{
    if (method) {
        self.successed_Method = method;
    }
    
    NSString* phone   = [params objectForKey:@"phone"];//手机号
    NSString* captcha = [params objectForKey:@"vcode"];//验证码
    
    NSDictionary* dic = @{@"mobileNo":phone?:@"",@"captcha":captcha?:@""};
    
    if ([SNNewsPPLoginEnvironment isPPLogin] && !isPhoneLoginViewModel) {
        [SNNewsPPLogin mobileVcodeLogin:dic WithResult:^(NSDictionary *info) {
            
            [self ppMobileLoginLogin:dic Resp:info Successed:nil];
        }];
        
        return;
    }
    /* 手机号验证码 登录接口
     params: mobileNo
             captcha
     */
    [[[SNMobileSmsLoginRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"MobileSmsLogin:::%@",responseObject);
        isLoading = NO;
        NSNumber* status = [responseObject objectForKey:@"status"];
        NSString* msg    = [responseObject objectForKey:@"msg"];
        NSDictionary* re_dic = nil;
        if (status && status.integerValue == 0) {//成功
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
            
            NSString *userID = [responseObject objectForKey:@"userId"];
            NSString *token = [responseObject objectForKey:@"token"];
            NSString *pid = [responseObject objectForKey:@"pid"];
            NSString *nick = [responseObject objectForKey:@"nick"];
            
            SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
            userInfoEx.userName = userID;
            userInfoEx.pid = [NSString stringWithFormat:@"%@", pid];
            userInfoEx.token = token;
            userInfoEx.nickName = nick;
            userInfoEx.passport = userID;
            
            NSDictionary* userInfo = [responseObject objectForKey:@"userInfo"];
            [userInfoEx parseUserinfoFromDictionary:userInfo];
            [userInfoEx saveUserinfoToUserDefault];
            
            re_dic = @{@"success":@"1"};
            //受制于弹窗时间 SNCenterToast
            [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic afterDelay:1.8];
            
            [self burySuccess:@"1" loginType:@"mobile" errType:@"0"];
            
            [SNNewsRecordLastLogin saveLogin:nil];
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
            re_dic = @{@"success":@"0"};
            isLoading = NO;
            //受制于弹窗时间 SNCenterToast
            [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic afterDelay:1.8];
            
            [self burySuccess:@"-1" loginType:@"mobile" errType:@"0"];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"MobileSmsLogin:::%@",error);
        isLoading = NO;
        NSDictionary* re_dic = @{@"success":@"0"};
        [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic];
        [self burySuccess:@"-1" loginType:@"mobile" errType:@"0"];
    }];
}

- (void)mobileSmsLoginSuccess:(NSDictionary*)result{
    if (self.successed_Method) {
        self.successed_Method(result);
    }
}


- (void)ppMobileLoginLogin:(NSDictionary*)params Resp:(NSDictionary*)info Successed:(void (^)(NSDictionary*))method{
    
    [SNNewsPPLoginThirdAnalyse mobilePPLoginParams:params Response:info Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                NSDictionary* re_dic = @{@"success":@"1"};
                //受制于弹窗时间 SNCenterToast
                [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic afterDelay:1.8];
                
                [self burySuccess:@"1" loginType:@"mobile" errType:@"0"];
                return;
            }
        }
        
        
        isLoading = NO;
        NSDictionary* re_dic = @{@"success":@"0"};
        //受制于弹窗时间 SNCenterToast
        [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic afterDelay:1.8];
        
        [self burySuccess:@"-1" loginType:@"mobile" errType:@"0"];
        
    }];
}

#pragma mark - 埋点

- (void)burySuccess:(NSString*)str loginType:(NSString*)loginType errType:(NSString*)errType{
    //    NSDictionary* dic = @{@"loginSuccess":str,@"loginType":loginType,@"cid":[SNUserManager getP1],@"errType":errType?:@""};
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:str?:@"" forKey:@"loginSuccess"];
    [dic setObject:loginType?:@"" forKey:@"loginType"];
    [dic setObject:[SNUserManager getP1] forKey:@"cid"];
    
    if ([self.screen isEqualToString:@"1"]) {
        [dic setObject:@"1" forKey:@"screen"];
    }
    else{
        [dic setObject:@"0" forKey:@"screen"];
    }
    
    if ([str isEqualToString:@"1"] && [loginType isEqualToString:@"mobile"]) {
        
    }
    else{
        if (errType) {
            [dic setObject:errType?:@"" forKey:@"errType"];
        }
    }
    
    NSString* sourceID = self.sourceChannelID;
    SNDebugLog(@"手机号 sourceChannelID:%@ dic:%@",sourceID,dic);
    if (!self.sourceChannelID) {
        sourceID = [SNShareManager defaultManager].loginFrom?:@"";
    }
    if (sourceID && ![sourceID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceID bodyDic:dic];
    }
    
    if ([str isEqualToString:@"1"]) {
        NSString* agif = @"_act=login&s=mobile";
        if(self.entrance){
            agif = [agif stringByAppendingFormat:@"&entrance=%@",self.entrance];
        }
        [SNNewsReport reportADotGif:agif];
    }
}

@end
