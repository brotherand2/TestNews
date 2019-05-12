//
//  SNNewsLoginSuccess.h
//  sohunews
//
//  Created by wang shun on 2017/4/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLoginSuccess : NSObject

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^loginSuccess)(NSDictionary* resultDic);

-(instancetype)initWithParams:(NSDictionary*)params;

- (void)loginSucessed:(NSDictionary*)dic;

/** 登录成功通知
 */
- (void)postLoginSuccessNotification;

@end
