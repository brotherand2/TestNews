//
//  SNWCache.m
//  sohunews
//
//  Created by H on 15/12/9.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#define     snw_fileSize            (3000000) // 3M

#import "SNWCache.h"
#import "SNWDefine.h"

@interface SNWCache ()

@property (nonatomic, retain) NSDictionary * appInfo;

@end

@implementation SNWCache

+ (SNWCache *)sharedInstance {

    static SNWCache * _cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[SNWCache alloc] init];
        _cache.appInfo = [NSDictionary dictionary];
    });
    return _cache;
}

- (BOOL)isCached:(NSString *)key {
    if (key.length == 0) {
        return NO;
    }
    NSString * path = [snw_home_directory stringByAppendingPathComponent:snw_app_group_filename];
    
    NSDictionary * cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if ([cacheData objectForKey:key]) {
        return YES;
    }
    return NO;
}

- (void)getDiskCacheDataForKey:(NSString *)key result:(void (^)(BOOL, NSDictionary *))result {

    if (key.length == 0) {
        result(NO,nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSString * path = [snw_home_directory stringByAppendingPathComponent:snw_app_group_filename];
        
        NSDictionary * cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        NSDictionary * resultDic = [cacheData objectForKey:key];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (resultDic) {
                result(YES,resultDic);
            }else{
                result(NO,nil);
            }
        });

    });
}

- (void)diskCachedData:(NSDictionary *)data Key:(NSString *)key Result:(void (^)(BOOL))finished {

    if (!data || !key) {
        return ;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary * finalData = nil;
        NSString * path = [snw_home_directory stringByAppendingPathComponent:snw_app_group_filename];
        
        NSDictionary * cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (cacheData) {
            
            finalData = [NSMutableDictionary dictionaryWithDictionary:cacheData];

            if (cacheData.count > 0 && cacheData.fileSize >= snw_fileSize) {
                [finalData removeAllObjects];
            }
            [finalData setObject:data forKey:key];
        }else{
            finalData = [NSMutableDictionary dictionaryWithObject:data forKey:key];
        }
        
        BOOL ret = [NSKeyedArchiver archiveRootObject:finalData toFile:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            finished(ret);
        });
    });

}

- (void)cachedAppInfo:(NSDictionary *)info {
    if (!info) {
        return;
    }
    self.appInfo = [NSDictionary dictionaryWithDictionary:info];
    NSString * path = [snw_home_directory stringByAppendingPathComponent:snw_app_info_filename];
    [NSKeyedArchiver archiveRootObject:info toFile:path];
}

- (NSDictionary *)getAppInfoFromCache {
    if (self.appInfo) {
        return self.appInfo;
    }
    NSString * path = [snw_home_directory stringByAppendingPathComponent:snw_app_info_filename];
    self.appInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return self.appInfo;
}

@end
