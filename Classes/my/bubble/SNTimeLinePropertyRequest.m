//
//  SNTimeLinePropertyRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNTimeLinePropertyRequest.h"

@implementation SNTimeLinePropertyRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    
    return SNLinks_Path_TimelineProperty;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
