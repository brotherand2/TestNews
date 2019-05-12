//
//  SNNewsPPLoginAppKey.m
//  sohunews
//
//  Created by wang shun on 2017/12/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginAppKey.h"

@implementation SNNewsPPLoginAppKey

+ (NSString*)AppKey:(NSString*)environment{
    NSString* appVerison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([appVerison isEqualToString:@"5.9.8"]) {
        if ([environment isEqualToString:@"test"]) {
            return @"58n3IzFIpEWQnjBmZkT8";
        }
        else if ([environment isEqualToString:@"online"]){
            return @"WEtHkynRcXivUmNAJmntp01SI9fvLYqQAuAiOSflfl3FyTMuYd";
        }
    }
    else if ([appVerison isEqualToString:@"5.9.9"]) {
        if ([environment isEqualToString:@"test"]) {
            return @"lIrowUaCDbXE9QJcrFRE";
        }
        else if ([environment isEqualToString:@"online"]){
            return @"lPbXeK7Xd5sVXCRh5BeoikXFrHEBgURY1SAVGw56SzdYGGiVxd";
        }
    }
    
    return @"WEtHkynRcXivUmNAJmntp01SI9fvLYqQAuAiOSflfl3FyTMuYd";
}


@end
