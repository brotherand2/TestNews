//
//  SNNewsSpeakerManager.m
//  sohunews
//
//  Created by weibin cheng on 14-6-19.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsSpeakerManager.h"
#import "SNNewsSpeaker.h"
#import "Toast+UIView.h"
#import "SNNewAlertView.h"

#define kHFLoginViewHeight ((kAppScreenWidth > 375.0) ? (934.0/3 - 45) : (542.0/2 - 45))
#define kHFCurrentPlay @"当前播放"
#define kHFLoginTextFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeD : kThemeFontSizeC)
#define kHFLoginTextLabelLeftDistance ((kAppScreenWidth > 375.0) ? 42.0/3 : 28.0/2)
#define kHFLoginTextLabelTopDistance ((kAppScreenWidth > 375.0) ? 36.0/3 : 26.0/2)
#define kHFViewLeftDistance (kAppScreenWidth == 320.0 ? 40.0/2 : (kAppScreenWidth == 375.0 ? 90.0/2 : 150.0/3))
#define kHFViewButtonTopDistance ((kAppScreenWidth > 375.0) ? 100.0/3 : 60.0/2)
#define kHFViewButtonWidth (kAppScreenWidth - kHFViewLeftDistance*2)/2
#define kHFViewButtonHeight (kHFViewButtonFontSize + 3)
#define kHFViewTextLabelTop (kHFViewHeight - kHFViewTextLabelHeight - kHFViewButtonHeight - kHFViewButtonTopDistance)/2
#define kHFPlayTextBottomDistance ((kAppScreenWidth > 375.0) ? 72.0/3 : 44.0/2)
#define kHFViewAreaWidth (kAppScreenWidth - kHFViewLeftDistance*2)
#define kHFViewButtonFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeF : kThemeFontSizeE)
#define kHFViewHeight ((kAppScreenWidth > 375.0) ? 610.0/3 : 370.0/2)
#define kHFViewBetweenTextLableDistance ((kAppScreenWidth > 375.0) ? 10.0/3 : 5.0/2)
#define kHFViewTextLabelHeight ((kThemeFontSizeE + 3.0)*2 + kHFViewBetweenTextLableDistance)

@interface SNNewsSpeakerManager () <SNNewAlertViewDelegate,SNNewsSpeakerDelegate>

@property (nonatomic, strong) SNNewAlertView *voiceAlertView;
@property (nonatomic, strong) UILabel *voiceTitle;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation SNNewsSpeakerManager


