//
//  SNMobileLoginRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNMobileLoginRequest.h"

@implementation SNMobileLoginRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andUrl:(NSString *)url
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.url = url;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return self.url;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}

//lijian 20170925 强制切https
- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}

@end
