//
//  SHAPI.m
//  LiteSohuNews
//
//  Created by lijian on 15/7/30.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SHAPI.h"

@implementation SHAPI

+ (NSString *)getBaseURL {
    return SNLinks_Domain_BaseURL;
}

+ (NSString *)getURLWithString:(NSString *)URLString {
    return [NSString stringWithFormat:@"%@%@", SNLinks_Domain_BaseURL, URLString];
}

+ (NSString *)getParam:(NSDictionary *)dic {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *itemString = [NSString stringWithFormat:@"%@=%@",key,obj];
        [mutablePairs addObject:itemString];
    }];
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

@end
