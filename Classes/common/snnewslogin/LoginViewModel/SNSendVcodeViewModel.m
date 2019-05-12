//
//  SNSendVcodeViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSendVcodeViewModel.h"

#import "SNSendVerifyCodeRequest.h"
#import "SNValidateMobileNumModel.h"

@interface SNSendVcodeViewModel ()
{
    BOOL isLoading;
}
@property (nonatomic,strong) SNValidateMobileNumModel* isValidateMobile;

@end

@implementation SNSendVcodeViewModel

- (instancetype)init{
    if (self = [super init]) {
        self.isValidateMobile = [[SNValidateMobileNumModel alloc] init];
    }
    return self;
}

- (void)sendVcode:(NSDictionary*)params Completion:(void (^)(NSDictionary*resultDic))method{
    if (isLoading == YES) {
        return;
    }
    isLoading = YES;
    
    NSString* phone = [params objectForKey:@"phone"];
    if (phone && phone.length>0) {
        __weak SNSendVcodeViewModel* weakSelf = self;
        //验证手机号有效
        [self.isValidateMobile isValidateMobileNum:phone Successed:^(NSDictionary *resultDic) {
            
            //手机号有效则 发送验证码
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                [weakSelf sendVerifyCodeRequest:params Successed:method];
            }
            else{//无效
                
            }
        }];
        
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

/** 发送验证码
 */
- (void)sendVerifyCodeRequest:(NSDictionary*)params Successed:(void (^)(NSDictionary* resultDic))method {
    NSString* type    = [params objectForKey:@"type"];
    NSString* phone   = [params objectForKey:@"phone"];
    
    NSDictionary* dic = @{@"type":type,@"mobileNo":phone};
    
    [[[SNSendVerifyCodeRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        
        NSDictionary* re_dic = nil;
        if (statusCode.integerValue == 10000000) {//成功
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeOnlyText];
            if (method) {
                isLoading = NO;
                re_dic = @{@"success":@"1"};
                method(re_dic);
                return;
            }
        }
        else if (statusCode.integerValue == 10000030){//
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else if (statusCode.integerValue == 10000031){
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        isLoading = NO;
        if (method) {
            re_dic = @{@"success":@"0"};
            method(re_dic);
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        isLoading = NO;
        if (method) {
            NSDictionary* re_dic = @{@"success":@"0"};
            method(re_dic);
        }
    }];
}

@end
