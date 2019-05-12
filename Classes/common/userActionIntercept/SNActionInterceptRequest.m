//
//  SNActionInterceptRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNActionInterceptRequest.h"

@implementation SNActionInterceptRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_ActionIntercept;
}

- (id)sn_parameters {
    [self.parametersDict setValue:@"1.0" forKey:@"version"];
    return [super sn_parameters];
}

@end
