//
//  SohuFileManager.m
//  SohuAR
//
//  Created by sun on 2016/11/29.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SohuFileManager.h"
#import "SohuARMacro.h"
#import "SohuARSingleton.h"

@implementation SohuFileManager

+(UIImage *)readImageFromCachesWithRelativePath:(NSString *)relativePath{
    if ([relativePath length]==0) {
        return nil;
    }
    NSString *path=[SohuFileManager loadAbsolutePathWithRelativePath:relativePath];
    return [UIImage imageWithContentsOfFile:path];
}

+(NSData *)readDataFromCachesWithRelativePath:(NSString *)relativePath{
    NSString *path2 =[NSString stringWithFormat:@"%@%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,relativePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSData* data;
    data = [fm contentsAtPath:path2];
    return data;
}

+(NSURL *)readSceneSourceFromCachesWithRelativePath:(NSString *)relativePath{
     NSString *path2 =[NSString stringWithFormat:@"%@%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,relativePath];
    return [NSURL fileURLWithPath:path2];
}

+(NSURL *)loadMusicFromCachesWithRelativePath:(NSString *)relativePath{
    NSString *path2 =[NSString stringWithFormat:@"%@%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,@"Resources",relativePath];
    return  [NSURL fileURLWithPath:path2];

}

+(BOOL)zipResourcesAvailable{
    return ([self zipFileExists] && (![self zipFileTimeOut]));
}

+(BOOL)zipFileExists{
    NSString *path2 =[NSString stringWithFormat:@"%@%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,@"Resources"];
    NSFileManager* fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path2];
}

+(BOOL)zipFileTimeOut{
    return YES;
    NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:kconfigurationsPath];
    if ([dic[kTimeInterval] length]>0) {
         NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        double timeinterval=[dic[kTimeInterval] doubleValue];
        if (interval-timeinterval>0.00) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

+(NSDictionary *)loadSohuConfigurations{
    NSString *path =[NSString stringWithFormat:@"%@%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,@"Resources/Configurations.plist"];
    return  [NSDictionary dictionaryWithContentsOfFile:path];
}

+(NSString *)loadAbsolutePathWithRelativePath:(NSString *)relativePath{
     NSString *path =[NSString stringWithFormat:@"%@%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,@"Resources",relativePath];
    return path;
}

@end
