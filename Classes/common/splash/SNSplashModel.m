//
//  SNSplashModel.m
//  sohunews
//
//  Created by ZhaoQing on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSplashModel.h"
#import "SNUserLocationManager.h"
#import "SNNewsShareManager.h"
#import "SNAlertStackManager.h"
#import "SNRollingNewsPublicManager.h"
#import "SNSpecialActivity.h"
#import "SNCommentEditorViewController.h"
#import "SNStatisticsManager.h"

@interface SNSplashModel() <SCADSplashDelegate> {

}

@property (nonatomic, retain) SNNewsShareManager *splashShareManager;

@end

@implementation SNSplashModel 

- (id)initWithRefer:(SNSplashViewRefer)splashRefer delegate:(id<SNSplashViewDelegate>)delegate
{
    if (self=[super init]) {
        _splashRefer = splashRefer;
        _delegate = delegate;
        //初始化loading页广告设置
        SCADAdConfiguration *config = [[SCADAdConfiguration alloc] init];
        config.adUnitType = @"1";
        config.adSource = @"13";
        config.adViewSize = CGSizeMake(kAppScreenWidth, kAppScreenHeight);
        config.appSource = [SNPreference sharedInstance].marketId;
        config.userID = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
        if ([[SNUserLocationManager sharedInstance] getLatitude].length > 0 && [[SNUserLocationManager sharedInstance] getLongitude].length > 0) {
            config.coordinate = CLLocationCoordinate2DMake([[SNUserLocationManager sharedInstance] getLatitude].doubleValue , [[SNUserLocationManager sharedInstance] getLongitude].doubleValue);
        }
        NSString *gbcode = [SNUserLocationManager sharedInstance].currentChannelGBCode;
        if (!gbcode || gbcode.length == 0) {
            gbcode = [SNUserDefaults objectForKey:kAdGbcode];
        }
        config.geocoding = gbcode ? : @"";
        self.scadSplash = [[SCADSplash alloc] initWithAdUnitID:@"12224" configuration:config];
        self.scadSplash.timeoutLength = 1.5;
        self.scadSplash.delegate = self;
        //品牌区域
        if (!_customView) {
            _customView = [[SNBrandView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - 115, kAppScreenWidth, 115)];
            if (kAppScreenWidth == kIPHONE_6P_WIDTH) {
                _customView.frame = CGRectMake(0, kAppScreenHeight - 380.0f/3.0f, kAppScreenWidth, 385.0f/3.0f);
            }else if(kAppScreenWidth == kIPHONE_4_WIDTH){
                _customView.frame = CGRectMake(0, kAppScreenHeight - 196.0f/2.0f, kAppScreenWidth, 195.0f/2.0f);
            }
            
            if(kAppScreenHeight == 812){
                _customView.frame = CGRectMake(0, kAppScreenHeight - 140, kAppScreenWidth, 385.0f/3.0f);
            }
            
            UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(kAppScreenWidth - 44,_customView.height - 46, 44, 44);
            [shareBtn addTarget:self action:@selector(splashShare) forControlEvents:UIControlEventTouchUpInside];
            shareBtn.backgroundColor = [UIColor clearColor];
            shareBtn.exclusiveTouch = YES;
            [shareBtn setImage:[UIImage imageWithBundleName:@"icotext_share_v5.png"] forState:UIControlStateNormal];
            [shareBtn setImage:[UIImage imageWithBundleName:@"icotext_sharepress_v5.png"] forState:UIControlStateSelected];
            shareBtn.accessibilityLabel = @"分享封面图";
            [_customView addSubview:shareBtn];
        }
    }
    return self;
}

- (void)showSplashIsCountDown:(BOOL)animated {
    if ([[SNAlertStackManager sharedAlertStackManager] isShowing]) {//如果有首页有全屏广告
        if (_splashRefer == SNSplashViewReferAppLaunching) {
            [_delegate splashViewDidShow];
        }
        return;
    }
    //请求并展示广告
    self.scadSplash.isUsingForAppLaunch = animated;
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t1"];
    [self.scadSplash loadAndPresentWithCustomView:_customView];
}

- (void)updateSettingsWithConfig:(SNAppConfig *)config {
    //节日图标
    SNAppConfigFestivalIcon *festivalConfig = config.festivalIcon;
    BOOL festivalIconEnable = festivalConfig.hasFestivalIcon;
    if (festivalIconEnable) {
        NSString * festivalIconUrl = festivalConfig.festivalIconUrl;
        UIImage * cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:festivalIconUrl];
        if (cacheImage) {
            [_customView.festivalIdentity setImage:cacheImage animated:YES];
        }else{
            [_customView.festivalIdentity loadUrlPath:festivalIconUrl];
            [[SDImageCache sharedImageCache] storeImage:_customView.festivalIdentity.image forKey:festivalIconUrl toDisk:YES];
        }
    }
}

- (void)showSplashViewWhenActive {
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNCommentEditorViewController class]]) {
        SNCommentEditorViewController *commentEditorViewController = (SNCommentEditorViewController *)[[TTNavigator navigator] topViewController];
        [commentEditorViewController popViewController];
    }
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [self showSplashIsCountDown:YES];
}

- (void)exitSplash {
    //收起loading页
    [self.scadSplash dismiss];
}

- (BOOL)isSplashVisible {
    //loading页是否正在展示
    return self.scadSplash.isDisplaying;
}

