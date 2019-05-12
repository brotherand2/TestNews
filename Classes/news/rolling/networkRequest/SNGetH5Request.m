//
//  SNGetH5Request.m
//  sohunews
//
//  Created by 李腾 on 2017/2/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNGetH5Request.h"

@implementation SNGetH5Request

#pragma mark SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Channel_H5;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

@end
