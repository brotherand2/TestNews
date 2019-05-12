//
//  SNRecordView.m
//  sohunews
//
//  Created by jialei on 13-6-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentEditorRecordView.h"
#import "UIImage+Utility.h"
#import "SNSoundManager.h"


#define kTimerLabelX            (kAppScreenWidth/2 + 25.0)
#define kTimerLabelY            (34.0)
#define kTimerLabelWidth        (30.0)
#define kTimerLabelHeight       (15.0)
#define kRecordButtonWidth      (204.0)
#define kRecordButtonHeight     (38.0)

#define kRecordPowerModulus     (1.5)

@interface SNRecordView ()
{
    UILabel *_timeTipLabel;
}
@end

@implementation SNRecordView

float const _maxPowerValue = 1.0;
float const _powerViewPointY = 122.0;

@synthesize recordButton;
@synthesize timerLabel;
@synthesize recordDelegate;
@synthesize powerValueView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *backgroundImage = [UIImage themeImageNamed:@"comment_input_background.png"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = self.bounds;
        [self addSubview:backgroundImageView];
        
        //麦克风
        UIImage *micImage= [UIImage themeImageNamed:@"comment_microphone.png"];
        UIImageView *microphoneView = [[UIImageView alloc]initWithImage:micImage];
        microphoneView.frame = CGRectMake(0, 0, micImage.size.width, micImage.size.height);
        microphoneView.center = backgroundImageView.center;
        [self addSubview:microphoneView];
        
        //时间显示
        self.timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(kTimerLabelX, kTimerLabelY, kTimerLabelWidth, kTimerLabelHeight)];
        self.timerLabel.font = [UIFont systemFontOfSize:14];
        [self.timerLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRecordTimerColor]]];
        self.timerLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.timerLabel];
        
        //音量显示
        _powerViewPointX = microphoneView.center.x - kPowerViewMaxWidth / 2;
        self.powerValueView = [[UIView alloc]initWithFrame:CGRectMake(_powerViewPointX, _powerViewPointY,
                                                                      kPowerViewMaxWidth, 0)];
        self.powerValueView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelSelectedTextColor]];
        [self insertSubview:self.powerValueView belowSubview:microphoneView];
        
        //最长时间提示
        NSString *tip = @"最长可录60秒";
        CGSize tipSize = [tip sizeWithFont:[UIFont systemFontOfSize:28 / 2]];
        _timeTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeTipLabel.text = tip;
        _timeTipLabel.font = [UIFont systemFontOfSize:28 / 2];
        _timeTipLabel.size = tipSize;
        _timeTipLabel.center = self.center;
        _timeTipLabel.top = self.powerValueView.bottom + 7;
        _timeTipLabel.backgroundColor = [UIColor clearColor];
        _timeTipLabel.textColor = SNUICOLOR(kCommentTextTipColor);
        
        [self addSubview:_timeTipLabel];
        //录音按键
        UIImage *recordBtnImage = [UIImage themeImageNamed:@"userinfo_smallbutton.png"];
        if ([recordBtnImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            recordBtnImage = [recordBtnImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 20, 20)];
        }
        else {
            recordBtnImage = [recordBtnImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        }
        
        UIImage *recordBtnImageHL = [UIImage themeImageNamed:@"userinfo_smallbutton_hl.png"];
        if ([recordBtnImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            recordBtnImageHL = [recordBtnImageHL resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 10, 24)];
        }
        else {
            recordBtnImageHL = [recordBtnImageHL stretchableImageWithLeftCapWidth:0 topCapHeight:30];
        }
        
        self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.recordButton setBackgroundImage:recordBtnImage forState:UIControlStateNormal];
        [self.recordButton setBackgroundImage:recordBtnImageHL forState:UIControlStateHighlighted];
        [self.recordButton setTitle:NSLocalizedString(@"recordButtonDown", @"") forState:UIControlStateNormal];
        [self.recordButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoButtonFontColor]] forState:UIControlStateNormal];
        [self.recordButton addTarget:self action:@selector(recordButtonBegin:) forControlEvents:UIControlEventTouchDown];
        [self.recordButton addTarget:self action:@selector(recordButtonEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        self.recordButton.frame = CGRectMake(self.size.width / 2 - kRecordButtonWidth / 2, _timeTipLabel.bottom + 10,
                                             kRecordButtonWidth, kRecordButtonHeight);
        [self addSubview:self.recordButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
}

- (void)recordButtonBegin:(id)sender
{
    // 检查系统是否授权录音
    BOOL bHaveMicPermission = [SNSoundManager isMicrophoneEnabled];
    if (!bHaveMicPermission) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"MicrophoneForbidden", nil) toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    
    [[SNSoundManager sharedInstance] stopAmr];
    self.timerLabel.hidden = NO;
    [self.recordButton setTitle:NSLocalizedString(@"recordButtonUp", @"") forState:UIControlStateNormal];
    if (self.recordDelegate && [self.recordDelegate respondsToSelector:@selector(snRecordChangedBegin)]) {
        [self.recordDelegate performSelector:@selector(snRecordChangedBegin)];
    }
}

- (void)recordButtonEnd:(id)sender
{
    // 检查系统是否授权录音
    BOOL bHaveMicPermission = [SNSoundManager isMicrophoneEnabled];
    if (!bHaveMicPermission) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"MicrophoneForbidden", nil) toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }

    self.timerLabel.hidden = YES;
//    [self.recordButton setTitle:NSLocalizedString(@"recordButtonDown", @"") forState:UIControlStateNormal];
    if (self.recordDelegate && [self.recordDelegate respondsToSelector:@selector(snRecordChangedEnd)]) {
        [self.recordDelegate performSelector:@selector(snRecordChangedEnd)];
    }
}

- (void)powerValueChange:(float)avgPower 
{
    float h = kPowerViewMaxHeight / _maxPowerValue * avgPower * kRecordPowerModulus;
    h = MAX(0, MIN(h, kPowerViewMaxHeight));
    CGRect frame = CGRectMake(_powerViewPointX, _powerViewPointY - h, kPowerViewMaxWidth, h);
    
    [UIView animateWithDuration:0.2 animations:^(void){
        self.powerValueView.frame = frame;
    }];
}

@end
