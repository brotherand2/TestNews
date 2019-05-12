//
//  SNNormalActivityAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNormalActivityAlert.h"
#import "SNPopupActivity.h"
#import "SNNewAlertView.h"

#define bgViewH 200
#define kHFViewButtonFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeF : kThemeFontSizeE)
#define kHFPlayTextFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeE : kThemeFontSizeD)
#define kHFNewVersionTextViewLeftDistance ((kAppScreenWidth > 375.0) ? 138.0/3 : (kAppScreenWidth == 320.0 ? 60.0/2 : 90.0/2))
#define kHFNewVersionViewHeight ((kAppScreenWidth > 375.0) ? 1224.0/3 : 710.0/2)
#define kHFNewVersionImageViewHeight ((kAppScreenWidth > 375.0) ? 314.0/3 : 180.0/2)
#define kHFNewVersionTextViewTopDistance ((kAppScreenWidth > 375.0) ? 30.0/3 : 16.0/2)
#define kHFNewVersionTextViewBottomDistance ((kAppScreenWidth > 375.0) ? 94.0/3 : 56.0/2)
#define kHFViewButtonHeight (kHFViewButtonFontSize + 3)
#define kHFViewLeftDistance (kAppScreenWidth == 320.0 ? 40.0/2 : (kAppScreenWidth == 375.0 ? 90.0/2 : 150.0/3))
#define kHFViewButtonWidth (kAppScreenWidth - kHFViewLeftDistance*2)/2

@interface SNNormalActivityAlert ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) SNNewAlertView *activityAlert;
@property (nonatomic, strong) SNPopupActivity *activity;
@end

@implementation SNNormalActivityAlert

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        self.alertViewType = SNAlertViewNomalActivityType;
        [self setAlertViewData:content];
    }
    return self;
}

- (void)setAlertViewData:(id)content {
    
    if (content && [content isKindOfClass:[SNPopupActivity class]]) {
        self.activity = content;
        NSInteger activityType = self.activity.activityType;
        if (2 == activityType) {
            [self setActivityView];
            self.activityAlert = [[SNNewAlertView alloc] initWithContentView:self.bgView cancelButtonTitle:nil otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
            self.activityAlert.alertViewType = SNAlertViewNomalActivityType;
        } else {
            NSString *title = self.activity.title.length > 0 ? self.activity.title : nil;
            NSString *message = self.activity.message.length > 0 ? self.activity.message : nil;
            NSString *confirmBtnTitle = self.activity.confirmBtnTitle.length > 0 ? self.activity.confirmBtnTitle : @"";
            NSString *cancelBtnTitle = self.activity.cancelBtnTitle.length > 0 ? self.activity.cancelBtnTitle : @"";
            
            SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:NSLocalizedString(title, @"").length > 0 ? NSLocalizedString(title, @""):nil  message:message delegate:self cancelButtonTitle:cancelBtnTitle otherButtonTitle:confirmBtnTitle];
            self.activityAlert = alertView;
            self.activityAlert.alertViewType = SNAlertViewNomalActivityType;
            [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
                /// 点击埋点
                [SNNewsReport reportADotGif:@"_act=activity_clk&_tp=clk&from=2"];
                
                NSString *link2 = self.activity.confirmLink2;
                if (link2.length > 0) {
                    [SNUtility openProtocolUrl:link2 context:nil];
                }
            }];
        }
    }
}

- (void)showAlertView {
    if (self.activityAlert) {
        [self.activityAlert show];
    } else {
        [self dismissAlertView];
    }
    /// 添加活动曝光埋点
    if (self.activity.activityType == 2) {
        [SNNewsReport reportADotGif:@"_act=activity_expos&_tp=pv&from=1"];
    } else {
        [SNNewsReport reportADotGif:@"_act=activity_expos&_tp=pv&from=2"];
    }
    
    if (self.activity.activityType != 2) {
        [SNNormalActivityAlert cacheLasttimePopupedActivityID:self.activity.identifier];
        
        //如果10秒alertView仍显示着则自动隐藏
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.activity.maxDurationOfPopupActivity * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.activityAlert && self.activityAlert.superview) {
                [self.activityAlert dismiss];
            }
        });
    }
}

