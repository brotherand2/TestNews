//
//  SNHisLivesRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNHisLivesRequest.h"

@implementation SNHisLivesRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_LiveHistory;
}

- (id)sn_parameters {
  
    return [super sn_parameters];
}

@end
