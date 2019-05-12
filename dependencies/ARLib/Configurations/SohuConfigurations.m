//
//  SohuConfigurations.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuConfigurations.h"
#import "SohuARSingleton.h"

@implementation SohuConfigurations

#pragma makr - getter

- (NSString *)type{
    return @"ios";
}

- (NSString *)systemVersion{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)rom{
    return [[UIDevice currentDevice] model];
}

- (NSString *)appVersion{
    return   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

-(NSString *)appBundle{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

-(BOOL)enableAR{
    return  [[UIDevice currentDevice].systemVersion doubleValue] >= 8.0;
}

+(NSMutableDictionary *)sohuConfigurations{
    NSDictionary *dic=@{
                        @"type":@"ios",
                        @"systemVersion":[[UIDevice currentDevice] systemVersion],
                        @"appVersion": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                        @"appBundle":[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"],
                        @"enableAR":@([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0),
                        @"activityID":[[SohuARSingleton sharedInstance]  activityID],
                        @"userID":[[SohuARSingleton sharedInstance]  userID],
                        };
    return [NSMutableDictionary dictionaryWithDictionary:dic];
}


@end
