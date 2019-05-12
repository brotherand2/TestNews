//
//  SNMobileSmsLoginRequest.m
//  sohunews
//
//  Created by wang shun on 2017/4/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNMobileSmsLoginRequest.h"

@implementation SNMobileSmsLoginRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return NSLinks_Path_Login_MobileSmsLogin;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

@end
