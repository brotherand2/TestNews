//
//  SNSpecialActivityRequest.m
//  sohunews
//
//  Created by yangln on 2017/9/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialActivityRequest.h"

@implementation SNSpecialActivityRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Special_Activity;
}

- (id)sn_parameters {
    [self.parametersDict setValue:[[UIDevice currentDevice] platformForSohuNews] forKey:@"deviceVersion"];
    [self.parametersDict setValue:[NSNumber numberWithInt:kAppScreenWidth] forKey:@"screenWidth"];
    [self.parametersDict setValue:[NSNumber numberWithInt:kAppScreenHeight] forKey:@"screenHeight"];
    
    return [super sn_parameters];
}

@end
