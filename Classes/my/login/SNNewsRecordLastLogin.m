//
//  SNNewsRecordLastLogin.m
//  sohunews
//
//  Created by wang shun on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsRecordLastLogin.h"

@implementation SNNewsRecordLastLogin

+ (NSDictionary*)getLastLogin:(id)sender{
    NSString* path = [SNNewsRecordLastLogin pathForLastLogin];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
        return dic;
    }
    else{
        return nil;
    }
}

+ (void)saveLogin:(NSDictionary*)lastLoginDic{
    
    if (lastLoginDic && [lastLoginDic isKindOfClass:[NSDictionary class]]) {
        
        NSString* key = [lastLoginDic objectForKey:@"key"];
        NSString* value = [lastLoginDic objectForKey:@"value"];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        if (key && value) {
            [dic setObject:value forKey:key];
        }
        
        NSString* path = [SNNewsRecordLastLogin pathForLastLogin];
        [dic writeToFile:path atomically:YES];
    }
    else{
        NSString* path = [SNNewsRecordLastLogin pathForLastLogin];
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:path]) {
            [manager removeItemAtPath:path error:nil];
        }
    }
}

+ (NSString*)pathForLastLogin{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/lastLogin.plist"];
    return path;
}

@end
