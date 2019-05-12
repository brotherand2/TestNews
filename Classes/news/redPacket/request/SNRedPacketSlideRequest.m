
//
//  SNRedPacketSlideRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRedPacketSlideRequest.h"

@implementation SNRedPacketSlideRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_RedPacket_Slide;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