+ (SNNewsSpeakerManager*)shareManager
{
    static SNNewsSpeakerManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNNewsSpeakerManager alloc] init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if(self) {
        [SNNotificationManager addObserver:self selector:@selector(PalyNextNewsNotificationCenter) name:kPalyNextNewsNotification object:nil];
        [SNNewsSpeaker shareSpeaker].delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

- (void)showNewsSpeakerViewWithList:(NSArray *)newsList
{
    self.voiceAlertView = [[SNNewAlertView alloc] initWithContentView:[self voiceFloatView] cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    self.voiceAlertView.delegate = self;
    [self.voiceAlertView show];
    
    [[SNNewsSpeaker shareSpeaker] startSpeaking:newsList];
    
    if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在非wifi环境播放语音新闻" toUrl:nil mode:SNCenterToastModeWarning];
    }
}


- (void)closeNewsSpeakerView
{
    [[SNNewsSpeaker shareSpeaker] stop];
}

#pragma mark - speakerRemoteControlDelegate
- (void)remoteControlPauseOrPlay
{
    [[SNNewsSpeaker shareSpeaker] playOrPause];
}

- (void)remoteControlPreviousTrack
{
    if (![[SNNewsSpeaker shareSpeaker] isFirst]) {
        [[SNNewsSpeaker shareSpeaker] speakPrevious];
    }
}

- (void)remoteControlNextTrack
{
    if (![[SNNewsSpeaker shareSpeaker] isEnd]) {
        [[SNNewsSpeaker shareSpeaker] speakNext];
    }
}

- (void)PalyNextNewsNotificationCenter{
//    [self.halfFloatView resetVoiceTitle:[SNNewsSpeaker shareSpeaker].currentNewsTitle];
    self.voiceTitle.text = [SNNewsSpeaker shareSpeaker].currentNewsTitle;
}

#pragma mark - Create voice float view
- (UIView *)voiceFloatView {
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHFLoginViewHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:kHFLoginTextFontSize];
    titleLabel.text = kHFCurrentPlay;
    [titleLabel sizeToFit];
    titleLabel.left = kHFLoginTextLabelLeftDistance;
    titleLabel.top = kHFLoginTextLabelTopDistance;

    titleLabel.textColor = SNUICOLOR(kThemeText3Color);
    [bgView addSubview:titleLabel];

    UILabel *voiceTitle = [[UILabel alloc] initWithFrame:CGRectMake(kHFViewLeftDistance, kHFViewTextLabelTop, kHFViewAreaWidth, kHFViewTextLabelHeight)];
    self.voiceTitle = voiceTitle;
    voiceTitle.backgroundColor = [UIColor clearColor];
    voiceTitle.text = [[SNNewsSpeaker shareSpeaker] currentNewsTitle];
    voiceTitle.textColor = SNUICOLOR(kThemeText2Color);
    voiceTitle.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    voiceTitle.textAlignment = NSTextAlignmentCenter;
    voiceTitle.numberOfLines = 0;
    [bgView addSubview:voiceTitle];
    
    CGFloat topDistance = voiceTitle.bottom + kHFPlayTextBottomDistance;
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"icofloat_pause_v5.png"] forState:UIControlStateNormal];
    [self.playButton sizeToFit];
    self.playButton.center = bgView.center;
    self.playButton.tag = 0;
    self.playButton.top = topDistance;
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.playButton];
    
    NSString *title = [[SNAppConfigManager sharedInstance] voiceCloudConfig].theCopyWriting;
    UIButton *downLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downLoadButton setTitle:title forState:UIControlStateNormal];
    downLoadButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    [downLoadButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    [downLoadButton sizeToFit];
    downLoadButton.center = bgView.center;
    downLoadButton.top = self.playButton.bottom + kHFPlayTextBottomDistance;
    [downLoadButton addTarget:self action:@selector(downLoadVoiceAssistant:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:downLoadButton];

    return bgView;
}

- (void)playAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        [button setImage:[UIImage imageNamed:@"icofloat_play_v5.png"] forState:UIControlStateNormal];
        button.tag = 1;
    }
    else {
        [button setImage:[UIImage imageNamed:@"icofloat_pause_v5.png"] forState:UIControlStateNormal];
        button.tag = 0;
    }
    [[SNNewsSpeaker shareSpeaker] playOrPause];
    
}

- (void)downLoadVoiceAssistant:(id)sender {
    [self.voiceAlertView dismiss];
    [[SNNewsSpeaker shareSpeaker] stop];
    NSString *url = [[SNAppConfigManager sharedInstance] voiceCloudConfig].url;
    [SNUtility openProtocolUrl:url];
    
}

#pragma mark - SNNewAlertViewDelegate

- (void)didDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex {
    [[SNNewsSpeaker shareSpeaker] pause];
}

- (void)willDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SNNewsSpeaker shareSpeaker] stop];
    });
}

#pragma mark SNNewsSpeakerDelegate

- (void)newsSpeakerContentDidChanged:(NSString*)title isFirst:(BOOL)first isEnd:(BOOL)end
{
    self.voiceTitle.text = title;
}

- (void)newsSpeakerStateDidChanged
{
    SNNewsSpeakerState state = [SNNewsSpeaker shareSpeaker].state;
    if(state == SNNewsSpeakerStateWorking)
    {
        [self.playButton setImage:[UIImage imageNamed:@"icofloat_pause_v5.png"] forState:UIControlStateNormal];
     }
    else if(state == SNNewsSpeakerStatePaused)
    {
        [self.playButton setImage:[UIImage imageNamed:@"icofloat_play_v5.png"] forState:UIControlStateNormal];
    }
    else if(state == SNNewsSpeakerStateStopped)
    {
        [self.playButton setImage:[UIImage imageNamed:@"icofloat_play_v5.png"] forState:UIControlStateNormal];
    }
}

- (void)newsSpeakerDidFinished
{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"语音新闻已播放完毕" toUrl:nil mode:SNCenterToastModeOnlyText];
}

- (void)newsSpeakerDidFailed:(IFlySpeechError*)error
{
    if (error.errorCode == SNListenNewsErrorNoNetWork)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    switch (error.errorCode)
    {
        case SNListenNewsErrorNoNetWork:
        case SNListenNewsErrorTimeOut:
        {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            break;
        }
        default:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法播放语音" toUrl:nil mode:SNCenterToastModeWarning];
            break;
    }
}


@end
