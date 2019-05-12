//
//  JKWebAppManager.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/14.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKWebAppManager.h"
#import "JKUpgradeManager.h"
#import "Define.h"
#import "JKAuthUtils.h"
#import "JKGlobalSettings.h"

@implementation JKWebAppManager{
    NSMutableDictionary* webApps;
    NSRegularExpression *regex;
    NSURL* baseWebAppUrl;
    NSArray* allWebAppNames;
}

+(JKWebAppManager *)manager{
    static JKWebAppManager* manager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[JKWebAppManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        webApps = [[NSMutableDictionary alloc] init];
        baseWebAppUrl = [NSURL URLWithString:BASE_H5_APP_URL];
        regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^%@/([^/]*)/",baseWebAppUrl.path] options:NSRegularExpressionCaseInsensitive error:nil];
        _rootPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"shwebapp"];
        _buildResoucePath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:[JKGlobalSettings defaultSettings].webAppResourcePath];
        _upgradeManager = [[JKUpgradeManager alloc] initWithWebAppManager:self];
        [_upgradeManager checkUpgradeAtPointTime];
    }
    return self;
}

-(BOOL)isBuildInWebAppWithUrl:(NSURL*)url{
    JKWebApp* webApp = [self getWebAppWithUrl:url relativePath:nil];
    JKWebAppInfo* info;
    return webApp!=nil && ((info=[webApp buildInAppInfo])!=nil) && (info.versionCode > 0);
}

-(JKWebApp*)getWebAppWithUrl:(NSURL*)url relativePath:(NSString**)outRelatviePath{
    if (![JKAuthUtils checkWebAppAuth:url]) {
        return nil;
    }
    return [self getWebAppWithName:[self getNameByUrl:url relativePath:outRelatviePath]];
}

-(JKWebApp *)getWebAppWithName:(NSString *)name{
    if (name==nil) {
        return nil;
    }
    JKWebApp* app = [webApps valueForKey:name];
    if (app==nil) {
        app = [[JKWebApp alloc] initWithName:name manager:self];
        [webApps setValue:app forKey:name];
    }
    return app;
}

-(NSString*)getNameByUrl:(NSURL*)url relativePath:(NSString**)outRelatviePath{
    if (nil != url && nil != url.host) {
        NSTextCheckingResult* result = [regex firstMatchInString:url.path options:0 range:NSMakeRange(0, url.path.length)];
        if (result) {
            if (outRelatviePath) {
                *outRelatviePath = [url.path substringFromIndex:[result rangeAtIndex:0].length];
            }
            return [url.path substringWithRange:[result rangeAtIndex:1]];
        }
    }
    return nil;
}

-(NSArray *)getAllWebAppNames{
    if (allWebAppNames) {
        return allWebAppNames;
    }
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray* installedWebAppNames = [manager contentsOfDirectoryAtPath:_rootPath error:nil];
    NSArray* buildInWebAppNames = [manager contentsOfDirectoryAtPath:_buildResoucePath error:nil];
    NSSet* allWebAppNameSet = [[NSSet alloc] initWithArray:installedWebAppNames];
    allWebAppNames = [[allWebAppNameSet setByAddingObjectsFromArray:buildInWebAppNames] allObjects];
    return allWebAppNames;
}

@end
