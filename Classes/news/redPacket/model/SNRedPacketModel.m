//
//  SNRedPacketModel.m
//  sohunews
//
//  Created by cuiliangliang on 16/3/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRedPacketModel.h"
#import "SNUserManager.h"
#import "JSONKit.h"
#import "SNBindAlipayRequest.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
#import "SNWithDrawRequest.h"
#import "SNNewsLoginManager.h"

/*
 企业版：
 pid: 2088221384467458
 appid: 2016031201205554
 正式版：
 appid：2016031101203522
 pid:
 
 */


/*============================================================================*/
/*=======================需要填写商户app申请的===================================*/
/*============================================================================*/
#define kAPAuthappID   @"2016031101203667"
#define kAPTargetID   @"2016031123587765"
#define kAPprivateKey   @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBANN4h7zVqPxZGDn4w8kEB+OILILQfxJtXAkM1vkTO8eS47SLBqHhR1MlgQ01XTmpPuCZ3McADAdZtSMig8KxDa7cCddKlAR1CTlriDuWfo3iv3NBcarWuaecKD4qReWICZrPRNp5tOEMnMDA0YQkCdPnwp4MUA5BiNiIIEZUa5sRAgMBAAECgYBzdzRmXyNN5jfcL4B3mcPU8N2c78ryfNPr/R7EEURqzEGYqvCMIz2WoLu+Qo0MluTGLjzmS5hFyy2kaYwYGiSlfprYaT+0qwOR2pqD+8dijwmIs/mwFjmyBCHt2896wvdCZijV2DJHsuTT3OS9g7BQrzEtK/5N+UVMMUrEbL2WIQJBAPsrDc5a3EfMa4/YOfYctJa7ECdVV9uvsxFbiDa9Ff70OVB9b2y2RRRVC5foJqxcYMOTwMS1uapk49zzV8itENcCQQDXifnRNl4R757E4LicPMYxUU8lT6HnkTGCllNp2kMvNuFth2dhaUp9xUi/4tLKZMpskY8QO/9f400o7BqeRe5XAkEA1TMwnu9FeLSuwQVb/etT53aWOa0ZzOMRbzRxJXXPzADm/cnb4T2+2YlvM9zdpwUrJhivUsqm9Vp6iT0OUMuHNQJAMuDA9Z+tyPIVOkgJi+fUqOOWmSoY/76IP1kYy43X+hcsU1x5DMd77ABb0d/K/jeYiNQ7PwvKlmnjVtuU1POQ9QJACZqdEWQatR87O3kjpObd7IQnpFP3eBR6oeRhFdMHXm+J0Sz8M/LwivwdrcvNROMGm4TOo6egTtz+38ZBi2JUCw=="


@implementation SNPackProfile


@end


@interface SNRedPacketModel ()
@property(nonatomic,copy)verifyCompletionBlock  _verifyCompletionBlock;
@end

@implementation SNRedPacketModel

+ (SNRedPacketModel *)sharedInstance{
    static SNRedPacketModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNRedPacketModel alloc] init];
    });
    return sharedInstance;
}

-(void)verifySendRedPacket:(verifyCompletionBlock)completionBlock{
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    self._verifyCompletionBlock = completionBlock;
    
    NSString *ish5page = @"0";
    if (self.isH5) {
        ish5page = @"1";
    }
    
    if (![SNUserManager isLogin]) {
        
        [SNNewsLoginManager phoneLoginData:nil Successed:nil];
        
//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//        NSValue* methodBack = [NSValue valueWithPointer:@selector(back)];
//
//        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self,@"delegate",method, @"method",methodBack, @"methodBack",ish5page,@"isFromH5",@"手机登录", @"headTitle", @"立即登录", @"buttonTitle",@"为了保证账号安全，需与手机绑定", @"staticTitle",nil];
//        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//        [[TTNavigator navigator] openURLAction:_urlAction];
    }else{
        /*
        BOOL isMobileBind = [SNUtility isBindMobile];
        if (!isMobileBind) {
            NSValue* method = [NSValue valueWithPointer:@selector(bindSuccess)];
            NSValue* methodBack = [NSValue valueWithPointer:@selector(back)];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self,@"delegate",method, @"method",methodBack,@"methodBack",ish5page,@"isFromH5",@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:_urlAction];
        }else{
            self._verifyCompletionBlock(YES,NO);
        }
        */
        [SNUtility checkIsBindMobileWithResult:^(BOOL isMobileBind) {
            if (!isMobileBind) {
//                NSValue* method = [NSValue valueWithPointer:@selector(bindSuccess)];
//                NSValue* methodBack = [NSValue valueWithPointer:@selector(back)];
//                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self,@"delegate",method, @"method",methodBack,@"methodBack",ish5page,@"isFromH5",@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle",@"1",@"commentBindOpen", nil];
//                TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//                [[TTNavigator navigator] openURLAction:_urlAction];
                
                [SNNewsLoginManager bindData:nil Successed:^(NSDictionary *info) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self bindSuccess];
                    });
                } Failed:^(NSDictionary *errorDic) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self back];
                    });
                }];
            } else {
                self._verifyCompletionBlock(YES,NO);
            }
        }];
    }
}

-(void)back{
    if (self.isH5) {
        self._verifyCompletionBlock(NO,YES);
    }
}

-(SNPackProfile*)packProfileWithP1:(NSString*)p1 withPackId:(NSString*)packId{
    // 此方法未调用

    return nil;
}

