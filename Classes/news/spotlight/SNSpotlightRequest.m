//
//  SNSpotlightRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpotlightRequest.h"

@implementation SNSpotlightRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Spotlight;
}

- (id)sn_parameters {
    return [super sn_parameters];
}
@end
