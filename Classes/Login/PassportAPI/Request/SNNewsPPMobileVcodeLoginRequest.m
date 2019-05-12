//
//  SNNewsPPMobileVcodeLoginRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPMobileVcodeLoginRequest.h"

@implementation SNNewsPPMobileVcodeLoginRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginUrl_mobileVcode;
}

-(SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}

@end
