//
//  SNNewsPPLoginGetPhotoVcodeRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/30.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginGetPhotoVcodeRequest.h"

@implementation SNNewsPPLoginGetPhotoVcodeRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginUrl_PhotoVcode;
}

-(SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}

@end
