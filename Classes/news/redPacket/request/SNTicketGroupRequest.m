//
//  SNTicketGroupRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNTicketGroupRequest.h"

@implementation SNTicketGroupRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Ticket_Group;
}

- (id)sn_parameters {
    return [super sn_parameters];
}
@end
