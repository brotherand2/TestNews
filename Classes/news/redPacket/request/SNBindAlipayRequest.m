//
//  SNBindAlipayRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBindAlipayRequest.h"

@implementation SNBindAlipayRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_RedPacket_BindAlipay;
}

- (id)sn_parameters {
    return [super sn_parameters];
}
@end
