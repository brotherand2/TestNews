//
//  SNDelCommentRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDelCommentRequest.h"

@implementation SNDelCommentRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Comment_Delete;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
