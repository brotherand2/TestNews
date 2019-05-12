//
//  SNPushGuideAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPushGuideAlert.h"
#import "SNNewAlertView.h"
#import "SNUtility.h"

@interface SNPushGuideAlert ()
@property (nonatomic, strong) SNNewAlertView *pushGuideAlert;
@end

@implementation SNPushGuideAlert

+ (BOOL)shouldShowPushGuideAlert {
    
    if ([SNUtility sharedUtility].isEnterBackground) [SNUtility sharedUtility].isEnterBackground = NO;
    if ([SNUserDefaults objectForKey:kRecordFirstOpenNewsKey]) {
        NSDate *lastDate = [SNUserDefaults objectForKey:kRecordFirstOpenNewsKey];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = [[[SNAppConfigManager sharedInstance] checkPushPeriod] integerValue];
        NSDate *expiredDate = [calendar dateByAddingComponents:components toDate:lastDate options:0];
        if (([expiredDate compare:[NSDate date]] == NSOrderedAscending && ![expiredDate isEqualToDate:lastDate]) || [SNUtility isCoverInstallAPP]) {
            BOOL isOverIOS8 = [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
            if (isOverIOS8) { //  >= iOS8.0
                UIUserNotificationSettings* userSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
                if (UIUserNotificationTypeNone == userSetting.types || ![SNUtility isHavePushSwitchOpened]) {
                    return YES;
                }
            } else if (UIRemoteNotificationTypeNone == [[UIApplication sharedApplication] enabledRemoteNotificationTypes] || ![SNUtility isHavePushSwitchOpened]) {
                return YES;
            }
        }
    }
    return NO;
}

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        [self setAlertViewData:content];
        self.alertViewType = SNAlertViewPushGuideType;
    }
    return self;
}

- (void)setAlertViewData:(id)content {
    
    BOOL isOverIOS8 = [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)];
    
    if (isOverIOS8) {
        UIUserNotificationSettings* userSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        __weak typeof(self)weakself = self;
        [self setPushGuideAlertHandler:^{
            if (UIUserNotificationTypeNone == userSetting.types) {
                //iOS8以上支持，打开应用设置页
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
                if (![SNUtility isHavePushSwitchOpened]) {
                    [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                    [weakself setPushSettingRequest];
                }
            } else {//open 快讯
                [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                [weakself setPushSettingRequest];
            }
        }];
        [SNUserDefaults setObject:[NSDate date] forKey:kRecordFirstOpenNewsKey];
        
    } else {
        __weak typeof(self)weakself = self;
        [self setPushGuideAlertHandler:^{
            if (UIRemoteNotificationTypeNone == [[UIApplication sharedApplication] enabledRemoteNotificationTypes]) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 解决iOS7通知浮层未弹出问题。。
                    SNNewAlertView *notiAlert = [[SNNewAlertView alloc] initWithContentView:[weakself createNotiView]  cancelButtonTitle:nil otherButtonTitle:kLowVersionIKnow alertStyle:SNNewAlertViewStyleAlert];
                    [notiAlert show];
                });
                
                if (![SNUtility isHavePushSwitchOpened]) {
                    [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                    [weakself setPushSettingRequest];
                }
            } else {//open 快讯
                [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                [weakself setPushSettingRequest];
            }
        }];
    }
}

- (void)showAlertView {
    if (self.pushGuideAlert) {
        [self.pushGuideAlert show];
    } else {
        [self dismissAlertView];
    }
}

- (UIView *)createNotiView {
    CGFloat imageH = 124/667.0 * kAppScreenHeight;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kAppScreenWidth > 375.0 ? kAppScreenWidth * 2/3 : 250.0), imageH+133.0)];
    bgView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bgView.width, imageH)];
    imageV.image = [UIImage imageNamed:@"icotooltip_zdzx_v5.png"];
    [bgView addSubview:imageV];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageH+20, bgView.width, 25)];
    titleLabel.text = @"第一时间获取重大新闻";
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    
    UILabel *massageLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, imageH+20+25+8, bgView.width - 22*2, 40)];
    massageLabel.text = @"打开设置,在“通知管理”或“应用管理”中选择搜狐新闻,开启通知。";
    massageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    massageLabel.textColor = SNUICOLOR(kThemeText4Color);
    massageLabel.numberOfLines = 0;
    massageLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [bgView addSubview:massageLabel];
    return bgView;
}

- (void)setPushSettingRequest {
    
    [[[SNUserSettingRequest alloc] initWithUserSettingMode:SNUserSettingNewsPushMode andModeString:@"1"] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        if (status == 200) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kPushSettingOpened toUrl:nil mode:SNCenterToastModeSuccess];
            [SNUserDefaults setObject:@"1" forKey:kNewsPushSet];
        }
    } failure:nil];
}


- (void)setPushGuideAlertHandler:(void (^)(void))handler {
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:kPushSettingContent cancelButtonTitle:kPushTemporarily otherButtonTitle:kPushOpenImmediate];
    self.pushGuideAlert = alert;
    self.pushGuideAlert.alertViewType = SNAlertViewPushGuideType;
    NSString *aDotURL = [SNUtility addNetSafeParametersForURL:@"_act=cc"];
    aDotURL = [aDotURL stringByAppendingString:@"&page=0&topage="];
    __block NSString *blockDotURL = aDotURL;
    [alert actionWithBlocksCancelButtonHandler:^{
        blockDotURL = [aDotURL stringByAppendingString:@"&fun=66"];
        [SNNewsReport reportADotGif:blockDotURL];
    } otherButtonHandler:^{
        blockDotURL = [aDotURL stringByAppendingString:@"&fun=67"];
        [SNNewsReport reportADotGif:blockDotURL];
        if (handler) handler();
    }];
}


@end
