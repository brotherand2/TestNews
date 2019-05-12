//
//  SNWeatherRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWeatherRequest.h"

@implementation SNWeatherRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Weather;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
