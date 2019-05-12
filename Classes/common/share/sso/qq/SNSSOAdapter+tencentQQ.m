//
//  SNSSOAdapter+tencentQQ.m
//  sohunews
//
//  Created by jojo on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSSOAdapter+tencentQQ.h"
#import "SNSSOQQWrapper.h"
#import "SNQQHelper.h"

@implementation SNSSOAdapter (tencentQQ)

- (BOOL)isSupportFor_80 {
    return [SNQQHelper isSupportQQSSO];
}

- (void)loginFor_80 {
    self.ssoClient = [[SNSSOQQWrapper alloc] init];
    self.ssoClient.delegate = self;
    [self.ssoClient login];
}

@end
