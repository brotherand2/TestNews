//
//  SNGetThirdAppListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNGetThirdAppListRequest.h"
#import "SNUserManager.h"

@implementation SNGetThirdAppListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Share_AppList;
}

- (id)sn_parameters {
    
    [self.parametersDict setValuesForKeysWithDictionary:[self addParamsForShare]];
    return [super sn_parameters];
}

- (NSDictionary *)addParamsForShare {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:@"1.0" forKey:@"version"];
    
    if([SNUserManager isLogin]) {
        if([SNUserManager getUserId].length > 0) {
            [params setValue:[SNUserManager getUserId] forKey:@"mainPassport"];
        }
        [params setValue:@"1" forKey:@"isCheck"];
    }
    return params.copy;
}

@end
