//
//  SNUnreadClearRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUnreadClearRequest.h"

@implementation SNUnreadClearRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Subcribe_UnreadClear;
}

- (id)sn_parameters {
    return [super sn_parameters];
}
@end
