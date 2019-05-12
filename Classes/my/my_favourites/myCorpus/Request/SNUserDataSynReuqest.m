//
//  SNUserDataSynReuqest.m
//  sohunews
//
//  Created by TengLi on 2017/8/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//////// 数据同步接口 /////////

#import "SNUserDataSynReuqest.h"

@implementation SNUserDataSynReuqest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_SyncUserData;
}

- (id)sn_parameters {
    [self.parametersDict setValue:@"11" forKey:@"syncType"]; // 11 代表同步收藏和分享. 2017.8.28
    return [super sn_parameters];
}
@end
