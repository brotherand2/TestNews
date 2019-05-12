//
//  SNNewsPPLoginSetCookieRequest.m
//  sohunews
//
//  Created by wang shun on 2017/11/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginSetCookieRequest.h"

@implementation SNNewsPPLoginSetCookieRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginUrl_H5SetCookie;
}

- (SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}


@end
