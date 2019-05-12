//
//  SNNotifyRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNotifyRequest.h"

@implementation SNNotifyRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    
    return SNLinks_Path_Notify;
}

- (id)sn_parameters {// ?rt=json&checkType=social
    [self.parametersDict setValue:@"json" forKey:@"rt"];
    [self.parametersDict setValue:@"social" forKey:@"checkType"];
    return [super sn_parameters];
}

@end
