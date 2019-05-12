//
//  SNAddMyStockRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  

#import "SNAddMyStockRequest.h"


@implementation SNAddMyStockRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Stock_Add;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

@end
