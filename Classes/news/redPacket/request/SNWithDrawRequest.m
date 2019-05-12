//
//  SNWithDrawRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWithDrawRequest.h"

@implementation SNWithDrawRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_RedPacket_Withdraw;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/plain"];
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
