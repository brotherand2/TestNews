//
//  SNUpgradeAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUpgradeAlert.h"
#import "SNNewAlertView.h"
#import "SNUpgradeInfo.h"

#define kHFNewVersionText @"发现新版本"
#define kUpgradeViewMaxHeight (kAppScreenWidth > 375.0 ? 500/1336.0*kAppScreenHeight : 250.0) - 38.0
#define kUpgradeViewWidth (kAppScreenWidth > 375.0 ? kAppScreenWidth * 2/3 : 250.0)
#define kUpgradeViewLeftMargin 22.0
#define kUpgradeViewTopMargin 31.0
#define kTotalMargin 81.0f
#define kTextLineSpacing 4.0f

@interface SNUpgradeAlert ()
@property (nonatomic, strong) SNNewAlertView *upgradeAlert;
@end

@implementation SNUpgradeAlert

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        self.alertViewType = SNAlertViewUpgradeType;
        [self setAlertViewData:content];
    }
    return self;
}

- (void)showAlertView {
    if (self.upgradeAlert) {
        [self.upgradeAlert show];
    } else {
        [self dismissAlertView];
    }
}

- (void)setAlertViewData:(id)content {
    
    SNNewAlertView *upgradeAlert = [[SNNewAlertView alloc] initWithContentView:[self createUpgradeViewWithMessage:content]
                                                             cancelButtonTitle:@"我知道了"
                                                              otherButtonTitle:@"立即升级"
                                                                    alertStyle:SNNewAlertViewStyleAlert];
    self.upgradeAlert = upgradeAlert;
    self.upgradeAlert.alertViewType = SNAlertViewUpgradeType;
    __weak typeof(self)weakself = self;
    [upgradeAlert actionWithBlocksCancelButtonHandler:^{
        SNUpgradeInfo *upgradeInfo	= [SNUpgradeInfo upgradeInfoWithData:
                                       (NSData*)[[NSUserDefaults standardUserDefaults] objectForKey:@"upgradeInfo"]];
        
        if (upgradeInfo.upgradeType != 3) {
            //更新用户对此次升级的取消信息
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"upgradeDeniedTime"];
            NSInteger nDeniedCount	= [[NSUserDefaults standardUserDefaults] integerForKey:@"upgradeDeniedCount"];
            [[NSUserDefaults standardUserDefaults] setInteger:++nDeniedCount forKey:@"upgradeDeniedCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            [weakself forceCloseAPP];
        }
    } otherButtonHandler:^{
        SNUpgradeInfo *upgradeInfo	= [SNUpgradeInfo upgradeInfoWithData:
                                       (NSData*)[[NSUserDefaults standardUserDefaults] objectForKey:@"upgradeInfo"]];
        if (upgradeInfo != nil && [upgradeInfo.downloadUrl length] != 0) {
            [SNNewsReport reportADotGif:@"s6=upgrade"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upgradeInfo.downloadUrl]];
            if (upgradeInfo.upgradeType == 3) {
                [weakself forceCloseAPP];
            }
        }
    }];
}

- (UIView *)createUpgradeViewWithMessage:(NSString *)message {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = kTextLineSpacing;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    
    CGRect textRect = [message boundingRectWithSize:CGSizeMake(kAppScreenWidth - kUpgradeViewLeftMargin * 2, FLT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:@{
                                                      NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeD],
                                                      NSParagraphStyleAttributeName:paraStyle
                                                      }
                                            context:nil];
    
    CGFloat textViewH = textRect.size.height + (textRect.size.height / [message textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]].height * 2 + 4) * kTextLineSpacing;
    CGFloat bgViewH = textViewH + kTotalMargin;
    if (bgViewH > kUpgradeViewMaxHeight) {
        bgViewH = kUpgradeViewMaxHeight;
    }
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kUpgradeViewWidth, bgViewH)];
    
    UIImage *topImage = [UIImage imageNamed:@"icotooltip_bj_v5.png"];
    UIImageView *topImageV = [[UIImageView alloc] initWithImage:topImage];
    topImageV.frame = CGRectMake(0, 0, kUpgradeViewWidth, topImage.size.height);
    [bgView addSubview:topImageV];
    UIImageView *iconV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icotooltip_rightfox_v5.png"]];
    [bgView addSubview:iconV];
    iconV.origin = CGPointMake(bgView.width - iconV.width, 0);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kUpgradeViewTopMargin, bgView.width, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    SNUpgradeInfo *upgradeInfo	= [SNUpgradeInfo upgradeInfoWithData:
                                   (NSData*)[[NSUserDefaults standardUserDefaults] objectForKey:@"upgradeInfo"]];
    
    titleLabel.text = [NSString stringWithFormat:@"%@V%@", kHFNewVersionText,upgradeInfo.latestVer];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.centerX = bgView.width / 2;
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    [bgView addSubview:titleLabel];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(kUpgradeViewLeftMargin, titleLabel.bottom + 15, bgView.width - kUpgradeViewLeftMargin * 2, bgView.height - kTotalMargin)];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.editable = NO;
    textView.selectable = NO;
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:kTextLineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kThemeFontSizeD] range:NSMakeRange(0, [message length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeText2Color) range:NSMakeRange(0, [message length])];// 解决升级文案无夜间模式
    textView.attributedText = attributedString;
    textView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:textView];
    
    return bgView;
}

- (void)forceCloseAPP {
    [UIApplication sharedApplication].keyWindow.transform = CGAffineTransformMakeScale(1,1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [UIApplication sharedApplication].keyWindow.transform = CGAffineTransformMakeScale(0.2,0.2);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

- (void)dealloc {
    
}

@end
