//
//  SNSendSmsGo.m
//  sohunews
//
//  Created by wang shun on 2017/3/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSendSmsGo.h"

@implementation SNSendSmsGo

- (void)analyseResp:(SNBaseRequest *) request withData:(NSDictionary*)respDic{
    NSNumber* statusCode = [respDic objectForKey:@"statusCode"];
    NSString* statusMsg  = [respDic objectForKey:@"statusMsg"];
    
    if (statusCode.integerValue == 10000000) {//成功
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeOnlyText];
        
        if (self.countDownTime) {
            self.countDownTime();
        }
    }
    else if (statusCode.integerValue == 10000030){//
        [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000031){
        [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}


+ (BOOL)isSendSmsGo:(SNBaseRequest *)request{
    
    NSString* url = @"api/usercenter/sendSms.go";
    
    NSRange range = [request.url rangeOfString:url];
    if (range.location != NSNotFound) {//是
        return YES;
    }
    
    return NO;
}

@end
