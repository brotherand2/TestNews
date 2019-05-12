//
//  SNUpgradeRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUpgradeRequest.h"
#import "SNClientRegister.h"

@implementation SNUpgradeRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeHTTP;
}

- (CGFloat)sn_timeoutInterval {
    return 10.0;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Upgrade;
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_ResponseHttpManager;
}

- (id)sn_parameters {
    
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    
    if (appBuild) {
        [self.parametersDict setValue:appBuild forKey:@"buildCode"];
    }
    
    return [super sn_parameters];
}

@end
