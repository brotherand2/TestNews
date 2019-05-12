//
//  SNNewsCheckToken.m
//  sohunews
//
//  Created by wang shun on 2017/5/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsCheckToken.h"
#import "SNNewsPPLoginCookie.h"

@implementation SNNewsCheckToken

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -  checkToken

+ (BOOL)checkTokenRequest {
    SNDebugLog(@"userinfo");
    SNUserinfoEx* userInfo = [SNUserinfoEx userinfoEx];
    if(userInfo!=nil) {
        SNDebugLog(@"userInfo.token:%@",userInfo.token);
        SNDebugLog(@"userInfo.getUsername:%@",userInfo.getUsername);
        if(!userInfo.token || ![userInfo getUsername]) {
            [SNNewsCheckToken dologout];
        }
        else{
            [[[SNCheckTokenRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
                
                //http://10.10.26.127:8080/doc/smc-api/index.html#api-usercenter-chkTk
                //wangshun 2017.3.20 修改逻辑
                if([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
                    NSNumber* checkResult = [responseObject objectForKey:@"checkResult"];
                    
                    if(statusCode!=nil && [statusCode intValue] == 10000000) {
                        if (checkResult.integerValue ==0) {
                            [SNNewsCheckToken dologout];//两个字段同事判断是否登出 wangshun
                        }
                    }
                }
                
            } failure:^(SNBaseRequest *request, NSError *error) {
                SNDebugLog(@"SNCheckTokenRequest::::%@",error);
            }];
            return YES;
        }
    }
    //by default
    return NO;
}

+ (void)dologout{
    //过期
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUserExpire];
    //if(_usrinfo._headImageUrl!=nil) [[NSUserDefaults standardUserDefaults] setObject:_usrinfo._headImageUrl forKey:@"SNUserExpireHeadUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SNNotificationManager postNotificationName:kUserDidLogoutNotification object:nil];
    [SNUserinfoEx clearUserinfoFromUserDefaults];
    [[SNDBManager currentDataBase] deleteMyFavouriteAll];
    [SNUtility deleteAllCookies];//删除cookie
    [SNNewsPPLoginCookie deleteCookie];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@end
