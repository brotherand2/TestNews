//
//  SNUserManager.h
//  sohunews
//
//  Created by weibin cheng on 13-10-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNUserConsts.h"

typedef enum {
    SNUserLoginMobile  = 0,        // 手机登录
    SNUserLoginTh3 = 1,        //第三方
    SNUserLoginSohu = 2,        //搜狐登录
}SNUserLoginType;

@interface SNUserManager : NSObject

+(SNUserManager*)shareInstance;

+(SNUserLoginType)getLoginType;

+(BOOL)isLogin;

+(NSString*)getGid;

+(NSString*)getPid;

+(NSString *)getCid;

//p1就是对cid的编码
+(NSString*)getP1;

//userId就是大家说的passport
+(NSString*)getUserId;

+(NSString*)getNickName;

+(NSString*)getToken;

+(NSString*)getCookie;

+(NSString*)getHeadImageUrl;

+(NSString *)getMobil;

+(BOOL)getIsRealName;

//wangshun 2017.5.5
//检验token有效期，程序启动得时候需要验证一下
//-(BOOL)checkTokenValid;

@end
