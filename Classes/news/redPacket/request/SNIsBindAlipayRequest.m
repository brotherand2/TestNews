//
//  SNIsBindAlipayRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNIsBindAlipayRequest.h"

@implementation SNIsBindAlipayRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_RedPacket_IsBindAlipay;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
