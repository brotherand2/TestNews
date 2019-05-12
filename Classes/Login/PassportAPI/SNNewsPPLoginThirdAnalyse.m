//
//  SNNewsPPLoginThirdAnalyse.m
//  sohunews
//
//  Created by wang shun on 2017/11/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginThirdAnalyse.h"

#import "SNNewsPPLoginSynchronize.h"
#import "SNNewsPPLogin.h"

@implementation SNNewsPPLoginThirdAnalyse

+ (void)mobilePPLoginParams:(NSDictionary*)params Response:(NSDictionary*)info Successed:(void (^)(NSDictionary* resultDic))method{
    NSString* success = [info objectForKey:@"success"];
    if ([success isEqualToString:@"1"]) {
        NSDictionary* resp = [info objectForKey:@"resp"];
        if (resp && [resp isKindOfClass:[NSDictionary class]]) {
            
            NSNumber* status = [resp objectForKey:@"status"];
            if (status.integerValue == 200) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录成功" toUrl:nil mode:SNCenterToastModeOnlyText];
                
                //同步用户信息 登录成功 拿到pid
                [SNNewsPPLoginSynchronize ppLoginSynchronize:params LoginType:@"mobile" UserInfo:resp callback:^(NSDictionary *resultDic) {
                    
                    if (resultDic) {
                        NSString* success = [resultDic objectForKey:@"success"];
                        if ([success isEqualToString:@"1"]) {//登录成功
                            
                            if (method) {
                                NSDictionary* re_dic = @{@"success":@"1",@"resp":resp};
                                method(re_dic);
                            }
                            return;
                        }
                    }
                    
                    if (method) {
                        NSDictionary* re_dic = @{@"success":@"0"};
                        method(re_dic);
                    }
                }];
                return;
            }
            else if (status.integerValue == 40001){//手机验证码错误
                NSString* msg = [resp objectForKey:@"message"];
                if ([msg isEqualToString:@"mcode too length"]) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码输入有误" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            else if (status.integerValue == 40005){//header error 容错
                NSString* gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
                if (!(gid && gid.length>0)) {
                    [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
                        SNDebugLog(@"PP-GID:%@",gid);
                    }];
                }
            }
            else if(status.integerValue == 40101){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码输入错误" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40301){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"账户异常不能登录" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40102){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请重新获取验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else{
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录失败" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
        
    }
    else if ([success isEqualToString:@"-2"]){
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (method) {
            NSDictionary* re_dic = @{@"success":@"-2"};
            method(re_dic);
        }
        return;
    }
    
    if (method) {
        NSDictionary* re_dic = @{@"success":@"0"};
        method(re_dic);
    }
}

