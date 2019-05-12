//
//  SNMsgRecRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNMsgRecRequest.h"

@implementation SNMsgRecRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    
    return SNLinks_Path_UserMsgRec;
}

- (id)sn_parameters {
    [self.parametersDict setValuesForKeysWithDictionary:[SNUtility paramsDictionaryForReadingCircle]];
    return [super sn_parameters];
}

@end
