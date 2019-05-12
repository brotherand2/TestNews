//
//  SNFeedBackListRequest.m
//  sohunews
//
//  Created by 李腾 on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackListRequest.h"
#import "SNUserManager.h"

@implementation SNFeedBackListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_FeedBack_List;
}

- (id)sn_parameters {
    
    [self.parametersDict setValue:[NSNumber numberWithInt:10] forKey:@"size"];
    return [super sn_parameters];
}
@end
