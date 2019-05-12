//
//  SNNewsReportRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsReportRequest.h"

@implementation SNNewsReportRequest

- (instancetype)initWithUrl:(NSString *)urlString
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

- (NSString *)sn_baseUrl {
    return [SNAPI baseUrlWithDomain:SNLinks_Domain_PicK];
}

- (NSString *)sn_requestUrl {
    return self.url;
}


@end
