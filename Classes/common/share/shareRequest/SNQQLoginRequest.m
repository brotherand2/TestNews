//
//  SNQQLoginRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNQQLoginRequest.h"

@implementation SNQQLoginRequest


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Share_QQSyncToken;
}

- (id)sn_parameters {

    [self.parametersDict setValue:@"3.0" forKey:@"version"];
    // from
    NSString *fromStr = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
    if ([fromStr length] > 0) {
        [self.parametersDict setValue:fromStr forKey:@"from"];
    }
    self.needNetSafeParameters = YES;
    
    return [super sn_parameters];
}

@end
