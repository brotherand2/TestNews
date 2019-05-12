//
//  SNNewsPPLoginSohuRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/30.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginSohuRequest.h"

@implementation SNNewsPPLoginSohuRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginUrl_SohuLogin;
}

-(SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}

@end
