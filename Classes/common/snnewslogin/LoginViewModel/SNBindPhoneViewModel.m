//
//  SNBindPhoneViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBindPhoneViewModel.h"
#import "SNValidateMobileNumModel.h"

#import "SNThirdRegisterPassportRequest.h"
#import "SNThirdBindMobileRequest.h"

@interface SNBindPhoneViewModel ()
{
    BOOL isLoading;
}
@property (nonatomic,strong) SNValidateMobileNumModel* isValidateMobile;
@property (nonatomic,copy)   void (^successed_method)(NSDictionary *resultDic);

@end

@implementation SNBindPhoneViewModel

-(instancetype)init{
    if (self = [super init]) {
        self.isValidateMobile = [[SNValidateMobileNumModel alloc] init];
    }
    return self;
}

- (void)bindPhone:(NSDictionary *)params Successed:(void (^)(NSDictionary *))method{
    if (isLoading == YES) {
        return;
    }
    isLoading = YES;
    
    NSString* phone = [params objectForKey:@"phone"];
    if (phone && phone.length>0) {
        NSString* vcode = [params objectForKey:@"vcode"];
        if (vcode && vcode.length>0) {//发起绑定
            __weak SNBindPhoneViewModel* weakSelf = self;
            //验证手机号有效
            [self.isValidateMobile isValidateMobileNum:phone Successed:^(NSDictionary *resultDic) {
                
                //手机号有效则 绑定
                NSString* success = [resultDic objectForKey:@"success"];
                if ([success isEqualToString:@"1"]) {
                    [weakSelf bindPhoneRequest:params Success:method];
                    return ;
                }
                else{//无效
                    
                }
            }];
            
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    isLoading = NO;

}

- (void)bindPhoneRequest:(NSDictionary*)params Success:(void (^)(NSDictionary *resultDic))method{
    if (method) {
       self.successed_method = method;
    }
    
    NSString* type = [params objectForKey:@"type"];
    if ([type isEqualToString:@"bind"]) {//绑定逻辑包括老用户评论绑定/第三方登录绑定/搜狐passport绑定
        [self thirdBind:params];
    }
    else if ([type isEqualToString:@"signup"]){//注册仅仅用于第三方登录
        [self thirdSignup:params];
    }
}

#pragma mark - 绑定

- (void)thirdBind:(NSDictionary*)thirdParams{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:thirdParams];
    
    //去掉原来的参数
    [params removeObjectForKey:@"type"];
    
    SNDebugLog(@"third bind::::%@",params);
    
    [[[SNThirdBindMobileRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        if (statusCode.integerValue == 10000000){//成功
            
            if ([statusMsg isEqualToString:@"登录成功，该手机号也绑定了其他登录方式哦！"]) {
                statusMsg = @"绑定成功，该手机号也绑定了其他登录方式哦！";
            }
            
            if ([statusMsg isEqualToString:@"登录成功"]) {
                statusMsg = @"绑定成功";
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            //绑定是不返回值的 因为已经拿到
            [self performSelector:@selector(bindSuccessed:) withObject:nil afterDelay:1.8];
            return ;
        }
        else if (statusCode.integerValue == 10000010){//验证码输入有误
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else if (statusCode.integerValue == 10000011){//该验证码已失效，请重新获取验证码

            //验证码输对了也不一定能过 所以要重置 passport 验证码只能用一次
            if (self.delegate && [self.delegate respondsToSelector:@selector(resetPhoneViewText:)]) {
                [self.delegate resetPhoneViewText:nil];
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else if (statusCode.integerValue == 10000012){//手机号绑定失败，已达安全手机绑定上限
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        isLoading = NO;
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        isLoading = NO;
    }];
}


#pragma mark - 注册

- (void)thirdSignup:(NSDictionary*)thirdParams{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:thirdParams];
    
//    [params setValue:self.loginFrom forKey:@"loginfrom"];
//    [params setValue:kLoginTypeMobileNum forKey:@"logintype"];
    
    //去掉原来的参数
    [params removeObjectForKey:@"type"];
    
    
    SNDebugLog(@"third register::::%@",params);
    
    [[[SNThirdRegisterPassportRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSString* passport = [responseObject objectForKey:@"passport"];
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg = [responseObject objectForKey:@"statusMsg"];
        if (statusCode.integerValue == 10000000) {
            SNDebugLog(@"成功");
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            //注册必须返回值的 因为没有
            [self performSelector:@selector(registerSuccessed:) withObject:responseObject afterDelay:2.5];
            return;
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        isLoading = NO;
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        isLoading = NO;
    }];
}

#pragma mark - 绑定成功/注册成功
//绑定
- (void)bindSuccessed:(NSDictionary*)resp_Dic{
    if (self.successed_method) {
        self.successed_method(resp_Dic);
    }
    isLoading = NO;
}

//注册
- (void)registerSuccessed:(NSDictionary*)resp_Dic{
    if (self.successed_method) {
        self.successed_method(resp_Dic);
    }
    isLoading = NO;
}

@end
