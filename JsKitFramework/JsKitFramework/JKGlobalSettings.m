//
//  JKGlobalSettings.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/14.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKGlobalSettings.h"

@interface JKGlobalSettings()<JKZipArchiveDelegate>

@end

@implementation JKGlobalSettings

+(JKGlobalSettings *)defaultSettings{
    static JKGlobalSettings* settings;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        settings = [[JKGlobalSettings alloc] init];
        
    });
    return settings;
}

-(instancetype)init{
    if (self=[super init]) {
        _imageLoadMode = JKImageLoadAlways;
        _zipArchiveDelegate = self;
        _webAppResourcePath = @"shwebapp";
    }
    return self;
}

-(BOOL)unzipFileAtPath:(id)zipPath toDestination:(id)unzipPath{
    static dispatch_once_t once;
    static id clz = nil;
    dispatch_once(&once, ^{
        clz = NSClassFromString(@"SSZipArchive");
        if (![clz respondsToSelector:@selector(unzipFileAtPath:toDestination:)]) {
            clz = nil;
        }
    });
    if (clz!=nil) {
        return [clz unzipFileAtPath:zipPath toDestination:unzipPath];
    }
    NSLog(@"Your project must dependens SSZipArchive or you should set JKGlobalSettings.zipArchiveDelegate!");
    abort();
    return NO;
}

@end
