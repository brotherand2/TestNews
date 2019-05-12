//
//  JKWebAppInfo.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/22.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKWebAppInfo : NSObject

@property(strong,nonatomic,readonly)NSString* applicationId;
@property(assign,nonatomic,readonly)NSInteger versionCode;
@property(strong,nonatomic,readonly)NSString* versionName;
@property(assign,nonatomic,readonly)NSInteger minJsKitVersion;
@property(assign,nonatomic,readonly)NSInteger targetJsKitVersion;
@property(strong,nonatomic,readonly)NSString* forAppVersion;
@property(assign,nonatomic,readonly)long buildTime;

-(instancetype)initWithFile:(NSString*)filePath;

+(JKWebAppInfo*)webAppInfoFromFile:(NSString*)filePath;

@end