-(void)redPacketRequestWithPacketID:(NSString *)packetID requestFinish:(SNRedPacketRequestFinish)requestFinish requestFailure:(SNRedPacketRequestFailure)requestFailure {

    [[[SNWithDrawRequest alloc] initWithDictionary:@{@"packId":packetID}] send:^(SNBaseRequest *request, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if (dict) {
            NSString *statusCode = [dict stringValueForKey:@"statusCode" defaultValue:@""];
            NSString *statusMsg = dict[@"statusMsg"];
            NSDictionary *data = dict[@"data"];
            SNPackProfile *profile = [[SNPackProfile alloc] init];
            profile.statusCode = statusCode;
            profile.statusMsg = statusMsg;
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSString *withdrawFee = [data stringValueForKey:@"withdrawFee" defaultValue:@""];
                NSString *alipayPassport = data[@"alipayPassport"];
                NSString *withdrawTime = [data stringValueForKey:@"withdrawTime" defaultValue:@""];
                profile.withdrawFee = withdrawFee;
                profile.alipayPassport = alipayPassport;
                profile.withdrawTime = withdrawTime;
            }
            requestFinish(profile);
        }else{
            requestFailure(request.requestObject, nil);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        requestFailure(request.requestObject, error);
    }];
}

- (void)bindApalipayPassport:(NSString*)openid  withAuthCode:(NSString*)code andResult:(void(^)(id responseObject))result{
    NSString *alipayAppId = kAPAuthappID;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setValue:openid forKey:@"openid"];
    [params setValue:code forKey:@"code"];
    [params setValue:alipayAppId forKey:@"alipayAppId"];
    
    [[[SNBindAlipayRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        if (result) result(responseObject);
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (result) result(nil);
    }];

}

-(void)bindSuccess{
    self._verifyCompletionBlock(YES,NO);
}

-(void)loginSuccess{
     self._verifyCompletionBlock(YES,NO);
}

-(void)auth_V2:(authCompletionBlock)completionBlock{

    NSString *pid = kSNAPPID;
    NSString *appID = kAPAuthappID;
    NSString *privateKey = kAPprivateKey;
    
    // 生成 auth info 对象
    APAuthV2Info *authInfo = [APAuthV2Info new];
    authInfo.pid = pid;
    authInfo.appID = appID;
    authInfo.targetID = kAPTargetID;
    
    // auth type
    NSString *authType = [[NSUserDefaults standardUserDefaults] objectForKey:@"authType"];
    if (authType) {
        authInfo.authType = authType;
    }
    
    // 时间戳
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    authInfo.signDate = [formatter stringFromDate:[NSDate date]];
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"aliauthsohu";
    
    // 将授权信息拼接成字符串
    NSString *authInfoStr = [authInfo description];
    // 获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:authInfoStr];
    
    // 将签名成功字符串格式化为订单字符串,请严格按照该格式
    if (signedString.length > 0) {
        authInfoStr = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", authInfoStr, signedString, @"RSA"];
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfoStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSString *result = resultDic[@"result"];
            NSString *resultStatus = resultDic[@"resultStatus"];
            /*
            resultStatus:
            9000——认证成功   4000——认证失败   6001——用户取消
            */
            if (resultStatus && [resultStatus isEqualToString:@"9000"]) {
                completionBlock(YES, result);
            } else {
               completionBlock(NO, result);
            }
        }];
    } else {
        completionBlock(NO,nil);
    }
}
-(void)handleOpenURL:(NSURL*)url{
    
    if (self.authCompletion) {
        self.authCompletion(YES,url.absoluteString);
    }
    
  
}

+ (NSString *)getValueStringFromUrl:(NSString *)url forParam:(NSString *)param{
    NSString * str = nil;
    NSRange start = [url rangeOfString:[param stringByAppendingString:@"="]];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:set];
    return trimmedString;
}

+(NSString*)getPidByInfoStr:(NSString*)url{
    NSString * str = nil;
    NSRange start = [url rangeOfString:[@"alipay_open_id" stringByAppendingString:@"="]];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:set];
    return trimmedString;
}

+(NSString*)getErrorStringWithErrorCode:(NSString*)code{
    NSString *title = nil;
    if (code && [code isEqualToString:@"30060009"]) {
        title = RedPacketCode30060009;
    }
    if (code && [code isEqualToString:@"30060010"]) {
        title = RedPacketCode30060010;
    }
    if (code && [code isEqualToString:@"30060011"]) {
        title = RedPacketCode30060011;
    }
    if (code && [code isEqualToString:@"30060012"]) {
        title = RedPacketCode30060012;
    }
    if (code && [code isEqualToString:@"30060014"]) {
        title = RedPacketCode30060014;
    }
    if (code && [code isEqualToString:@"30060013"]) {
        title = RedPacketCode30060013;
    }
    if (code && [code isEqualToString:@"30060006"]) {
        title = RedPacketCode30060006;
    }
    if (code && [code isEqualToString:@"30060003"]) {
        title = RedPacketCode30060003;
    }
    if (code && [code isEqualToString:@"30060005"]) {
        title = RedPacketCode30060005;
    }
    if (code && [code isEqualToString:@"30060002"]) {
        title = RedPacketCode30060002;
    }
    if (code && [code isEqualToString:@"30060001"]) {
        title = RedPacketCode30060001;
    }
    if (nil == title) {
        title = RedPacketCopywriterNomal;
    }
    return title;
}

@end
