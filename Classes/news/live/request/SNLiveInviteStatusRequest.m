//
//  SNLiveInviteStatusRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveInviteStatusRequest.h"

@implementation SNLiveInviteStatusRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_InviteStatus;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
