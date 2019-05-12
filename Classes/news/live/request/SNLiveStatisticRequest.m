//
//  SNLiveStatisticRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveStatisticRequest.h"

@implementation SNLiveStatisticRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_Statistic;
}

- (id)sn_parameters {
//    ?liveId=%@&statisticsType=1
    [self.parametersDict setValue:@"1" forKey:@"statisticsType"];
    return [super sn_parameters];
}

@end
