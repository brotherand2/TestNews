//
//  SNCheckTokenRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCheckTokenRequest.h"

@implementation SNCheckTokenRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Login_CheckToken_V3;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

//lijian 20170925 强制切https
- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}

@end
