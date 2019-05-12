//
//  SNMyStockRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  

#import "SNMyStockRequest.h"

@implementation SNMyStockRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Stock_MyStock;
}

- (id)sn_parameters {
    
    [self.parametersDict setObject:@"99999" forKey:@"pageSize"];
    return [super sn_parameters];
}

@end
