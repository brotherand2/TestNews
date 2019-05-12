//
//  SNQQLogin.h
//  sohunews
//
//  Created by wang shun on 2017/4/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNQQLogin : NSObject

@property (nonatomic, strong) SNThirdLoginSuccess* thirdLoginSuccess;
@property (nonatomic,strong) NSDictionary* userInfoDic;//绑定之前已经拿到的userinfo

+ (void)qqlogin:(NSDictionary*)params WithSuccessed:(void(^)(NSDictionary*resultDic))method;

@end
