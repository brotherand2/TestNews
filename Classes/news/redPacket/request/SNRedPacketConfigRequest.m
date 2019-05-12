//
//  SNRedPacketConfigRequest.m
//  sohunews
//
//  Created by iEvil on 3/9/16.
//  Copyright © 2016 Sohu.com. All rights reserved.
//

#import "SNRedPacketConfigRequest.h"

@implementation SNRedPacketConfigRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Client_Config;
}

- (id)sn_parameters {
    return [super sn_parameters];
}


- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/plain"];
}

@end
