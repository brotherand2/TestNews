//
//  SNIsBindMobileRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNIsBindMobileRequest.h"

@implementation SNIsBindMobileRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_IsBindMobile;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

//lijian 20170925 强制切https
- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}

@end
