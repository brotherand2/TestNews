//
//  SNResetPromptRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNResetPromptRequest.h"

@implementation SNResetPromptRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Activity_Reset;
}

- (id)sn_parameters {
    
    [self.parametersDict setValue:[SNAPI productId] forKey:@"productId"];
    
    return [super sn_parameters];
}

@end
