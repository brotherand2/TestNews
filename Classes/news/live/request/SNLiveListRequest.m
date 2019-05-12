//
//  SNLiveListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveListRequest.h"

@implementation SNLiveListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_LiveList;
}

- (id)sn_parameters {

    [self.parametersDict setValue:@"1" forKey:@"type"];
    return [super sn_parameters];
}


@end
