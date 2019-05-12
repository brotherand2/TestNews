//
//  JKUpgradeManager.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/23.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JKUpgradeManager.h"

#import "JKWebAppManager.h"

#import "JKRequestManager.h"

#import "JKDownloadManager.h"

#import "JKFileUtils.h"

#import "Define.h"
#import "JsKitFramework.h"

#define CHECK_UPGRADE_INTERVAL 24*60*60


#define CHECK_UPGRADE_INTERVAL_WHEN_ERROR 4*60*60

@implementation JKUpgradeManager{
    JKWebAppManager* webAppManager;
    NSTimeInterval nextCheckTime;
    NSTimer* timer;
}

-(instancetype)initWithWebAppManager:(JKWebAppManager *)manager{
    if (self=[super init]) {
        webAppManager = manager;
        nextCheckTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@JsKitNextCheckUpgradeTime] doubleValue];
        timer = [NSTimer timerWithTimeInterval:CHECK_UPGRADE_INTERVAL target:self selector:@selector(checkUpgradeNow) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkUpgradeAtPointTime)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUpgradeAtPointTime) name: kJKReachabilityChangedNotification object: nil];
    }
    return self;
}

-(void)checkUpgradeAtPointTime{
    NSTimeInterval nextCheckInterval = nextCheckTime - [NSDate timeIntervalSinceReferenceDate];
    [self checkUpgradeDelay:MAX(10.0, nextCheckInterval)];
}

-(void)checkUpgradeDelay:(NSTimeInterval)delay{
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
}

- (void)uniqueIdentifier
{
    
}
-(void)checkUpgradeNow{
    //TODO do check
    static BOOL checking = NO;
    if (checking) {
        return;
    }
    checking = YES;
    
    NSUUID* uuid;
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        uuid = [[UIDevice currentDevice] identifierForVendor];
    }else{
        uuid = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier) withObject:nil];
    }
    
    
    NSArray* webAppNames = [webAppManager getAllWebAppNames];
    NSMutableArray* webAppVersionInfo = [[NSMutableArray alloc] initWithCapacity:[webAppNames count]];
    for (NSUInteger i=0,c=[webAppNames count]; i<c; i++) {
        JKWebApp* webApp = [webAppManager getWebAppWithName:[webAppNames objectAtIndex:i]];
        [webAppVersionInfo addObject:@{@"pluginName":webApp.name,
                                       @"pluginVer":@([webApp currentVersion])}];
    }
    
    
    [[JKRequestManager manager] getUpgradeInfo:[uuid UUIDString] sdkVer:JSKIT_VERSION_CODE hostAppName:[[NSBundle mainBundle] bundleIdentifier] hostVer:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] pluginInfos:webAppVersionInfo success:^(id  _Nonnull upgradeInfos) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                for (id webAppInfo in upgradeInfos) {
                    JKWebApp* webApp = [webAppManager getWebAppWithName:webAppInfo[@"pluginName"]];
                    //如果webapp版本有更新，则下载更新的webapp
                    if ([webAppInfo[@"rollback"] integerValue]!=0){
                        if ([webApp currentVersion] != [webAppInfo[@"verCode"] integerValue]) {
                            [webApp installBuildInWebApp:YES];
                        }
                    }else if ([webApp currentVersion] < [webAppInfo[@"verCode"] integerValue]) {
                        [self downloadWebApp:webAppInfo forWebApp:webApp];
                    }
                }
                
                nextCheckTime = [NSDate timeIntervalSinceReferenceDate] + CHECK_UPGRADE_INTERVAL;
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setValue:@(nextCheckTime) forKey:@JsKitNextCheckUpgradeTime];
                [userDefaults synchronize];
                checking = NO;
                return;
            }@catch (NSException *exception) {
                //            JSLog(@"%@",exception);
            }
            checking = NO;
            [self checkUpgradeDelay:CHECK_UPGRADE_INTERVAL_WHEN_ERROR];
        });
    } failure:^(NSError * _Nonnull error) {
        checking = NO;
        [self checkUpgradeDelay:CHECK_UPGRADE_INTERVAL_WHEN_ERROR];
    }];
    
}

-(void)downloadWebApp:(id)webAppInfo forWebApp:(JKWebApp*)webApp{
    [JKDownloadManager
     downloadFileWithURLString:[webAppInfo[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
     progressBlock:nil
     successBlock:^(AFHTTPRequestOperation *operation,NSString* filePath, id responseObject) {
         dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             if([webApp currentVersion] < [webAppInfo[@"verCode"] integerValue]){
                 if([[[JKFileUtils md5OfFile:filePath] lowercaseString] isEqualToString:[webAppInfo[@"md5"] lowercaseString]]){
                     [webApp installWebAppFromZip:filePath overWirte:YES];
                 }
                 [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
             }
         });
     } failureBlock:^(AFHTTPRequestOperation *operation,NSString* filePath, NSError *error) {
         [self checkUpgradeDelay:CHECK_UPGRADE_INTERVAL_WHEN_ERROR];
     }];
}

@end
