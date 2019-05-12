//
//  SNReasonsForUninterestedRequest.m
//  sohunews
//
//  Created by 赵青 on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNReasonsForUninterestedRequest.h"

@implementation SNReasonsForUninterestedRequest

#pragma mark SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Channel_DislikeReason;
}

- (id)sn_parameters {
    
    [self.parametersDict setObject:[SNAPI productId]?:@"" forKey:@"productid"];
    return [super sn_parameters];
}

@end

@implementation SNReasonsForUninterestedReportRequest

#pragma mark SNRequestProtocol
- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}


- (NSString *)sn_requestUrl {
    return SNLinks_Path_Channel_DislikeReport;
}

- (id)sn_parameters {
    [self.parametersDict setObject:[SNAPI productId]?:@"" forKey:@"productid"];
    return [super sn_parameters];
}


@end
