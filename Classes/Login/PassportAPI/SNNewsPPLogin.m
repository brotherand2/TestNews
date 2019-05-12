//
//  SNNewsPPLogin.m
//  sohunews
//
//  Created by wang shun on 2017/10/30.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLogin.h"

#import "SNNewsPPLoginWebView.h"
#import "SNNewsPPLoginRequestList.h"
#import "SNNewsPPLoginEnvironment.h"
#import "SNNewsPPLoginSynchronize.h"

#import "SNSLib.h"

static SNNewsPPLogin* _instance = nil;

@interface SNNewsPPLogin ()<SNNewsPPLoginWebViewDelegate>

@property (nonatomic,strong) SNNewsPPLoginWebView* ppWeb;//这不是个webView
@property (nonatomic,strong) SNNewsPPLoginCookie* cookie;//
@property (nonatomic,strong) NSString* photoCtime;//图片验证码时间戳


@property (nonatomic,copy) void (^ppjvCallBack)(NSString*);

@end

@implementation SNNewsPPLogin

/***************************************************/

//手机号登录
+ (void)mobileVcodeLogin:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method{
        
        [SNNewsPPLogin loadPPJV:^(NSString *jv) {
            
            if ([jv isEqualToString:@"-2"]) {
                if (method) {
                    method(@{@"success":@"-2"});
                    return;
                }
            }
            
            NSString* mobile = [params objectForKey:@"mobileNo"];
            NSString* vcode = [params objectForKey:@"captcha"];
            
            NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [mDic setObject:mobile forKey:@"mobile"];
            [mDic setObject:vcode forKey:@"mcode"];
            
            [[[SNNewsPPMobileVcodeLoginRequest alloc] initWithDictionary:mDic PPJV:jv] send:^(SNBaseRequest *request, id responseObject) {
                SNDebugLog(@"pp Url::%@",request.url);
                SNDebugLog(@"resp:::%@",responseObject);
                
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    if (method) {
                        method(@{@"success":@"1", @"resp":responseObject});
                        return;
                    }
                }
                
                if (method) {
                    method(@{@"success":@"0"});
                }
                
            } failure:^(SNBaseRequest *request, NSError *error) {
                SNDebugLog(@"err:::%@",error);
                if (method) {
                    method(@{@"success":@"-2"});
                }
            }];
        }];
    
}

+ (void)thirdLogin:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method{
    [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
        [[[SNNewsPPThirdLoginRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
            SNDebugLog(@"pp Url::%@",request.url);
            SNDebugLog(@"resp::%@",responseObject);
            [[SNCenterToast shareInstance] hideToast];
            if (responseObject) {
                NSNumber* status = [responseObject objectForKey:@"status"];
                if(method){
                   method(@{@"success":@"1",@"resp":responseObject});
                }
            }
            else{
                if(method){
                   method(@{@"success":@"0"});
                }
            }
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"err:::%@",error);
            if(method){
               method(@{@"success":@"-2"});
            }
            [[SNCenterToast shareInstance] hideToast];
        }];
    }];
}

+ (void)sohuLogin:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method{
    
    [SNNewsPPLogin loadPPJV:^(NSString * jv) {
        if ([jv isEqualToString:@"-2"]) {
            if (method) {
                method(@{@"success":@"-2"});
                return;
            }
        }
        
        NSString* account     = [params objectForKey:@"account"];
        NSString* password    = [params objectForKey:@"password"];
        NSString* captcha     = [params objectForKey:@"captcha"];
        
        NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [mDic setObject:account forKey:@"acc"];
        [mDic setObject:password forKey:@"pwd"];
        if (captcha) {
            [mDic setObject:captcha forKey:@"captcha"];
            if ([SNNewsPPLogin sharedInstance].photoCtime) {
                [mDic setObject:[SNNewsPPLogin sharedInstance].photoCtime forKey:@"ctoken"];
            }
        }
        
        
        [[[SNNewsPPLoginSohuRequest alloc] initWithDictionary:mDic PPJV:jv] send:^(SNBaseRequest *request, id responseObject) {
            SNDebugLog(@"pp Url::%@",request.url);
            SNDebugLog(@"resp:%@",responseObject);
            
            NSMutableDictionary* re_dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if (method) {
                    method(@{@"success":@"1",@"resp":responseObject});
                    return;
                }
            }
            
            if (method) {
                method(@{@"success":@"0"});
                return;
            }
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            if (method) {
                method(@{@"success":@"-2"});
                return;
            }
        }];
    }];
}


/***************************************************/

#pragma mark - 发送验证码
//发送验证码

+ (void)sendVcode:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method{
    
    [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
        
        NSString* mobile   = [params objectForKey:@"mobileNo"];
        NSString* type     = [params objectForKey:@"type"];
        NSString* voice    = [params objectForKey:@"sendMethod"];
        NSString* captcha  = [params objectForKey:@"captcha"];
        
        NSNumber* v = [NSNumber numberWithBool:NO];
        if ([voice isEqualToString:@"1"]) {
            v = [NSNumber numberWithBool:YES];
        }
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dic setObject:mobile forKey:@"mobile"];
        [dic setObject:type forKey:@"biz"];
        [dic setObject:v forKey:@"voice"];
        [dic setObject:captcha forKey:@"captcha"];
        
        if ([SNNewsPPLogin sharedInstance].photoCtime) {
            [dic setObject:[SNNewsPPLogin sharedInstance].photoCtime forKey:@"ctoken"];
        }
        
        [[[SNNewsPPLoginSendVcodeRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
            SNDebugLog(@"pp Url::%@",request.url);
            SNDebugLog(@"resq::::%@",responseObject);
            
            NSMutableDictionary* re_dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                
                if (method) {
                    method(@{@"success":@"1",@"resp":responseObject});
                    return;
                }
            }
            else{
                if (method) {
                    method(@{@"success":@"0"});
                }
            }
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"err::::%@",error);
            
            if (method) {
                method(@{@"success":@"-2"});
            }
        }];
        
    }];
    
}

