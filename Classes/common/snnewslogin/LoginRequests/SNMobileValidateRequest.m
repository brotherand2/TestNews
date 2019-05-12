//
//  SNMobileValidateRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNMobileValidateRequest.h"

@implementation SNMobileValidateRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    NSString* str = SNLinks_Path_Login_CheckValidate;
    return str;
}

- (id)sn_parameters {
    return [super sn_parameters];
}


@end
