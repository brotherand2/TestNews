//
//  SNOpenLoginLinkRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNOpenLoginLinkRequest.h"

@implementation SNOpenLoginLinkRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Login_OpenLoginLink;
}

- (id)sn_parameters {
    //    ?version=1.0
    [self.parametersDict setValue:@"1.0" forKey:@"version"];
    
    return [super sn_parameters];
}

//lijian 20170925 强制切https
- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}

@end
