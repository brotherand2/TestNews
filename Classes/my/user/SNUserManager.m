//
//  SNUserManager.m
//  sohunews
//
//  Created by weibin cheng on 13-10-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNUserManager.h"
#import "SNUserConsts.h"
#import "SNUserinfo.h"

#import "SNNewsCheckToken.h"

#import "SNNewsPPLogin.h"

static NSString *staticP1String = nil;
static NSString *staticGidString = nil;
static NSString *staticPPGidString = nil;

@interface SNUserManager ()

@property (nonatomic, strong) SNUserAccountService* accountService;

@end


@implementation SNUserManager
@synthesize accountService = _accountService;

+(SNUserManager*)shareInstance
{
    static SNUserManager* _userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userManager = [[SNUserManager alloc] init];
    });
    return _userManager;
}

-(void)dealloc
{
     //(_accountService);
     //(staticP1String);
     //(staticGidString);
}


+(BOOL)isLogin
{
    return [SNUserinfoEx isLogin];
}

+(SNUserLoginType)getLoginType{
    return SNUserLoginSohu;
}

+(NSString*)getGid
{
    if(staticPPGidString){
        SNDebugLog(@"staticPPGidString::::%@",staticPPGidString);
        return staticPPGidString;
    }
    //新登录 覆盖gid 设备唯一标识 wangshun
    NSString* pp_gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
    if (pp_gid) {
        SNDebugLog(@"PP_GID::::%@",pp_gid);
        staticPPGidString = pp_gid;
        return staticPPGidString;
    }
    
    if (staticGidString) {
        SNDebugLog(@"staticGidString::::%@",staticGidString);
        return staticGidString;
    }
    
    NSMutableString* string = [NSMutableString stringWithCapacity:0];
    [string appendString:@"01"];                    //ostype ：系统类型
    [string appendString:@"0101"];                  //modeltype ： 设备类型
    [string appendString:kPassportAppId];           //appid
    [string appendString:@"0001"];                  //mask：四字节掩码，从低到高分别表示imei、imsi、mac、uuid是否存在（1存在、0不存在）
    [string appendString:[[SNUtility getCFUUID] md5Hash]];     //modeltype ： 设备类型
    staticGidString = string;
    return staticGidString;
}

+(NSString*)getPid
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    if (userinfo.pid.length > 0) {
        return userinfo.pid;
    } else {
        return @"-1";
    }
}

+(NSString *)getCid {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
}

+(NSString*)getP1
{
    if (staticP1String) {
        return staticP1String;
    }
    NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if (savedUid.length) {
        NSString* encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
        NSString *p1Str = [encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        staticP1String = p1Str;
        return staticP1String;
    }
    return [[kDefaultProfileClientID dataUsingEncoding:NSUTF8StringEncoding] base64String];
}

+(NSString*)getUserId
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    if(userinfo.userName)
        return userinfo.userName;
    else
        return userinfo.uid;
}

+(NSString*)getNickName
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    if(userinfo.nickName)
        return userinfo.nickName;
    else if(userinfo.userName)
        return userinfo.userName;
    else
        return userinfo.uid;
}

+(NSString*)getToken
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    return userinfo.token;
}

+(NSString*)getCookie
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    return userinfo.cookieValue;
}

+(NSString*)getHeadImageUrl
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    if (userinfo.headImageUrl.length > 0) {
        return userinfo.headImageUrl;
    } else {
        return userinfo.icon;
    }
}

+(NSString *)getMobil
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    return userinfo.mobile;
}

+(BOOL)getIsRealName
{
    SNUserinfoEx *userinfo = [SNUserinfoEx userinfoEx];
    return userinfo.isRealName;
}
//
//- (BOOL)checkTokenValid
//{
//    return [SNNewsCheckToken checkTokenRequest];
//}




@end
