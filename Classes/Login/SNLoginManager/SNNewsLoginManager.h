//
//  SNNewsLoginManager.h
//  sohunews
//
//  Created by wang shun on 2017/4/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLoginManager : NSObject

/** 登录
 */
+ (void)loginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed;

/** 第三方登录 (含sohu)
 */
+ (void)loginThird:(NSString*)plat Data:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed;

/** 绑定
 */
+ (void)bindData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed;


/** 绑定 仅手机号登录 红包 (调绑定页面 走登录逻辑)
 */
+ (void)phoneLoginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success;

/** 半屏登录 params : {@"loginFrom":xxxx,@"halfScreenTitle":xxxx}
 */
+ (void)halfLoginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed;


@end
