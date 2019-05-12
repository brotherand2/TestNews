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

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginThirdAnalyse.h"
#import "SNNewsPPLoginEnvironment.h"

#import "SNSLib.h"

@interface SNBindPhoneViewModel ()
{
    BOOL isLoading;
    
    NSString* entrance;
    NSString* onlybind;
}
@property (nonatomic,strong) SNValidateMobileNumModel* isValidateMobile;
@property (nonatomic,strong) NSDictionary* thirdDic;
@property (nonatomic,copy)   void (^successed_method)(NSDictionary *resultDic);

@end

@implementation SNBindPhoneViewModel

-(instancetype)init{
    if (self = [super init]) {
        self.isValidateMobile = [[SNValidateMobileNumModel alloc] init];
    }
    return self;
}

-(BOOL)isBinding{
    return isLoading;
}

- (void)bindPhone:(NSDictionary *)params ThirdData:(NSDictionary*)thirdData Successed:(void (^)(NSDictionary *))method{
    if (isLoading == YES) {
        return;
    }
    isLoading = YES;
    
    if (thirdData) {
        self.thirdDic = thirdData;
    }
    
    if ([params objectForKey:@"entrance"]) {
        entrance = [params objectForKey:@"entrance"];
    }
    
    if ([params objectForKey:@"bindSuccessModel"]) {
        onlybind = @"1";
    }
    
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
                    
                    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:params];
                    [dic removeObjectForKey:@"bindSuccessModel"];//仅绑定页
                    [weakSelf bindPhoneRequest:dic Success:method];
                    return ;
                }
                else{//无效
                    isLoading = NO;
                }
            }];
            return;
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
            isLoading = NO;
        }
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
        isLoading = NO;
    }
    
}

- (void)bindPhoneRequest:(NSDictionary*)params Success:(void (^)(NSDictionary *resultDic))method{
    if (method) {
       self.successed_method = method;
    }

    
    if ([SNNewsPPLoginEnvironment isPPLogin] && ![onlybind isEqualToString:@"1"]){
        NSString* mobile = [params objectForKey:@"phone"];//手机号
        NSString* smCode = [params objectForKey:@"vcode"];//验证码
        
        NSMutableDictionary* pp_mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [pp_mDic setDictionary:self.thirdDic];
        
        [pp_mDic setObject:mobile?:@"" forKey:@"mobile"];
        [pp_mDic setObject:smCode?:@"" forKey:@"mcode"];
        
        NSString* pp_bind = [params objectForKey:@"pp_bind"];
        if ([pp_bind isEqualToString:@"pp_third"]) {
            [SNNewsPPLogin thirdLogin:pp_mDic WithResult:^(NSDictionary *info) {
                [self thirdAnalysePPLoginParams:pp_mDic Response:info];
            }];
        }
        else if ([pp_bind isEqualToString:@"pp_sohu"]) {
            [SNNewsPPLogin sohuLogin:pp_mDic WithResult:^(NSDictionary *info) {
                [self sohuPPLoginParams:pp_mDic Response:info];
            }];
        }
        return;
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
    
    NSString* mobile = [thirdParams objectForKey:@"phone"];//手机号
    NSString* smCode = [thirdParams objectForKey:@"vcode"];//验证码
    NSString* passport = [thirdParams objectForKey:@"passport"];//验证码
    
    NSMutableDictionary* postDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [postDic setObject:mobile?:@"" forKey:@"mobile"];
    [postDic setObject:smCode?:@"" forKey:@"smCode"];
    [postDic setObject:passport?:@"" forKey:@"passport"];
    
    SNDebugLog(@"third bind::::%@",postDic);
    
    [[[SNThirdBindMobileRequest alloc] initWithDictionary:postDic] send:^(SNBaseRequest *request, id responseObject) {
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
            
            [self burySuccess:@"1"];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            //绑定是不返回值的 因为已经拿到
            [self performSelector:@selector(bindSuccessed:) withObject:nil afterDelay:1.8];
            
            if (mobile) {
                NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:mobile, @"phone", nil];
                [SNSLib bindPhoneWith:dictInfo];
            }
            
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
            if ([statusMsg isEqualToString:@"登录失败"]) {
                statusMsg = @"绑定失败";
            }
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        isLoading = NO;
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        isLoading = NO;
    }];
}


