//
//  SNSettingViewController+extend.m
//  sohunews
//
//  Created by jojo on 14-4-2.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSettingViewController+extend.h"
#import "SNUserManager.h"
#import "SNSettingViewController.h"
#import "SNCacheCleanerManager.h"
#import "SNToast.h"
#import "SNUpgradeInfo.h"
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>

#import "SNNewAlertView.h"
#import "SNUpgradeHelper.h"
#import "TMCache.h"
#import "SNDBManager.h"
#import "SNNewsExposureManager.h"
#import "SNNewsFavourCache.h"
#import "SNSLib.h"
#import "SNSpecialActivity.h"

@implementation SNSettingViewController (Download)

-(void)kickDownload
{
    //[_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadedMode] forKey:kReferOfDownloader];
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:SN_String("tt://globalDownloader")] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)kickDownloadSetting
{
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://downloadSettingViewController"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

/*
- (void)kickDownload {
    
#if kNeedDownloadRollingNews
    //用户非第一次进入离线管理
    if (!![[NSUserDefaults standardUserDefaults] objectForKey:kIfDownloadSettingHadShown]) {
        NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
        //如果正在下载则进入“正在离线”界面
        if (!([[SNDownloadScheduler sharedInstance] isAllDownloadFinished])) {
            [_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadingMode] forKey:kReferOfDownloader];
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES]
                                       applyQuery:_query];
            [[TTNavigator navigator] openURLAction:_urlAction];
        }
        //如果没有下载则进入“离线内容”界面
        else {
            [_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadedMode] forKey:kReferOfDownloader];
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES]
                                       applyQuery:_query];
            [[TTNavigator navigator] openURLAction:_urlAction];
        }
         //(_query);
    }
    //用户第一次进入离线管理，则先打开“正在离线”界面，然后打开“离线设置”界面，以使得从设置界面返回时返回到“正在离线”界面；
    else {
        NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
        [_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadingMode] forKey:kReferOfDownloader];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:SN_String("tt://globalDownloader")] applyAnimated:NO]
                                   applyQuery:_query];
        [[TTNavigator navigator] openURLAction:_urlAction];
         //(_query);
        
        _urlAction = [[TTURLAction actionWithURLPath:@"tt://downloadSettingViewController"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
#else
    NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
    //如果正在下载则进入“正在离线”界面
    if (!([SNDownloadManager sharedInstance].isAllFinished)) {
        [_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadingMode] forKey:kReferOfDownloader];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:SN_String("tt://globalDownloader")] applyAnimated:YES]
                                   applyQuery:_query];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
    //如果没有下载则进入“离线内容”界面
    else {
        [_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadedMode] forKey:kReferOfDownloader];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:SN_String("tt://globalDownloader")] applyAnimated:YES]
                                   applyQuery:_query];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
     //(_query);
#endif
}
*/
 
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNSettingViewController (Media)

- (void)kickMedia {
    
    NSString *gid = [SNUserManager getGid];
    NSString *url = [kUrlOpenCMSEntranceControl stringByAppendingFormat:@"&userId=%@&p1=%@&gid=%@&token=%@",
                     [[SNUserManager getUserId] length] > 0 ? [SNUserManager getUserId] : @"",
                     [SNUserManager getP1],
                     gid.length > 0 ? gid : @"",
                     [[SNUserManager getToken] length] > 0 ? [SNUserManager getToken] : @""];
    if([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        url = [url stringByAppendingString:@"&mode=1"];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"mediaCooperation", @""), @"title", url, kLink, [NSNumber numberWithBool:NormalWebViewType], kUniversalWebViewType, nil];
    [SNUtility openUniversalWebView:dict];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNSettingViewController (checkUpdate)

- (void)checkUpdate {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    
    self.upgrade = [[SNUpgrade alloc] init];
//    [SNNotificationCenter showLoadingAndBlockOtherActions:NSLocalizedString(@"CheckingUpgrade", nil)];
	[self.upgrade getUpgradeInfoAsyncly:self];
}


-(void)remindUserAboutUpgrade:(SNUpgradeInfo *)upgradeInfo
{
    [SNNotificationCenter hideLoadingAndBlock];
    
    self.upgradeInfo = upgradeInfo;
    
	NSString *msg = upgradeInfo.description;
	
	if ([msg length] == 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"AlreadyLatestVersion", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
	}
	
	SNDebugLog(@"sohunewsAppDelegate - remindUserAboutUpgrade:%@", msg);
    
    [[SNUpgradeHelper sharedInstance] showUpgradeAlertWithMessage:msg CancelButtonHandler:nil OtherButtonHandle:^{
        if (self.upgradeInfo != nil && [self.upgradeInfo.downloadUrl length] != 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.upgradeInfo.downloadUrl]];
            if (self.upgradeInfo.upgradeType == 3) {
                exit(0);
            }
        }
        else {
            SNDebugLog(@"sohunewsAppDelegate - remindUserAboutUpgrade: Invalid upgradeInfo");
        }
        
    }];

}

- (void)receiveUpgradeInfo:(SNUpgradeInfo*)upgradeInfo
{
	if (upgradeInfo == nil) {
        [SNNotificationCenter hideLoadingAndBlock];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法检查更新" toUrl:nil mode:SNCenterToastModeWarning];
		SNDebugLog(@"sohunewsAppDelegate - receiveUpgradeInfo:Invalid upgradeInfo");
		return;
	}
	[self remindUserAboutUpgrade:upgradeInfo];
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNSettingViewController (clearCache)

- (void)clearCache:(SNSettingBaseCell *)cell {
    SNNewAlertView *clearAlert = [[SNNewAlertView alloc] initWithTitle:nil message:@"已离线的视频和媒体不被清除，确认删除所有缓存数据吗?"cancelButtonTitle:@"取消" otherButtonTitle:@"清空"];
    [clearAlert show];
    [clearAlert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
//        [self performSelector:@selector(clearCache) withObject:nil afterDelay:0.5];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self clearCache];
        });
    }];
}


