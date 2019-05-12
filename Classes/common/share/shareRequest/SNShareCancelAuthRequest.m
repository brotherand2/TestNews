//
//  SNShareCancelAuthRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareCancelAuthRequest.h"
#import "SNUserManager.h"

@implementation SNShareCancelAuthRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Share_CancelAuth;
}

- (id)sn_parameters {
    [self.parametersDict setValue:[SNUserManager getUserId] forKey:@"mainPassport"];
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    [self.parametersDict setValue:appBuild forKey:@"buildCode"];
    return [super sn_parameters];
}
@end