#pragma mark - 注册

- (void)thirdSignup:(NSDictionary*)thirdParams{

    NSString* mobile = [thirdParams objectForKey:@"phone"];//手机号
    NSString* smCode = [thirdParams objectForKey:@"vcode"];//验证码
    
    //注册一定是第三方
    NSMutableDictionary* postDic = [[NSMutableDictionary alloc] initWithDictionary:self.thirdDic];
    
    [postDic setObject:mobile?:@"" forKey:@"mobile"];
    [postDic setObject:smCode?:@"" forKey:@"smCode"];
    
    if ([postDic objectForKey:@"type"]) {
        [postDic removeObjectForKey:@"type"];
    }
    
    SNDebugLog(@"third register::::%@",postDic);
    
    [[[SNThirdRegisterPassportRequest alloc] initWithDictionary:postDic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSString* passport = [responseObject objectForKey:@"passport"];
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg = [responseObject objectForKey:@"statusMsg"];
        if (statusCode.integerValue == 10000000) {
            SNDebugLog(@"成功");
            if ([statusMsg isEqualToString:@"登录成功"]) {
                statusMsg = @"绑定成功";
            }
            [self burySuccess:@"1"];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            //注册必须返回值的 因为没有用户信息
            [self performSelector:@selector(registerSuccessed:) withObject:responseObject afterDelay:1.8];
            
            if (mobile) {
                NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:mobile, @"phone", nil];
                [SNSLib bindPhoneWith:dictInfo];
            }

            return;
        }
        else{
            if ([statusMsg isEqualToString:@"登录失败"]) {
                statusMsg = @"绑定失败";
            }
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        isLoading = NO;
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        isLoading = NO;
    }];
}

- (void)autoThirdSignup:(NSDictionary *)thirdParams Successed:(void (^)(NSDictionary *))method{
    if (method) {
       self.successed_method = method;
    }
    
    [[[SNThirdRegisterPassportRequest alloc] initWithDictionary:thirdParams] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSString* passport = [responseObject objectForKey:@"passport"];
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg = [responseObject objectForKey:@"statusMsg"];
        if (statusCode.integerValue == 10000000) {
            SNDebugLog(@"成功");
            if ([statusMsg isEqualToString:@"登录成功"]) {
               //这个地方不弹窗 
            }
            //注册必须返回值的 因为没有用户信息
            [self performSelector:@selector(registerSuccessed:) withObject:responseObject afterDelay:1.8];
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
        NSDictionary* success = @{@"success":@"1"};
        self.successed_method(success);
    }
    isLoading = NO;
}

//注册
- (void)registerSuccessed:(NSDictionary*)resp_Dic{
    if (self.successed_method) {
        NSDictionary* success = @{@"success":@"1",@"resp":resp_Dic};
        self.successed_method(success);
    }
    isLoading = NO;
}


- (void)thirdAnalysePPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info{
    [SNNewsPPLoginThirdAnalyse analysePPLoginParams:params Response:info Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//登录成功
                if (self.successed_method) {
                    NSDictionary* success = @{@"success":@"1"};
                    self.successed_method(success);
                    [self burySuccess:@"1"];
                    return;
                }
            }
            
        }
        
        isLoading = NO;
    }];
}

- (void)sohuPPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info{
    [SNNewsPPLoginThirdAnalyse sohuPPLoginParams:params Response:info Successed:^(NSDictionary *resultDic) {
        NSString* success = [resultDic objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {//登录成功
            if (self.successed_method) {
                NSDictionary* success = @{@"success":@"1"};
                self.successed_method(success);
                [self burySuccess:@"1"];
                return;
            }
            
        }
        
        isLoading = NO;
    }];
}

- (void)burySuccess:(NSString*)str{
    if ([str isEqualToString:@"1"]) {
        NSString* agif = @"_act=connect_phone&_tp=clk";
        if (entrance) {
            agif = [agif stringByAppendingFormat:@"&entrance=%@",entrance];
        }
        [SNNewsReport reportADotGif:agif];
        SNDebugLog(@"login agif::::%@",agif);
    }
}

@end
