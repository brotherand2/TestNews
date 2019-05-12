//
//  SNSubHistoryListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSubHistoryListRequest.h"

@implementation SNSubHistoryListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_SubHistory;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
