//
//  SNWeiboHelper.m
//  sohunews
//
//  Created by wang shun on 2017/2/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWeiboHelper.h"
#import "SNSSOSinaWrapper.h"
#import "SNH5NewsBindWeibo.h"

@implementation SNWeiboHelper

- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([SNSSOSinaWrapper sharedInstance].isCommentBindWeibo ==YES) {//绑定微博回调
        if (self.bindWeibo) {
            [self.bindWeibo didReceiveWeiboResponse:response];
        }
    }
    else if ([SNSSOSinaWrapper sharedInstance].isSinaWebOpen ==YES) {//登录回调
        [[SNSSOSinaWrapper sharedInstance] didReceiveWeiboResponse:response];
    }
    else{//分享回调
        [self.shareWeibo didReceiveWeiboResponse:response];
    }
    [SNSSOSinaWrapper sharedInstance].isCommentBindWeibo = NO;
}

+ (SNWeiboHelper *)sharedInstance {
    static SNWeiboHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNWeiboHelper alloc] init];
    });
    
    return _instance;
}

@end
