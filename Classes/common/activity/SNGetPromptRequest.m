//
//  SNGetPromptRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  活动红点提醒信息

#import "SNGetPromptRequest.h"

@implementation SNGetPromptRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Activity_Info;
}

- (id)sn_parameters {
    
    [self.parametersDict setValue:[SNAPI productId] forKey:@"productId"];
    [self.parametersDict setValue:[NSString stringWithFormat:@"%zd",[SNUtility marketID]] forKey:@"channel"];
    [self.parametersDict setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey] forKey:@"version"];
    
    return [super sn_parameters];
}

@end
