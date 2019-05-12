//
//  SNNewsLoginBaseRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginBaseRequest.h"
#import "SNNewsPPLoginEnvironment.h"

@implementation SNNewsLoginBaseRequest

-(instancetype)initWithDictionary:(NSDictionary *)dict PPJV:(NSString *)ppjv{
    if (self = [super initWithDictionary:dict]) {
        self.ppjv = ppjv;
    }
    return self;
}

- (NSString *)sn_requestUrl{
    return @"";
}

- (SNRequestMethod)sn_requestMethod{
    return SNRequestMethodPost;
}

- (SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (id)sn_parameters{
    
    NSDictionary* dic = [SNNewsPPLoginHeader getPPBaseParams];
    
    [self.parametersDict addEntriesFromDictionary:dic];
    
    NSString* sig = [SNNewsPPLoginHeader getSig:self.parametersDict];
    [self.parametersDict setObject:sig forKey:@"sig"];
    return self.parametersDict;
}

- (NSString *)sn_baseUrl{
    NSString* host = [NSString stringWithFormat:@"https://%@",[SNNewsPPLoginEnvironment domain]];
    return host;
}

- (NSDictionary *)sn_requestHTTPHeader{
    NSMutableDictionary* dic = [SNNewsPPLoginHeader getPPHeader];
    if (self.ppjv) {
        [dic setObject:self.ppjv forKey:@"PP-JV"];
    }

    return dic;
}


@end
