//
//  SNSSOWXWrapper.m
//  sohunews
//
//  Created by yangln on 15-3-13.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSSOWXWrapper.h"
#import "SNWeixinOauthRequest.h"

@implementation SNSSOWXWrapper

- (void)login {
    
    if (isINHOUSE) {
        [WXApi registerApp:kWX_APP_ID enableMTA:NO];
    }
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";//必须
    req.state = @"111111";//不必须
    [WXApi sendReq:req];
}

@end
