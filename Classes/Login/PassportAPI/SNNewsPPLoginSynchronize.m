//
//  SNNewsPPLoginSynchronize.m
//  sohunews
//
//  Created by wang shun on 2017/11/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginSynchronize.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginHeader.h"

#import "SNNewsPPLoginSyncUserInfoRequest.h"
#import "SNUserManager.h"
#import "SNUserinfo.h"

@implementation SNNewsPPLoginSynchronize

+ (void)ppLoginSynchronize:(NSDictionary*)params LoginType:(NSString*)loginType UserInfo:(NSDictionary*)userInfo callback:(void (^)(NSDictionary*))method{
    
    NSDictionary* data = [userInfo objectForKey:@"data"];
    NSString* pp_token = [data objectForKey:@"appSessionToken"];
    NSString* pp_passport = [data objectForKey:@"passport"];
    SNDebugLog(@"data:::%@",data);
    
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //这里必须要有gid
    NSString* gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
    [mDic setObject:gid forKey:@"gid"];
    
    NSString* passport = pp_passport;
    [mDic setObject:passport forKey:@"passport"];
    
    NSString* ppAppId = SNNewsPPLogin_APPID;
    [mDic setObject:ppAppId forKey:@"ppAppId"];
    
    NSString* ppAppVs = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [mDic setObject:ppAppVs forKey:@"ppAppVs"];
    
    NSString* ppToken = pp_token;
    [mDic setObject:ppToken forKey:@"ppToken"];

    NSString* p1 = [SNUserManager getP1];
    [mDic setObject:p1 forKey:@"p1"];
    
    NSString* u = @"1";//产品id u=1 不知道干啥的 写死 @wangshun
    [mDic setObject:u forKey:@"u"];
    
    NSString* login_Type = @"1";
    if ([loginType isEqualToString:@"sohu"]) {
        login_Type = @"3";
        
    }
    else if ([loginType isEqualToString:@"third"]){
        login_Type = @"2";
        
        NSString* platform = [params objectForKey:@"platform"];
        NSString* appId = @"";
        if([platform isEqualToString:@"wechat"]){
            appId = @"8";
        }
        else if ([platform isEqualToString:@"sina"]){
            appId = @"1";
        }
        else if ([platform isEqualToString:@"qq"]){
            appId = @"6";
        }
        
        [mDic setObject:appId forKey:@"appId"];
        
        NSString* from = @"login";//写死 ios 只一种情况， 安卓有多种参数 @wangshun
        [mDic setObject:from forKey:@"from"];
        
        NSString* tpToken = [params objectForKey:@"accesstoken"];
        [mDic setObject:tpToken forKey:@"tpToken"];
    }
    else if ([loginType isEqualToString:@"mobile"]){
        login_Type = @"1";
    }
    [mDic setObject:login_Type forKey:@"loginType"];
    
    NSString* ua = [SNNewsPPLoginHeader getUA];
    [mDic setObject:ua forKey:@"ua"];
    NSString* openId = [params objectForKey:@"openid"]?:@"";
    [mDic setObject:openId forKey:@"openId"];
    
/***************************************************************************************/
    
    NSString* macAaddress = [SNNewsPPLoginHeader getMac];
    [mDic setObject:macAaddress forKey:@"macAaddress"];
    

    NSString* innerIp = [SNNewsPPLoginHeader getIPAddress];
    [mDic setObject:innerIp forKey:@"innerIp"];

    NSString* longitude = [SNNewsPPLoginHeader getLongitude];
    [mDic setObject:longitude forKey:@"longitude"];
    NSString* latitude = [SNNewsPPLoginHeader getLatitude];
    [mDic setObject:latitude forKey:@"latitude"];
    
    NSString* osType = [NSString stringWithFormat:@"iOS %0.2f",[SNNewsPPLoginHeader getIOSVersion]];
    [mDic setObject:osType forKey:@"osType"];
    
/***************************************************************************************/
    
    [[[SNNewsPPLoginSyncUserInfoRequest alloc] initWithDictionary:mDic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"sync resp:::%@",responseObject);
        if (responseObject) {
            NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
            if (statusCode.integerValue == 10000000) {
                
                NSDictionary* resp_data = [responseObject objectForKey:@"data"];
                
                NSString* pid = [resp_data objectForKey:@"pid"];
                
                NSString* nick = [resp_data objectForKey:@"nick"];
                
                NSString* avator = [resp_data objectForKey:@"avator"];
                
                NSMutableDictionary* user_info = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                [user_info setObject:pid forKey:@"pid"];
                [user_info setObject:pp_passport forKey:@"passport"];
                [user_info setObject:nick forKey:@"nick"];
                [user_info setObject:avator forKey:@"avator"];
                [user_info setObject:ppToken forKey:@"token"];
                
                SNUserinfoEx *aUserInfo = [SNUserinfoEx userinfoEx];
                [aUserInfo ppSaveUserInfo:user_info];
                
                if (method) {
                    NSDictionary* re_dic = @{@"success":@"1"};
                    method(re_dic);
                }
                
                [[SNNewsPPLogin sharedInstance] createCookie];
                
                [SNNewsPPLogin setCookie:@{@"PP-GID":gid} WithResult:^(NSDictionary *info) {
                    
                }];
                
                return ;
            }
        }
        
        if (method) {
            NSDictionary* re_dic = @{@"success":@"0"};
            method(re_dic);
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (method) {
            NSDictionary* re_dic = @{@"success":@"-2"};
            method(re_dic);
        }
    }];
}

@end

