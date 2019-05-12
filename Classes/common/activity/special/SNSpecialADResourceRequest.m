//
//  SNSpecialADResourceRequest.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialADResourceRequest.h"

@implementation SNSpecialADResourceRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Special_AdResource;
}

- (id)sn_parameters {
    [self.parametersDict setValue:[[UIDevice currentDevice] platformForSohuNews] forKey:@"deviceVersion"];
    [self.parametersDict setValue:[NSNumber numberWithInt:kAppScreenWidth] forKey:@"screenWidth"];
    [self.parametersDict setValue:[NSNumber numberWithInt:kAppScreenHeight] forKey:@"screenHeight"];
    
    return [super sn_parameters];
}

@end
