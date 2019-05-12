//
//  SNUserRegistRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserRegistRequest.h"
#import "SNClientRegister.h"

@implementation SNUserRegistRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_User_Regist;
}


- (id)sn_parameters {
    [self.parametersDict setValue:[SNClientRegister sharedInstance].s_cookie forKey:@"SCOOKIE"];
    [self.parametersDict setValue:[NSString stringWithFormat:@"%zd",[UIDevice isJailbroken]] forKey:@"jailbreak"];
    [self.parametersDict setValue:@"json" forKey:@"rt"];
    [self.parametersDict setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild] forKey:@"buildCode"];
    return [super sn_parameters];
}
@end
