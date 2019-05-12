//
//  JKWebApp.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/14.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JKWebAppInfo.h"

@class JKWebAppManager;

@interface JKWebApp : NSObject

@property(strong,nonatomic,readonly)NSString* name;

@property(strong,nonatomic,readonly)NSString* resourcesPath;

@property(strong,nonatomic,readonly)JKWebAppInfo* buildInAppInfo;

@property(strong,nonatomic,readonly)JKWebAppInfo* installedAppInfo;

-(instancetype)initWithName:(NSString*)name manager:(JKWebAppManager*)manager;

-(void)installBuildInWebApp:(BOOL)overWrite;

-(void)installWebAppFromZip:(NSString*)zipFilePath overWirte:(BOOL)overWirte;

-(NSString*)installFlagFile;

-(NSInteger)currentVersion;

-(NSData*)getResourceOfPath:(NSString*)relativePath;

-(NSData*)getMemoryCacheOfPath:(NSString*)relativePath;

@end
