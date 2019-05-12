//
//  SNCommentListByCursorRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCommentListByCursorRequest.h"
#import "SNUserLocationManager.h"

@implementation SNCommentListByCursorRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict needNetSafeParameters:(BOOL)needNetSafe
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.needNetSafeParameters = needNetSafe;
    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    
    return SNLinks_Path_Comment_CommentList;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

@end
