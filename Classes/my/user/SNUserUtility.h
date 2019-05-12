//
//  SNUserUtility.h
//  sohunews
//
//  Created by weibin cheng on 14-2-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNUserUtility : NSObject

//解析user数据
+ (void)parseUserinfo:(SNUserinfoEx*)userInfo fromDictionary:(NSDictionary*)dic;

//判断用户名是否合法
+ (BOOL)isValidateUsername:(NSString*)aUsername;

//判断手机号是否合法
+ (BOOL)isMobileValidateTelNumber:(NSString*)aNumber;

//判断密码是否合法
+ (BOOL)isValidatePassword:(NSString*)aPassword;

//判断email是否合法
+ (BOOL)isValidateEmail:(NSString*)aEmail;

//处理用户登录,只有登陆成功后才调用，慎用
+ (void)handleUserLogin;

//处理用户注销,只有登陆成功后才调用，慎用
+ (void)handleUserLogout;

//打开用户中心
+ (BOOL)openUserWithPassport:(NSString *)passport
                   spaceLink:(NSString *)spaceLink
                   linkStyle:(NSString *)linkStyle
                         pid:(NSString *)pid
                        push:(NSString *)push refer:(NSDictionary *)referInfo;

@end
