//
//  SNPushChangeRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPushChangeRequest.h"

@implementation SNPushChangeRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Push_Change;
}

- (id)sn_parameters {
    [self.parametersDict setValue:@"json" forKey:@"rt"];
    return [super sn_parameters];
}

@end
