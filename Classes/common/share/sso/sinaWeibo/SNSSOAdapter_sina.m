//
//  SNSSOAdapter_sina.m
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSSOAdapter_sina.h"
#import "SinaWeiboConstants.h"
#import "SNSSOSinaWrapper.h"

@implementation SNSSOAdapter(sina)

- (BOOL)isSupportFor_1 {
//    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kSinaWeiboAppAuthURL_iPhone]];
    return YES;
}

- (void)loginFor_1 {
    self.ssoClient = [[SNSSOSinaWrapper alloc] init];
    self.ssoClient.delegate = self;
    [self.ssoClient login];
}

@end
