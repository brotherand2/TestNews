//
//  SNSpecialActivityReportRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialActivityReportRequest.h"

@implementation SNSpecialActivityReportRequest

- (instancetype)initWithSpecialActivityURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.url = urlString;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeHTTP;
}

- (NSString *)sn_customUrl {
    return self.url;
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_ResponseHttpManager;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/html"];
}

- (id)sn_parameters {
    return nil;
}

@end
