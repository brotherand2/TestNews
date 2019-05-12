//
//  SNConfigSettingRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNConfigSettingRequest.h"

@implementation SNConfigSettingRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Client_Setting;
}

- (id)sn_parameters {
    [self.parametersDict setValue:@"5" forKey:@"platform"];///平台 platform  3是安卓 5是ios
    [self.parametersDict setValue:@"1" forKey:@"isContainPopup"];
    [self.parametersDict setValue:[NSNumber numberWithInt:[SNUtility getSettingParamMode]] forKey:@"abmode"];
    [self.parametersDict setValue:[SNUtility ABTestUserMode] forKey:@"usermode"];
    return [super sn_parameters];
}
@end
