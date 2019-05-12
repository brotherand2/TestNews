//
//  JKWebAppInfo.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/22.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKWebAppInfo.h"


//JsKit.applicationId=jskit.sohu.com
//JsKit.versionCode=1
//JsKit.versionName=1.0
//JsKit.minJsKitVersion=1
//JsKit.targetJsKitVersion=1
@implementation JKWebAppInfo

-(instancetype)initWithFile:(NSString *)filePath{
    if (self=[super init]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if(data){
            NSDictionary* values = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            _applicationId = [values objectForKey:@"applicationId"];
            _versionCode = [[values objectForKey:@"versionCode"] integerValue];
            _versionName = [values objectForKey:@"versionName"];
            _forAppVersion = [values objectForKey:@"forAppVersion"];
            _minJsKitVersion = [[values objectForKey:@"minJsKitVersion"] integerValue];
            _targetJsKitVersion = [[values objectForKey:@"targetJsKitVersion"] integerValue];
            _buildTime = [[values objectForKey:@"buildTime"] longValue];
        }
    }
    return self;
}

+(JKWebAppInfo*)webAppInfoFromFile:(NSString*)filePath{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [[JKWebAppInfo alloc] initWithFile:filePath];
    }
    return nil;
}

@end
