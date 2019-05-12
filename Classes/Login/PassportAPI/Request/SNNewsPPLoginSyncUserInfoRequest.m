//
//  SNNewsPPLoginSyncUserInfoRequest.m
//  sohunews
//
//  Created by wang shun on 2017/11/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginSyncUserInfoRequest.h"
#import "SNNewsPPLoginEnvironment.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"

@implementation SNNewsPPLoginSyncUserInfoRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_PPLogin_GetPid;
}

- (id)sn_parameters {//参数不用底层传 @wangshun
    return self.parametersDict;
}

- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}

@end

