//
//  SNWeiXinLogin.h
//  sohunews
//
//  Created by wang shun on 2017/4/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "SNThirdLoginSuccess.h"

@interface SNWeiXinLogin : NSObject

@property (nonatomic,strong) SNThirdLoginSuccess* thirdLoginSuccess;
@property (nonatomic,strong) NSDictionary* userInfoDic;//绑定之前已经拿到的userinfo

+ (void)weixinLogin:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary*))method;

- (void)setURLWithCode:(NSString *)code;

@end
