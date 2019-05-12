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

@interface SNPhoneLoginViewModel ()
{
    BOOL isLoading;
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
                }
            }];
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
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
            re_dic = @{@"success":@"0"};
            //受制于弹窗时间 SNCenterToast
            [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic afterDelay:1.8];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"MobileSmsLogin:::%@",error);
        isLoading = NO;
        NSDictionary* re_dic = @{@"success":@"0"};
        [self performSelector:@selector(mobileSmsLoginSuccess:) withObject:re_dic];
    }];
}

- (void)mobileSmsLoginSuccess:(NSDictionary*)result{
    if (self.successed_Method) {
        self.successed_Method(result);
    }
}

@end
