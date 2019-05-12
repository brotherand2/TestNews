//
//  SNClearPushCountRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNClearPushCountRequest.h"

@implementation SNClearPushCountRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_ClearPush;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
