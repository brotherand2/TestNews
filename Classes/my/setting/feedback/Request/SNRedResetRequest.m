//
//  SNRedResetRequest.m
//  sohunews
//
//  Created by 李腾 on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRedResetRequest.h"

@implementation SNRedResetRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}


- (NSString *)sn_requestUrl {
    return SNLinks_Path_FeedBack_RedReset;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
