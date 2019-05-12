

//
//  SNSearchMyStockRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  

#import "SNSearchMyStockRequest.h"


@implementation SNSearchMyStockRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Stock_Search;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
