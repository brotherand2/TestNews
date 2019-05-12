//
//  SNSerQuestionListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSerQuestionListRequest.h"

@implementation SNSerQuestionListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    
    return SNLinks_Path_FeedBack_SerQuesList;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
