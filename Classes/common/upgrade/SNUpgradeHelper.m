//
//  SNUpgradeHelper.m
//  sohunews
//
//  Created by Dan Cong on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNUpgradeHelper.h"
#import "SNUpgradeInfo.h"
#import "SNUpgradeAlert.h"
#import "SNAlertStackManager.h"

#define kHFNewVersionText @"发现新版本"
#define kUpgradeViewMaxHeight (kAppScreenWidth > 375.0 ? 500/1336.0*kAppScreenHeight : 250.0) - 38.0
#define kUpgradeViewWidth (kAppScreenWidth > 375.0 ? kAppScreenWidth * 2/3 : 250.0)
#define kUpgradeViewLeftMargin 22.0
#define kUpgradeViewTopMargin 31.0
#define kTotalMargin 81.0f
#define kTextLineSpacing 4.0f

@implementation SNUpgradeHelper

+ (SNUpgradeHelper *)sharedInstance {
    static SNUpgradeHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNUpgradeHelper alloc] init];
    });
    
    return _sharedInstance;
}

- (void)checkUpgrade
{
    _upgradeObj	= [[SNUpgrade alloc] init];
    [_upgradeObj getUpgradeInfoAsyncly:self];
}


-(BOOL)optionalUpgradeNeedUserConfirm
{
    NSInteger nDeniedCount	= [[NSUserDefaults standardUserDefaults] integerForKey:@"upgradeDeniedCount"];
    NSDate *dateDenied	= [[NSUserDefaults standardUserDefaults] objectForKey:@"upgradeDeniedTime"];
    NSDate *dateNow		= [NSDate date];
    NSTimeInterval timeInterval	= [dateNow timeIntervalSinceDate:dateDenied];
    
    /*
     deny=0    1.   服务器开启升级后，重启客户端后第一次弹出升级提示；（点击取消后关闭提示，从点击取消一刻开始计时）
     deny=1    2.   24小时后重启客户端，第二次弹出升级提示；
     deny=2    3.   24小时后重启客户端，第三次弹出升级提示；
     deny>=3   4.   第三次及以后，每隔1周重启客户端弹出一次提示(如果用户不升级，此逻辑会一直执行)
     */
    
    switch (nDeniedCount) {
        case 0:
            return YES;
        case 1:
        case 2:
        {
            if (timeInterval >= 24 * 60 * 60) {
                return YES;
            }
            else {
                return NO;
            }
        }
            break;
        default:
        {
            if (timeInterval >= 7 * 24 * 60 * 60) {
                return YES;
            }
            else {
                return NO;
            }
        }
            break;
    }
    
    return NO;
}

#pragma mark - SNUpgradeDelegate
- (void)receiveUpgradeInfo:(SNUpgradeInfo*)upgradeInfo
{
    if (upgradeInfo == nil) {
        SNDebugLog(@"sohunewsAppDelegate - receiveUpgradeInfo:Invalid upgradeInfo");
        if ([_delegate respondsToSelector:@selector(didFinishUpgradeCheck:)]) {
            [_delegate didFinishUpgradeCheck:NO];
        }
        return;
    }
    
    SNDebugLog(@"sohunewsAppDelegate - receiveUpgradeInfo successfully");
    
    int nRet = 0;
    //对比最新从服务器取得的升级信息同上次获取的升级信息是否一致
    if ([upgradeInfo hadError]) {
        if (upgradeInfo.networkError != nil) {
            SNDebugLog(@"sohunewsAppDelegate - receiveUpgradeInfo:netWork error:%d, %@"
                       ,[upgradeInfo.networkError code],[upgradeInfo.networkError localizedDescription]);
        }
        else{
            SNDebugLog(@"sohunewsAppDelegate - receiveUpgradeInfo:server return error = %@",upgradeInfo.serverRtnError);
        }
    }
    else {
        SNUpgradeInfo *lastUpgradeInfo	= [SNUpgradeInfo upgradeInfoWithData:
                                           (NSData*)[[NSUserDefaults standardUserDefaults] objectForKey:@"upgradeInfo"]];
        
        if (!lastUpgradeInfo.bNeedUpgrade && !upgradeInfo.bNeedUpgrade) {
            
        }
        else {
            //同上次的升级信息相同
            if ([lastUpgradeInfo.latestVer isEqualToString:upgradeInfo.latestVer]
                && lastUpgradeInfo.upgradeType	== upgradeInfo.upgradeType) {
                switch (upgradeInfo.upgradeType) {
                        //可选升级、重要升级，根据上次提示后用户的反应确认是否需要在此弹出提示
                    case 1:
                    case 2:
                    {
                        if ([self optionalUpgradeNeedUserConfirm]) {
                            nRet = upgradeInfo.upgradeType;
                        }
                    }
                        break;
                        //强制升级，则直接弹出强制升级的提示
                    case 3:
                        nRet = upgradeInfo.upgradeType;
                        break;
                    default:
                        break;
                }
            }
            //新的升级信息
            else {
                [[NSUserDefaults standardUserDefaults] setObject:[upgradeInfo getData] forKey:@"upgradeInfo"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"upgradeDeniedTime"];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"upgradeDeniedCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                nRet = upgradeInfo.upgradeType;
            }
        }
    }
    
    // //(_upgradeObj);
    [self remindUserAboutUpgrade:nRet];
}

-(void)remindUserAboutUpgrade:(int)upgradeFlag
{
    SNUpgradeInfo *lastUpgradeInfo	= [SNUpgradeInfo upgradeInfoWithData:
                                       (NSData*)[[NSUserDefaults standardUserDefaults] objectForKey:@"upgradeInfo"]];
    BOOL needNotify = YES;
    NSString *msg	= nil;
    switch (upgradeFlag) {
        case 1:
        case 2:
        {
            msg = lastUpgradeInfo.description;
            if ([msg length] == 0) {
                msg	= NSLocalizedString(@"Optional upgrade", @"");
            }
        }
            break;
        case 3:
        {
            msg = lastUpgradeInfo.description;
            if ([msg length] == 0) {
                msg	= NSLocalizedString(@"Force upgrade", @"");
            }
        }
            break;
        default:
            break;
    }
    
    BOOL needAlertUpgradeMessage = [msg length] > 0;
    
    if (!needAlertUpgradeMessage) {
        SNDebugLog(@"sohunewsAppDelegate - remindUserAboutUpgrade:not need");
    }
    else {
        needNotify = NO;
        SNUpgradeAlert *upgradeAlert = [[SNUpgradeAlert alloc] initWithAlertViewData:msg];
        [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:upgradeAlert];
    }
    // add by Cae. 补上同步client/setting.go的逻辑
    if (needNotify && [_delegate respondsToSelector:@selector(didFinishUpgradeCheck:)]) {
        [_delegate didFinishUpgradeCheck:needAlertUpgradeMessage];
    }
}

@end
