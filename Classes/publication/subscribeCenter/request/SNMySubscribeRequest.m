//
//  SNMySubscribeRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNMySubscribeRequest.h"
#import "SNClientRegister.h"

@implementation SNMySubscribeRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Subcribe_MySub;
}


- (id)sn_parameters {// ?&rt=json&showSdkAd=1&picScale=11&showAd=1&showSubRecom=1
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"json" forKey:@"rt"];
    [params setValue:@"1" forKey:@"showSdkAd"];
    [params setValue:@"11" forKey:@"picScale"];
    [params setValue:@"1" forKey:@"showAd"];
    [params setValue:@"1" forKey:@"showSubRecom"];
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    [params setValue:appBuild forKey:@"buildCode"];
    
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}

@end
