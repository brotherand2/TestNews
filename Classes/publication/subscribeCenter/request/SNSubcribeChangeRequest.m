//
//  SNSubcribeChangeRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSubcribeChangeRequest.h"

@implementation SNSubcribeChangeRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Subcribe_Change;
}

- (id)sn_parameters {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:@"json" forKey:@"rt"];
    [params setValue:@"1" forKey:@"showSub"];
    
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}
@end
