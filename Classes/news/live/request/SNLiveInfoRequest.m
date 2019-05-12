//
//  SNLiveInfoRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveInfoRequest.h"
#import "SNUserManager.h"
#import "SNAdManager.h"

@implementation SNLiveInfoRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_Info;
}

- (id)sn_parameters {

    [self.parametersDict setValue:@"1" forKey:@"showSdkAd"];
    NSString *passport = [SNUserManager getUserId];
    if (passport.length > 0) {
        [self.parametersDict setValue:passport forKey:@"passport"];
    }
    [self.parametersDict setValuesForKeysWithDictionary:[SNAdManager addAdParameters]];

    return [super sn_parameters];
}
@end
