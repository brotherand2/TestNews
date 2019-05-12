//
//  JKWebApp.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/14.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKWebApp.h"
#import "JKWebAppManager.h"
#import "Define.h"
#import "JsKitFramework.h"
#import "JKGlobalSettings.h"

#define JsKitManifest @"JsKitManifest"
#define Payload @"Payload.zip"

@implementation JKWebApp{
    JKWebAppManager* webAppManager;
    NSMutableDictionary* cache;
    NSString* buildInResourcePath;
    BOOL isInstalled;
    JKWebAppInfo* _buildInAppInfo;
    JKWebAppInfo* _installedAppInfo;
}

-(instancetype)initWithName:(NSString *)name manager:(JKWebAppManager *)manager{
    if (self=[super init]) {
        _name = name;
        webAppManager = manager;
        _resourcesPath = [[manager rootPath] stringByAppendingPathComponent:_name];
        buildInResourcePath = [manager.buildResoucePath stringByAppendingPathComponent:_name];
        
        cache = [[NSMutableDictionary alloc] init];
        [self reloadInstalledAppInfo];
    }
    return self;
}

-(void)installBuildInWebApp:(BOOL)overWrite{
    if (isInstalled && !overWrite) {
        return;
    }
    NSString* buildInZipFile = [buildInResourcePath stringByAppendingPathComponent:Payload];
    if ([[NSFileManager defaultManager] fileExistsAtPath:buildInZipFile]) {
        [self installWebAppFromZip:buildInZipFile overWirte:overWrite];
        isInstalled = YES;
    }else{
//        JSLog(@"webapp of %@ is not a buildin app",self.name);
    }
}

-(JKWebAppInfo *)buildInAppInfo{
    if (!_buildInAppInfo) {
        _buildInAppInfo = [[JKWebAppInfo alloc] initWithFile:[buildInResourcePath stringByAppendingPathComponent:JsKitManifest]];
    }
    return _buildInAppInfo;
}

-(JKWebAppInfo *)installedAppInfo{
    if (!_installedAppInfo) {
        [self reloadInstalledAppInfo];
    }
    return _installedAppInfo;
}


-(BOOL)isBuildVersionGreater {
    return ((self.buildInAppInfo.versionCode > self.installedAppInfo.versionCode))
    || (_buildInAppInfo.versionCode == _installedAppInfo.versionCode
        && _buildInAppInfo.buildTime > _installedAppInfo.buildTime);
}

-(void)installWebAppFromZip:(NSString*)zipFilePath overWirte:(BOOL)overWirte{
    @synchronized (self) {
        NSString* installFlagFile = [self installFlagFile];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        //如果不要求强制覆盖，并且webapp已经部署，并且没有版本变化，则返回，否则需要部署webapp，即解压Payload.zip至资源目录
        if (!overWirte && [fileManager fileExistsAtPath:installFlagFile] && ![self isBuildVersionGreater]) {
            return;
        }
        [cache removeAllObjects];
        [[NSFileManager defaultManager] removeItemAtPath:_resourcesPath error:nil];
        //开始解压
        BOOL success = [[JKGlobalSettings defaultSettings].zipArchiveDelegate unzipFileAtPath:zipFilePath toDestination:_resourcesPath];
        if (success) {
            [self reloadInstalledAppInfo];
            [[NSFileManager defaultManager] createFileAtPath:installFlagFile contents:nil attributes:nil];
        }
        //解压完成
    }
}

-(void)reloadInstalledAppInfo{
    _installedAppInfo = [JKWebAppInfo webAppInfoFromFile:[_resourcesPath stringByAppendingPathComponent:JsKitManifest]];
    
}

-(NSString *)installFlagFile{
    return [_resourcesPath stringByAppendingPathComponent:@"install.ok"];
}

-(NSInteger)currentVersion{
    return MAX(self.installedAppInfo.versionCode, self.buildInAppInfo.versionCode);
}


-(NSData*)getResourceOfPath:(NSString*)relativePath{
    [self installBuildInWebApp:NO];
    if (self.buildInAppInfo.versionCode > 0) {
        //webApp使用本地资源
        NSString* localResourcePath = [self.resourcesPath stringByAppendingPathComponent:relativePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localResourcePath]) {
            NSData* cacheData = [cache objectForKey:relativePath];
            if (!cacheData) {
                cacheData = [NSData dataWithContentsOfFile:localResourcePath];
                [cache setObject:cacheData forKey:relativePath];
            }
            return cacheData;
        }
    }
    return [@"404 Local resource not found" dataUsingEncoding:NSUTF8StringEncoding];
}


-(NSData*)getMemoryCacheOfPath:(NSString*)relativePath{
    return [cache objectForKey:relativePath];
}

@end
