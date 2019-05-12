//
//  SNNewsPPThirdLoginRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPThirdLoginRequest.h"

@implementation SNNewsPPThirdLoginRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginUrl_thirdLogin;
}

-(SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}


@end
