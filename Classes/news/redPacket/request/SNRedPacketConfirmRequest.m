//
//  SNRedPacketConfirmRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/22.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRedPacketConfirmRequest.h"

@implementation SNRedPacketConfirmRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_RedPacket_Confirm;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
