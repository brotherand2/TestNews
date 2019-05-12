//
//  SNNetworkConfiguration.h
//  TT_AllInOne
//
//  Created by tt on 15/5/29.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import <Foundation/Foundation.h>

//配置
static const NSInteger maxConcurrentOperationCountInNetwork = 4;
static NSString * const SNRequestCheckResponseErrorDomain = @"com.sohu.error.check.response";

static inline NSString * SNQueryStringFromParameters(id params) {
    if ([params isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *parts = [NSMutableArray array];
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id<NSObject> obj, BOOL *stop) {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *encodedValue = [[obj description] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }];
        return [parts componentsJoinedByString:@"&"];
    } else if ([params isKindOfClass:[NSString class]]) {
        return params;
    }
    return params;
}

static inline NSString * SNAddBuildInUrl(NSString *originStr, NSString *buildInStr) {
    if ([originStr rangeOfString:@"?"].location != NSNotFound) {
        return [originStr stringByAppendingFormat:@"&%@",buildInStr];
    } else {
        return [originStr stringByAppendingFormat:@"?%@",buildInStr];
    }
}

@interface SNNetworkConfiguration : NSObject

+ (SNNetworkConfiguration *)sharedInstance;

// 每次请求都会带上的默认参数
@property (strong, nonatomic) id buildInParameters; // 外部设置
@property (nonatomic, readonly) NSString *buildInUrl; // 转换后的string

// url统一前缀
@property (copy, nonatomic) NSString *baseUrl;

@end
