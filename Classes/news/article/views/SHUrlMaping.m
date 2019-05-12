//
//  SHUrlMaping.m
//  LiteSohuNews
//
//  Created by lijian on 15/7/15.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "SHUrlMaping.h"
#import "SHAPI.h"

NSString * const kHomeId = @"1";
NSString * const kPicsId = @"47";
NSString * const kLiveId = @"25";
NSString * const kQiquId = @"54";

@interface SHUrlMaping() {
    
}
@property (nonatomic, strong) NSData *data;

@end

@implementation SHUrlMaping

- (id)init
{
    self = [super init];
    if(nil != self){
        _data = [self getData];
    }
    return self;
}

+ (SHUrlMaping *)shareInstance
{
    static SHUrlMaping *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[SHUrlMaping alloc] init];
    });
    
    return instance;
}

+ (NSDictionary *)getUrlMaping
{
    SHUrlMaping *map = [SHUrlMaping shareInstance];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if(nil != map.data && [map.data length] > 0){
        NSString *content = [[NSString alloc] initWithData:map.data encoding:NSUTF8StringEncoding];
        NSString *key = nil;
        NSMutableString *value = nil;

        NSArray *array = [content componentsSeparatedByString:@"\n"];
        for (NSString *temp in array) {
            if(nil == temp || [temp length] <= 0 || [temp isEqualToString:@""]){
                continue;
            }
            
            NSRange range = [temp rangeOfString:@"#"];
            if(range.length > 0){
                continue;
            }
            
            NSArray *keyArray = [temp componentsSeparatedByString:@"/"];
            key = nil;
            value = [NSMutableString string];
            if(nil != keyArray && [keyArray count] >= 2){
                for (NSString *obj in keyArray) {
                    if(nil == obj || [obj length] <= 0 || [obj isEqualToString:@""]){
                        continue;
                    }
                    if(nil == key){
                        key = obj;
                        key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        continue;
                    }
                    
                    [value appendFormat:@"/%@",obj];
                }
                if (value.length > 0 && key.length > 0) {
                    [dic setObject:value forKey:key];
                }
            }
        }
    }
    
    return dic;
}


- (NSData *)getData
{
    //NSString *url = SH_URLMAPING_PATH;
//    APPLog(@"MapPath:%@",SH_URLMAPING_CONF);
//    if(NO == [[NSFileManager defaultManager] fileExistsAtPath:133 isDirectory:&isDirectory]) {
//        //return nil;
//    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:SH_URLMAPING_CONF]];
    return data;
}

+ (NSString *)getRelativePathWithKey:(NSString *)key
{
    if(nil == key && [key length] <= 0)
        return nil;
    
    NSDictionary *dic = [self getUrlMaping];
    
    NSArray *keys = [dic allKeys];
    
    for (NSString *temp in keys) {
        if(nil != temp && [temp length] > 0 && [temp isEqualToString:key]){
            return [dic objectForKey:key];
        }
    }
    
    return nil;
}

+ (NSString *)getLocalPathWithKey:(NSString *)key
{
    if(nil == key && [key length] <= 0)
        return nil;
    
    NSString *path = [self getRelativePathWithKey:key];
    if(nil != path)
    {
        return [NSString stringWithFormat:kH5AppsNewsSDKURL, path];
    }
    
    return nil;
}

+ (NSString *)getRelativePathWithChannelID:(NSString *)channelID {
    NSString *relativePath = nil;
    // 不同的频道需要加载不同的模板
    if ([channelID isEqualToString:kHomeId]) {
        relativePath = [self getLocalPathWithKey:SH_JSURL_HOME];
    } else if ([channelID isEqualToString:kPicsId] || [channelID isEqualToString:kQiquId]) {
        relativePath = [self getLocalPathWithKey:SH_JSURL_NEWSPICS];
    } else if ([channelID isEqualToString:kLiveId]) {
        relativePath = [self getLocalPathWithKey:SH_JSURL_NEWSLIVE];
    } else {
        relativePath = [self getLocalPathWithKey:SH_JSURL_NEWSLIST];
    }
    return relativePath;
}

@end
