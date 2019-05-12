//
//  SNShareSyncTokeyRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareSyncTokeyRequest.h"
#import "SNUserManager.h"

@implementation SNShareSyncTokeyRequest


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Share_SyncToken;
}

- (id)sn_parameters {
    // from
    NSString *fromStr = [[NSUserDefaults standardUserDefaults] stringForKey:kSSOLoginTypeKey];
    if ([fromStr length] > 0) {
        [self.parametersDict setValue:fromStr forKey:@"from"];
    }
    [self.parametersDict setValue:[SNUserManager getUserId] forKey:@"mainPassport"];

    [self.parametersDict setValue:@"1.0" forKey:@"version"];
    
    self.needNetSafeParameters = YES;
    
    return [super sn_parameters];
}

@end
