//
//  SNPhoneLoginViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNPhoneLoginViewModel : NSObject

/** 手机号登录
 */
- (void)loginWithPhoneAndVcode:(NSDictionary*)params Successed:(void (^)(NSDictionary* resultDic))method;

@end
