//
//  SNH5NewsBindWeibo.m
//  sohunews
//
//  Created by wang shun on 2017/6/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNH5NewsBindWeibo.h"

#import "SNWeiboHelper.h"
#import "SNSSOSinaWrapper.h"

@implementation SNH5NewsBindWeibo

/**绑定微博 正文评论*/
- (void)bindWeiBo:(id<SNH5NewsBindWeiboDelegate>)delegate_{
    [SNSSOSinaWrapper sharedInstance].isCommentBindWeibo = YES;
    WBAuthorizeRequest *wbRequest = [WBAuthorizeRequest request];
    wbRequest.redirectURI = SNLinks_Domain_ApiK;
    wbRequest.scope = @"all";
    wbRequest.userInfo = nil;
    [WeiboSDK sendRequest:wbRequest];
    
    if ([SNWeiboHelper sharedInstance].bindWeibo != nil) {
        [SNWeiboHelper sharedInstance].bindWeibo = nil;
    }
    [SNWeiboHelper sharedInstance].bindWeibo = self;
    
    self.delegate = delegate_;
}

/** 解绑
 */
+ (void)removeBindWeibo{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kSinaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNotBindWeibo{
    //YES:已绑定 NO:未绑定
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSinaAccessToken"];
    if (str && str.length>0) {
        return YES;
    }
    return NO;
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        
        SNDebugLog(@"statusCode:%d",response.statusCode);
        
        if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            return;
        }
        
        NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
        
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"kSinaAccessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (accessToken && accessToken.length>0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bindWeiboSuccess:)]) {
                [self.delegate bindWeiboSuccess:nil];
            }
        }
    }
    
    [SNSSOSinaWrapper sharedInstance].isCommentBindWeibo = NO;
}

@end
