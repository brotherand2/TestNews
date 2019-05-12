//
//  SNSendSmsGo.h
//  sohunews
//
//  Created by wang shun on 2017/3/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSendSmsGo : NSObject

@property (nonatomic,copy) void (^countDownTime)(void);

- (void)analyseResp:(SNBaseRequest *) request withData:(NSDictionary*)respDic;

/*! 是否是发送验证码接口 !*/
+ (BOOL)isSendSmsGo:(SNBaseRequest*)request;

@end
