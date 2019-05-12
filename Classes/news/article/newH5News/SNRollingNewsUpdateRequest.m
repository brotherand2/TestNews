//
//  SNRollingNewsUpdateRequest.m
//  sohunews
//
//  Created by 赵青 on 2017/4/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsUpdateRequest.h"

@implementation SNRollingNewsUpdateRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_News_NewsUpdate;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
