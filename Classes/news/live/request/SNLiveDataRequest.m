//
//  SNLiveDataRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveDataRequest.h"
#import "SNAdManager.h"

@implementation SNLiveDataRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_Content;
}

- (id)sn_parameters {
    [self.parametersDict setValuesForKeysWithDictionary:[SNAdManager addAdParameters]];
    return [super sn_parameters];
}

@end
