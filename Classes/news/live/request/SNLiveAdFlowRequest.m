//
//  SNLiveAdFlowRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveAdFlowRequest.h"
#import "SNAdManager.h"
#import "SNVideoAdContext.h"

@implementation SNLiveAdFlowRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_AdFlow;
}

- (id)sn_parameters {
    
    [self.parametersDict setValue:@"1" forKey:@"num"];
    [self.parametersDict setValue:[[SNVideoAdContext sharedInstance] getCurrentChannelID] forKey:@"channelID"];
    [self.parametersDict setValuesForKeysWithDictionary:[SNAdManager addAdParameters]];
    return [super sn_parameters];
}

@end
