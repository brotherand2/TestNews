//
//  SNNewsPPLoginThirdAnalyse.h
//  sohunews
//
//  Created by wang shun on 2017/11/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsPPLoginThirdAnalyse : NSObject
//两种错误情况不一样 所以分别解析

//手机号验证码登录解析
//http://wiki.sohu-inc.com/pages/viewpage.action?pageId=26051085
+ (void)mobilePPLoginParams:(NSDictionary*)params Response:(NSDictionary*)info Successed:(void (^)(NSDictionary* resultDic))method;

//第三方登录解析
//http://wiki.sohu-inc.com/pages/viewpage.action?pageId=26055912
+ (void)analysePPLoginParams:(NSDictionary*)params Response:(NSDictionary*)info Successed:(void (^)(NSDictionary* resultDic))method;

//搜狐登录解析(账号密码)
//http://wiki.sohu-inc.com/pages/viewpage.action?pageId=26053035
+ (void)sohuPPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info Successed:(void (^)(NSDictionary *resultDic))method;

@end
