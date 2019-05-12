//
//  SNKeywordRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNKeywordRequest.h"

@implementation SNKeywordRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Photo_Tags;
}

- (id)sn_parameters {
    
    [self.parametersDict setValue:@"json" forKey:@"rt"];
    return [super sn_parameters];
}


@end