- (void)dismissAlertView {
    [self.activityAlert dismiss];
    self.activityAlert = nil;
}

- (void)setActivityView {
    [self setBgImageView];
    [self setRedPacketVerionLabel];
    [self setUpgradeTextView:70];
    [self setNormalHalfFloatViewButton:(bgViewH - kHFNewVersionTextViewBottomDistance - kHFViewButtonHeight)];
}

- (void)setBgImageView {
    UIImage *image = [UIImage themeImageNamed:@"icohome_hb_yd_v5.png"];
    CGFloat yValue = 1;
    if ([SNDevice sharedInstance].isPlus) yValue = -5;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -60 + yValue, kAppScreenWidth, image.size.height)];
    imageView.image = image;
    [self.bgView addSubview:imageView];
}

- (void)setRedPacketVerionLabel {
    NSString *titleString = self.activity.message;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    NSString *string = @" 精彩活动";
    if (titleString != nil && [titleString length] != 0) {
        string = [NSString stringWithFormat:@" %@", titleString];
    }
    [button setTitle:string forState:UIControlStateNormal];
    [button setImage:[UIImage themeImageNamed:@"icohome_shb_v5.png"] forState:UIControlStateNormal];
    [button setUserInteractionEnabled:NO];
    [button setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:kHFViewButtonFontSize];
    button.top = 20;
    [button sizeToFit];
    button.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:button];
    button.centerX = self.bgView.centerX;
}

- (void)setUpgradeTextView:(CGFloat)topValue {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(kHFNewVersionTextViewLeftDistance, topValue, kAppScreenWidth - 2*kHFNewVersionTextViewLeftDistance, kHFNewVersionViewHeight - kHFNewVersionImageViewHeight - kHFNewVersionTextViewTopDistance - 2*kHFNewVersionTextViewBottomDistance - kHFViewButtonHeight)];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:kHFPlayTextFontSize];
    textView.textColor = SNUICOLOR(kThemeText2Color);
    textView.textAlignment = NSTextAlignmentCenter;
    textView.editable = NO;
    textView.selectable = NO;
    textView.text = self.activity.descDetail;
    [self.bgView addSubview:textView];
}

- (void)setNormalHalfFloatViewButton:(CGFloat)topDistance {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:self.activity.cancelBtnTitle forState:UIControlStateNormal];
    [cancelBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:kHFViewButtonFontSize];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.frame = CGRectMake(kHFViewLeftDistance, topDistance, kHFViewButtonWidth, kHFViewButtonHeight);
    [cancelBtn addTarget:self action:@selector(dismissAlertView) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:cancelBtn];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:self.activity.confirmBtnTitle forState:UIControlStateNormal];
    [button setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:kHFViewButtonFontSize];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(cancelBtn.right, topDistance, kHFViewButtonWidth, kHFViewButtonHeight);
    [button addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:button];
}

- (void)confirmBtnClick {
    [self.activityAlert dismiss];
    ///  点击埋点
    [SNNewsReport reportADotGif:@"_act=activity_clk&_tp=clk&from=1"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SNUtility openProtocolUrl:self.activity.confirmLink2];
    });
}

/**
 *  缓存上次已弹过的activityID
 *
 *  @param lasttimePopupedActivityID 上次已弹过的activityID
 */
+ (void)cacheLasttimePopupedActivityID:(NSString *)lasttimePopupedActivityID {
    if (lasttimePopupedActivityID.length > 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:lasttimePopupedActivityID forKey:@"kLasttimePopupedActivityID"];
        [userDefaults synchronize];
    }
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, bgViewH)];
    }
    return _bgView;
}

- (void)dealloc {
    self.activityAlert = nil;
}

@end
