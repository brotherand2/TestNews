//
//  SNNotifyTimeLineRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNotifyTimeLineRequest.h"

@implementation SNNotifyTimeLineRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    
    return SNLinks_Path_PPNotify;
}

- (id)sn_parameters {// ?version=1.0
    [self.parametersDict setValue:@"1.0" forKey:@"version"];
    return [super sn_parameters];
}

@end
