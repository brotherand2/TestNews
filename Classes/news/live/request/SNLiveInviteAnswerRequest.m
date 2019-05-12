//
//  SNLiveInviteAnswerRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLiveInviteAnswerRequest.h"

@implementation SNLiveInviteAnswerRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Live_InviteAnswer;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
