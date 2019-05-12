//
//  SNNewsPPLoginJSRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginJSRequest.h"

@implementation SNNewsPPLoginJSRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginURL_JSEval;
}

- (SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}

@end