- (void)clearCache {
        
    //清理数据库过期数据
    [[SNDBManager currentDataBase] cleanAllExpiredCache];
    
    //主要清理所有数据库，外带caches文件夹下的一些图片，但是没有清理离线刊物，不知为何。。
    [[SNCacheCleanerManager sharedInstance] cleanManually];
    
    //清理TMCache
    [[TMCache sharedCache] removeAllObjects];
    
    //清理浮层广告资源包
    [SNSpecialADTools removeAllAdResource];
    
    //清理浮层广告缓存
    [[SNSpecialActivity shareInstance] clearSNSpecialADCache];
    
    //清除图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    
    //h5的缓存
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage removeItems:@"article%"];
    
    //曝光记录
    [[SNNewsExposureManager sharedInstance] clearAllExposureNewsInFile];

    [[SNNewsFavourCache shareInstance] clearFavour];
    
    //清理狐友小视频缓存
    [SNSLib clearSnsVideoCache];
    
    //清caches文件夹
    [self cleanCachesDisk];
    
    //清理TTCache
    [[TTURLCache sharedCache] removeAll:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //	[SNNotificationCenter hideLoadingAndBlock];
        [[SNToast shareInstance] hideToast];
        SNDebugLog(@"%@", @"hide Loading And Block");
        [self resetCacheSizeLabel];
        
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Clear cache finished",@"") toUrl:nil mode:SNCenterToastModeSuccess];
    });
}
- (void)cleanCachesDisk {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        NSArray * contents = [fm subpathsAtPath:caches];
        for (NSString * fileName in contents) {
            NSString * path = [caches stringByAppendingPathComponent:fileName];
            if ([fm fileExistsAtPath:path ]) {
                [fm removeItemAtPath:path error:nil];
            };
        }
//    });
}


- (void)resetCacheSizeLabel {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kCacheSizeUpdateDate];
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults setObject:@"0.0 MB" forKey:kCacheSize];
    [_userDefaults synchronize];
    
    [self.tableView reloadData];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNSettingViewController (splash)

- (void)showSplash {
    if (!LoadingSwitch) {
        SNSplashViewController *splashViewController = [SNUtility getApplicationDelegate].splashViewController;
        if (splashViewController.isSplashDecelorating) {
            return;
        }
    }
    NSDictionary * obj = @{@"refer":@"userCenter"};
    [SNNotificationManager postNotificationName:kShowSplashViewNotification object:obj];
}

@end

@implementation SNSettingViewController (readingMode)

- (void)showReadingModeView {
    self.readModeAlertView = [[SNNewAlertView alloc] initWithContentView:[self creatReadingModeView] cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    [self.readModeAlertView show];
}

- (UIView *)creatReadingModeView {
    NSString *picMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
    NSInteger readMode = picMode.integerValue;
    
    self.readingModeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kReadingModeBttonHeight * 3 + 20)];
    NSArray *readingModes = @[@"无图模式（极省流量）", @"小图模式（较省流量）", @"畅读模式（体验最佳）"];
    for (NSString *readingModeStr in readingModes) {
        NSInteger index = [readingModes indexOfObject:readingModeStr];
        UIButton *readingModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        readingModeBtn.frame = CGRectMake(0, 10 + index * kReadingModeBttonHeight, kAppScreenWidth, kReadingModeBttonHeight);
        readingModeBtn.tag = 2 - index + kReadingModeBttonTag;
        readingModeBtn.backgroundColor = [UIColor clearColor];
        [readingModeBtn setTitle:readingModeStr forState:UIControlStateNormal];
        [readingModeBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
        [readingModeBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateHighlighted];
        [readingModeBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
        readingModeBtn.titleLabel.font = [UIFont systemFontOfSize:kReadingModeBttonFont];
        if (readMode == 2 - index) {
            readingModeBtn.selected = YES;
        }
        [readingModeBtn addTarget:self action:@selector(changeReadingMode:) forControlEvents:UIControlEventTouchUpInside];
        [self.readingModeView addSubview:readingModeBtn];
    }
    return self.readingModeView;
}

//2(无)   1(小)   0(畅)     客户端对应的模式
//1(无)   2(小)   0(畅)     H5和服务端对应的模式
- (void)changeReadingMode:(UIButton *)btn {
    
    for (UIButton *button in [self.readingModeView subviews]) {
        if (button.tag == btn.tag) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    NSString *modeStr = [NSString stringWithFormat:@"%d", btn.tag - kReadingModeBttonTag];
    
    [SNPreference sharedInstance].pictureMode = modeStr.integerValue;
    [[NSUserDefaults standardUserDefaults] setObject:modeStr forKey:kNonePictureModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *h5Mode = nil;
    if (modeStr.integerValue == 1) {
        h5Mode = @"2";
    } else if (modeStr.integerValue == 2) {
        h5Mode = @"1";
    } else {
        h5Mode = @"0";
    }
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInteger:h5Mode.integerValue] forKey:@"settings_imageMode"];
    

    [SNUtility sendSettingModeType:SNUserSettingImageMode mode:h5Mode];
    [self.readModeAlertView dismiss];
    [self.tableView reloadData];
}

@end

@implementation SNSettingViewController (userPrivacyProtectPolicy)

-(void)kickUserPrivacyProtectPolicy
{
    NSString *url = KUserPrivacyProtectPolicyUrl;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"title", url, kLink, [NSNumber numberWithBool:NormalWebViewType], kUniversalWebViewType, nil];
    [SNUtility openUniversalWebView:dict];
}

@end