//第三方登录
+ (void)analysePPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info Successed:(void (^)(NSDictionary *))method{
    NSString* success = [info objectForKey:@"success"];
    if ([success isEqualToString:@"1"]) {
        NSDictionary* resp = [info objectForKey:@"resp"];
        if (resp && [resp isKindOfClass:[NSDictionary class]]) {
            NSNumber* status = [resp objectForKey:@"status"];
            if (status.integerValue == 200) {//登录成功
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录成功" toUrl:nil mode:SNCenterToastModeOnlyText];
                    
                    //同步用户信息 登录成功 拿到pid
                    [SNNewsPPLoginSynchronize ppLoginSynchronize:params LoginType:@"third" UserInfo:resp callback:^(NSDictionary *resultDic) {
                        
                        if (resultDic) {
                            NSString* success = [resultDic objectForKey:@"success"];
                            if ([success isEqualToString:@"1"]) {//登录成功
                                
                                if (method) {
                                    NSDictionary* re_dic = @{@"success":@"1",@"resp":resp};
                                    method(re_dic);
                                }
                                return;
                            }
                        }
                        
                        if (method) {
                            NSDictionary* re_dic = @{@"success":@"0"};
                            method(re_dic);
                        }
                    }];
                    
                });
                return;
            }
            else if (status.integerValue == 40001){//手机验证码错误
                NSString* msg = [resp objectForKey:@"message"];
                if ([msg isEqualToString:@"mcode too length"]) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码输入有误" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
                else{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"openKey is blank" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            else if (status.integerValue == 40005){//header error 容错
                NSString* gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
                if (!(gid && gid.length>0)) {
                    [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
                        SNDebugLog(@"PP-GID:%@",gid);
                    }];
                }
            }
            else if (status.integerValue == 40101){//手机验证码错误
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码有误" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40102){//手机验证码未设置或已过期
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请重新获取验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40301){//账号冻结，不能登录
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"帐号异常，稍后再试" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40321){//手机绑定账户数已达到上限，需更换手机
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"手机绑定账号超限，请更换手机再试" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40323){//账户未绑定手机，需要手机号和手机验证码
                //[[SNCenterToast shareInstance] showCenterToastWithTitle:@"为了您的帐号安全，登录前需绑定手机" toUrl:nil mode:SNCenterToastModeOnlyText];
                if (method) {
                    NSDictionary* re_dic = @{@"success":@"40323",@"pp_thirdParams":params};
                    method(re_dic);
                }
                return;
            }
            else if (status.integerValue == 40601){//第三方账户校验失败
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"授权失败，请重试" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
        
    }
    else if ([success isEqualToString:@"-2"]){
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (method) {
            NSDictionary* re_dic = @{@"success":@"-2"};
            method(re_dic);
        }
        return;
    }
    
    if (method) {
        NSDictionary* re_dic = @{@"success":@"0"};
        method(re_dic);
    }
}


+ (void)sohuPPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info Successed:(void (^)(NSDictionary *))method{
    NSString* success = [info objectForKey:@"success"];
    if ([success isEqualToString:@"1"]) {
        NSDictionary* resp = [info objectForKey:@"resp"];
        if (resp && [resp isKindOfClass:[NSDictionary class]]) {
            NSNumber* status   = [resp objectForKey:@"status"];
            if (status.integerValue == 200) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录成功" toUrl:nil mode:SNCenterToastModeOnlyText];
                
                //同步用户信息 登录成功 拿到pid
                [SNNewsPPLoginSynchronize ppLoginSynchronize:params LoginType:@"sohu" UserInfo:resp callback:^(NSDictionary *resultDic) {
                    
                    if (resultDic) {
                        NSString* success = [resultDic objectForKey:@"success"];
                        if ([success isEqualToString:@"1"]) {//登录成功
                            
                            if (method) {
                                NSDictionary* re_dic = @{@"success":@"1",@"resp":resp};
                                method(re_dic);
                            }
                            return;
                        }
                    }
                    
                    if (method) {
                        NSDictionary* re_dic = @{@"success":@"0"};
                        method(re_dic);
                    }
                }];
                
                return;
            }
            else if (status.integerValue == 40001){//手机验证码错误
                NSString* msg = [resp objectForKey:@"message"];
                if ([msg isEqualToString:@"mcode too length"]) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码输入有误" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            else if (status.integerValue == 40005){//header error 容错
                NSString* gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
                if (!(gid && gid.length>0)) {
                    [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
                        SNDebugLog(@"PP-GID:%@",gid);
                    }];
                }
            }
            else if (status.integerValue == 40101){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码有误" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40102){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请重新获取验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40104){//js挑战失败
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请刷新页面" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40105){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"输入图片验证码有误" toUrl:nil mode:SNCenterToastModeOnlyText];
                if (method) {
                    NSDictionary* re_dic = @{@"success":@"40105"};
                    method(re_dic);
                }
                return;
            }
            else if (status.integerValue == 40501){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"帐号或密码错误" toUrl:nil mode:SNCenterToastModeOnlyText];
                if (method) {
                    NSDictionary* re_dic = @{@"success":@"40501"};
                    method(re_dic);
                }
                return;
            }
            else if (status.integerValue == 40502){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"帐号未设置密码" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40301){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"帐号冻结,请联系搜狐" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40301){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"手机绑定账号超限，请更换手机再试" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (status.integerValue == 40108){
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入图形验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
                if (method) {
                    NSDictionary* re_dic = @{@"success":@"40108"};
                    method(re_dic);
                }
                return;
            }
            else if (status.integerValue == 40323){
                if (method) {
                    NSDictionary* re_dic = @{@"success":@"40323"};
                    method(re_dic);
                }
                return;
            }
        }
    }
    else if ([success isEqualToString:@"-2"]){
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (method) {
            NSDictionary* re_dic = @{@"success":@"-2"};
            method(re_dic);
        }
        return;
    }
    
    if (method) {
        NSDictionary* re_dic = @{@"success":@"0"};
        method(re_dic);
    }
}

@end
