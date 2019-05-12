//
//  SNSSOAdapter+weixin.m
//  sohunews
//
//  Created by yangln on 15-3-13.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSSOAdapter+weixin.h"
#import "SNWXHelper.h"
#import "SNSSOWXWrapper.h"

@implementation SNSSOAdapter (weixin)

- (BOOL)isSupportFor_8 {
    return [WXApi isWXAppSupportApi];
}

- (void)loginFor_8 {
    self.ssoClient = [[SNSSOWXWrapper alloc] init];
    self.ssoClient.delegate = self;
    [self.ssoClient login];
}

@end
