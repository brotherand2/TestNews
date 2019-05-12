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

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginEnvironment.h"

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
                return;
            }
            else{//无效
                isLoading = NO;
            }
        }];
        
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
        isLoading = NO;
    }
    
}

/** 发送验证码
 */
- (void)sendVerifyCodeRequest:(NSDictionary*)params Successed:(void (^)(NSDictionary* resultDic))method {
    NSString* type       = [params objectForKey:@"type"];
    NSString* phone      = [params objectForKey:@"phone"];
    NSString* sendMethod = [params objectForKey:@"sendMethod"];//语音验证码 2017.7 wangshun
    
    NSDictionary* dic = @{@"type":type,@"mobileNo":phone};
    if (sendMethod) {
        dic = @{@"type":type,@"mobileNo":phone,@"sendMethod":sendMethod};
    }

    if([SNNewsPPLoginEnvironment isPPLogin] && ![sendMethod isEqualToString:@"1"]){//开关 如果是语音验证走老接口 跟安卓一样 wangshun
        NSString* pvcode = [params objectForKey:@"pvcode"]?:@"";//图片验证码
        
        NSDictionary* ppdic = @{@"type":type,@"mobileNo":phone,@"captcha":pvcode};
        if (sendMethod) {
            ppdic = @{@"type":type,@"mobileNo":phone,@"sendMethod":sendMethod,@"captcha":pvcode};
        }
        
        [SNNewsPPLogin sendVcode:ppdic WithResult:^(NSDictionary *info) {
            //params为了拿sendMethod
            [self analysePPLoginParams:params Response:info Successed:method];
        }];
        
        return;
    }
    
    [[[SNSendVerifyCodeRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {

        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        
        NSDictionary* re_dic = nil;
        NSString* sendMethod = [params objectForKey:@"sendMethod"];
        if (statusCode.integerValue == 10000000) {//成功
            if ([sendMethod isEqualToString:@"1"]) {//如果是语音验证不弹出toast, 后面会弹的
                
            }
            else{
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            
            if (method) {
                isLoading = NO;
                re_dic = @{@"success":@"1",@"resp":responseObject};
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
        else{
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

- (void)analysePPLoginParams:(NSDictionary*)params Response:(NSDictionary*)responseObject Successed:(void (^)(NSDictionary* resultDic))method{
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        NSString* success = [responseObject objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {
            
            NSDictionary* resp = [responseObject objectForKey:@"resp"];
            if (resp && [resp isKindOfClass:[NSDictionary class]]) {
                NSNumber* statusCode = [resp objectForKey:@"status"];
                if (statusCode.integerValue == 200) {
                    NSString* sendMethod = [params objectForKey:@"sendMethod"];//语音验证码 2017.7 wangshun
                    if ([sendMethod isEqualToString:@"1"]) {
                        
                    }
                    else{
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeOnlyText];
                    }
                    isLoading = NO;
                    if (method) {
                        method(@{@"success":@"1"});
                        return;
                    }
                }
                else if (statusCode.integerValue == 40201){//发送达到上限
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"操作频繁，稍后再试" toUrl:nil mode:SNCenterToastModeOnlyText];
                    isLoading = NO;
                    if (method) {
                        method(@{@"success":@"40201"});
                        return;
                    }
                }
                else if (statusCode.integerValue == 40108){
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"验证码发送太频繁，请进行图形安全验证" toUrl:nil mode:SNCenterToastModeOnlyText];
                    isLoading = NO;
                    if (method) {
                        method(@{@"success":@"40108"});
                        return;
                    }
                }
                else if (statusCode.integerValue == 40105){
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"图形验证码输入错误，请重新验证" toUrl:nil mode:SNCenterToastModeOnlyText];
                    isLoading = NO;
                    if (method) {
                        method(@{@"success":@"40105"});
                        return;
                    }
                }
                else if (statusCode.integerValue == 40109){
//                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"出于安全考虑，请进行语音验证" toUrl:nil mode:SNCenterToastModeOnlyText];
                    isLoading = NO;
                    if (method) {
                        method(@{@"success":@"40109"});
                        return;
                    }
                }
                else{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送失败" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            
            isLoading = NO;
            if (method) {
                NSDictionary* re_dic = @{@"success":@"0"};
                method(re_dic);
            }
        }
        else if ([success isEqualToString:@"-2"]) {//网络失败
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            isLoading = NO;
            if (method) {
                NSDictionary* re_dic = @{@"success":@"-2"};
                method(re_dic);
            }
        }
        else{
            isLoading = NO;
            if (method) {
                NSDictionary* re_dic = @{@"success":@"0"};
                method(re_dic);
            }
        }
    }
}

@end
