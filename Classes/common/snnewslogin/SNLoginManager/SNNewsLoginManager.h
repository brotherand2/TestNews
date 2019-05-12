//
//  SNNewsLoginManager.h
//  sohunews
//
//  Created by wang shun on 2017/4/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLoginManager : NSObject

/** 登录   info : {@"success":@"1"}//success:1 成功  success:0 失败
 */
+ (void)loginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success;

/** 绑定   info : {@"success":@"1"}//success:1 成功  success:0 失败
 */
+ (void)bindData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success;


/** 绑定 仅手机号登录 红包 (调绑定页面 走登录逻辑)   info : {@"success":@"1"}//success:1 成功  success:0 失败
 */
+ (void)phoneLoginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success;


@end
