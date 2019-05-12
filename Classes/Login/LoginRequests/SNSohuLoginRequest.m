//
//  SNSohuLoginRequest.m
//  sohunews
//
//  Created by wang shun on 2017/3/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuLoginRequest.h"

@implementation SNSohuLoginRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Login_sohuLogin;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

//lijian 20170925 强制切https
- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}


@end