/***************************************************/

+ (void)setCookie:(NSDictionary*)params WithResult:(void (^)(NSDictionary* info))method{
    
    SNUserinfoEx *aUserInfo = [SNUserinfoEx userinfoEx];
    NSString* token    = [aUserInfo token];
    NSString* passport = [aUserInfo passport];
    NSString* pp_GID   = [params objectForKey:@"PP-GID"];
    
    NSDictionary* dic = @{@"passport":passport,@"appSessionToken":token};
    
    [[[SNNewsPPLoginSetCookieRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"SNNewsPPLoginSetCookieRequest:::%@",request.url);
        SNDebugLog(@"responseObject:%@",responseObject);
        
        if (responseObject) {
            NSNumber* status = [responseObject objectForKey:@"status"];
            if (status.integerValue == 200) {
                NSDictionary* data = [responseObject objectForKey:@"data"];
                [SNNewsPPLogin sharedInstance].cookie.pp_GID = pp_GID;
                [SNNewsPPLogin sharedInstance].cookie.pp_token = token;
                [[SNNewsPPLogin sharedInstance].cookie setCookieData:data];
            }
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"err:::%@",error);
        if (method) {
            method(@{@"success":@"-2"});
        }
    }];
}
/***************************************************/

#pragma mark - Photo Vcode

+ (void)getPhotoVcode:(NSDictionary*)params WithSuccess:(void (^)(UIImage*))method{
    //时间戳 单位：ms
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* timestamp = [NSString stringWithFormat:@"%0.f",interval* 1000];
    NSDictionary* dic = @{@"ctoken":timestamp?:@""};
    
    [SNNewsPPLogin sharedInstance].photoCtime = timestamp;
    
    [[[SNNewsPPLoginGetPhotoVcodeRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"pp Url::%@",request.url);
        SNDebugLog(@"resp::::%@",responseObject);
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary* resp = (NSDictionary*)responseObject;
            NSNumber* status = [resp objectForKey:@"status"];
            if (status.integerValue == 200) {
                NSDictionary* data = [resp objectForKey:@"data"];
                if (data) {
                    NSString* content = [data objectForKey:@"content"];
                    
                    NSData *_decodedImageData   = [[NSData alloc] initWithBase64Encoding:content];
                    UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];
                    
                    if(method){
                       method(_decodedImage);
                    }
                }
            }
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"err:::%@",error);
    }];
}


/***************************************************/

#pragma mark - PP-GID

- (void)getGID:(void (^)(NSString*))method{
    
    NSString* pp_gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
    if (pp_gid && pp_gid.length>0) {
        if (method) {
            NSDictionary* dic = @{@"gid":pp_gid};
            [SNSLib updatePassportInfo:dic];
            method(pp_gid);
        }
    }
    else{
        
        [[[SNNewsPPGIDRequest alloc] initWithDictionary:nil] send:^(SNBaseRequest *request, id responseObject) {
            SNDebugLog(@"pp Url::%@",request.url);
            SNDebugLog(@"SNNewsPPGIDRequest resq:%@",responseObject);
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSNumber* status = [responseObject objectForKey:@"status"];
                if (status.integerValue == 200) {
                    NSDictionary* data = [responseObject objectForKey:@"data"];
                    NSString* gid = [data objectForKey:@"gid"];
                    if (gid && gid.length>0) {
                        [[NSUserDefaults standardUserDefaults] setObject:gid forKey:SNNewsLogin_PP_GID];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSDictionary* dic = @{@"gid":gid};
                        [SNSLib updatePassportInfo:dic];
                        
                        if (method) {
                            method(pp_gid);
                        }
                    }
                }
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            NSLog(@"err:%@",error);
            if (method) {
                method(@"-2");
            }
        }];
        
    }
}

#pragma mark - PP-JV

- (void)getPPJV:(NSString *)ppjv{
    SNDebugLog(@"ppjv:::%@",ppjv);
    if (self.ppjvCallBack) {
        self.ppjvCallBack(ppjv);
    }
}

-(void)loadFailed:(id)sender{
    if (self.ppjvCallBack) {
        self.ppjvCallBack(@"-2");
    }
}

- (void)createCookie{
    if (!self.cookie) {
        self.cookie = [[SNNewsPPLoginCookie alloc] init];
    }
}

+ (void)loadPPJV:(void (^)(NSString*))method{
    if (method) {
        [SNNewsPPLogin sharedInstance].ppjvCallBack = nil;
        [SNNewsPPLogin sharedInstance].ppjvCallBack = method;
    }
    
    [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
        if ([gid isEqualToString:@"-2"]) {
            if (method) {
                method(@"-2");
            }
            return;
        }
        [[SNNewsPPLogin sharedInstance].ppWeb loadPPJV];
    }];
}



- (instancetype)init{
    if (self = [super init]) {
        self.ppWeb = [[SNNewsPPLoginWebView alloc] init];//先创建webView 拿UA
        self.ppWeb.delegate = self;
    }
    return self;
}



+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (NSString*)getUA{
    return [[SNNewsPPLogin sharedInstance].ppWeb getUA];
}

+ (BOOL)isPPLoginValid{
    return [SNNewsPPLoginEnvironment isPPLogin];
}


@end
