//
//  SNNewsLogout.m
//  sohunews
//
//  Created by wang shun on 2017/5/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLogout.h"

#import "SNLogoutRequest.h"
#import "SNUserUtility.h"
#import "SNSLib.h"
#import "SNMySDK.h"

@interface SNNewsLogout ()

@end

@implementation SNNewsLogout


+ (void)requestLogout:(void (^)(NSDictionary *))method{
    
    if(![SNUserinfoEx isLogin]) return;
    
    [[[SNLogoutRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [responseObject intValueForKey:@"status" defaultValue:0];
        NSString* msg = [responseObject stringValueForKey:@"msg" defaultValue:@""];
        if(status == 0) {
            
            [SNUserUtility handleUserLogout];
            
#pragma mark - huangjing  //我的SDK调用退出逻辑添加
            [SNSLib  loginOutWith:@{@"loginOut":@"1"}];
            [[SNMySDK sharedInstance] logout];
#pragma mark - end
            
            if (method) {
                method (@{@"loginOut":@"1",@"status":[NSNumber numberWithInt:status],@"msg":msg});
            }
        }
        else{
            
#pragma mark - huangjing //我的SDK调用退出逻辑添加
            [SNSLib loginOutWith:@{@"loginOut":@"0"}];
#pragma mark - end
            
            if (method) {
                method (@{@"loginOut":@"0",@"status":[NSNumber numberWithInt:status],@"msg":msg});
            }
            
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [SNSLib loginOutWith:@{@"loginOut":@"0"}];//my sdk 退出失败
        
        if (method) {
            method (@{@"loginOut":@"-2"});
        }
    }];
}

@end