- (void)pushToIntroChannel {
    //要闻频道改版不跳推荐
    if ([SNNewsFullscreenManager newsChannelChanged]) {
        return;
    }
    //跳转到推荐频道
    if ([SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom) {
        [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
        
        //判断是不是爆光过要闻频道，如果没爆光过，留在要闻频道
        if (![SNUtility shouldShowEditMode]) {
            //Loading页广告结束之后, 调用跳转推荐流的动画
            [SNNotificationManager postNotificationName:SNROLLINGNEWS_PUSHTONEXTCHANNEL object:nil];
        }
    }
}

- (void)splashShare {
    [self.scadSplash disableDismissTimer];
    NSMutableDictionary* dic = [self getShareInfo];
    [dic setObject:@"loading" forKey:@"shareLogType"];
    [dic setObject:@"qqZone,copyLink" forKey:@"disableIcons"];//不显示qq空间和复制链接
    [self callShare:dic];
}

- (NSMutableDictionary *)getShareInfo
{
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    NSDictionary *adDict = _scadSplash.properties;
    if (adDict) {
        NSString *title = [adDict objectForKey:@"sharedTitle"];
        title = (title && ![title isEqualToString:@""]) ? title : NSLocalizedString(@"News to share", @"");
        NSString *imageUrl = [adDict objectForKey:@"sharedURL"];
        NSString *shareContent = (title && ![title isEqualToString:@""]) ? title : NSLocalizedString(@"SMS share to friends for splash", @"");
        
        [dicShareInfo setObject:title forKey:kShareInfoKeyTitle];
        [dicShareInfo setObject:imageUrl forKey:kShareInfoKeyImageUrl];
        [dicShareInfo setObject:imageUrl forKey:@"url"];
        [dicShareInfo setObject:shareContent forKey:kShareInfoKeyContent];
        
        [dicShareInfo setObject:@"0" forKey:kShareInfoKeyNewsId];
        [dicShareInfo setObject:@"loading" forKey:@"contentType"];
        return dicShareInfo;
    }
    return nil;
}

- (void)callShare:(NSDictionary *)dic {
    if (self.splashShareManager) {
        self.splashShareManager = nil;
    }
    self.splashShareManager = [SNNewsShareManager loadShareData:dic FromView:_customView.window Delegate:self];
}

/**
 广告数据请求失败
 @param splash 实例
 @param error 错误
 */
- (void)splash:(SCADSplash *)splash didFailToReceiveAdWithError:(SCADError * )error {
    if (_splashRefer == SNSplashViewReferAppLaunching) {
        [_delegate splashViewDidShow];
        [[SNStatisticsManager shareInstance] recordAppStartStage:@"t6"];
        [_delegate splashViewDidExit];
    }
    [self pushToIntroChannel];
}

/**
 广告即将展示在屏幕上
 @param splash 实例
 */
- (void)splashWillPresentScreen:(SCADSplash *)splash {
    if (_splashRefer == SNSplashViewReferAppLaunching) {
        [_delegate splashViewDidShow];
    }
    if (_splashRefer == SNSplashViewReferRollingNewsHorizontalSliding) {
        [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
    } 
}

/**
 广告已经展示在屏幕上
 @param splash 实例
 */
- (void)splashDidPresentScreen:(SCADSplash *)splash {
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t2"];
    if (_splashRefer == SNSplashViewReferRollingNewsHorizontalSliding) {
        //进入splash页，停止焦点图轮播
        NSNumber *stopFlagNum = [NSNumber numberWithBool:YES];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[SNUtility getCurrentChannelId], @"stopChannelId", stopFlagNum, @"stopFlag", nil];
        [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];
    }
}

/**
 广告即将在屏幕上消失
 当落地页出现时，那这个方法会延迟到落地页将要消失时调用
 @param splash 实例
 */
- (void)splashWillDismissScreen:(SCADSplash *)splash {
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t3"];
    if (_splashRefer == SNSplashViewReferAppLaunching) {
        [_delegate splashViewWillExit];
    }
    if (_splashRefer == SNSplashViewReferRollingNewsHorizontalSliding) {
        [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:[SNUtility sharedUtility].currentChannelId];
    }
    //连续两次下拉toast显示问题yln
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShowLoadingPageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 广告已经在屏幕上消失
 当落地页出现时，那这个方法会延迟到落地页已经消失时调用
 @param splash 实例
 */
- (void)splashDidDismissScreen:(SCADSplash *)splash {
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t6"];
    if (_splashRefer == SNSplashViewReferAppLaunching) {
        [_delegate splashViewDidExit];
    }
    [self pushToIntroChannel];
    
    //离开splash页，恢复焦点图轮播
    NSNumber *stopFlagNum = [NSNumber numberWithBool:NO];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[SNUtility getCurrentChannelId], @"stopChannelId", stopFlagNum, @"stopFlag", nil];
    [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];
    
     [[SNUtility getApplicationDelegate].window makeKeyAndVisible];
    [[caltime sharedInstance] end_cal_time:@"didFinishLaunchingWithOptions"];
    if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
        [SNUtility trigerSpecialActivity];
    }
    
    // 检查是否有符合条件的弹窗
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL result = [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];
        SNDebugLog(@"%zd", result);
    });
}

/**
 广告被点击
 @param splash 实例
 */
- (void)splashDidClick:(SCADSplash *)splash {
    [SNUtility shouldUseSpreadAnimation:NO];
    NSString *url = [splash.properties objectForKey:@"click_url"];
    if (url && url.length > 0) {
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        [query setObject:[NSNumber numberWithInt:REFER_LOADING] forKey:kRefer];
        [SNUtility openProtocolUrl:url context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
    }
}
@end
