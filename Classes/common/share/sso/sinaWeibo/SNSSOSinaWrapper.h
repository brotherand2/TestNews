//
//  SNSSOSinaWrapper.h
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSSOWrapper.h"
#import "SinaWeibo.h"
#import "WeiboSDK.h"

#import "SNThirdLoginSuccess.h"

#define kSinaAppKey             @"3651065292"
#define kSinaAppSecret          @"4044dcec48356f896919cd5ff46d2217"

@interface SNSSOSinaWrapper : SNSSOWrapper<SinaWeiboDelegate, WeiboSDKDelegate, WBHttpRequestDelegate> {
    SinaWeibo *_sinaWeibo;
}
@property (nonatomic, assign) BOOL isSinaWebOpen;
@property (nonatomic, assign) BOOL isCommentBindWeibo;


@property (nonatomic, strong) SNThirdLoginSuccess* thirdLoginSuccess;
@property (nonatomic,strong) NSDictionary* userInfoDic;//绑定之前已经拿到的userinfo

+ (SNSSOSinaWrapper *)sharedInstance;
+ (BOOL)sinaSDKRegister;

+ (BOOL)isHaveToken;

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;

@end
