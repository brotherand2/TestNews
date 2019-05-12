//
//  SNNewsCheckToken.h
//  sohunews
//
//  Created by wang shun on 2017/5/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCheckTokenRequest.h"
#import "SNDBManager.h"

@interface SNNewsCheckToken : NSObject

/** 检查token 有效 无效自动登出
 */
+ (BOOL)checkTokenRequest;

@end
