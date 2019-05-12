//
//  SNNewsSpeakerView.m
//  sohunews
//
//  Created by weibin cheng on 14-6-18.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsSpeakerView.h"
#import "SNNewsSpeaker.h"
#import "SNAppConfigManager.h"
#import "SNAppConfigVoiceCloud.h"

#import "SNThemeManager.h"


@implementation SNNewsSpeakerView
@synthesize closeBlock = _closeBlock;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat height = 0;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(47, height, self.frame.size.width-94, 26)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:kThemeFontSizeF];
        label.text = @"当前播放";
        [self addSubview:label];
        
        height += 26 + 29;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, height, self.frame.size.width-94, 44)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [self addSubview:_titleLabel];
        
        height += 38 + 44;
        CGFloat buttonHeight = height + 26;
        
        _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previousButton.frame = CGRectMake(30, buttonHeight, 39, 39);
        [_previousButton setBackgroundImage:[UIImage themeImageNamed:@"news_speaker_previous_normal.png"] forState:UIControlStateNormal];
        [_previousButton setBackgroundImage:[UIImage themeImageNamed:@"news_speaker_previous_highlight.png"] forState:UIControlStateHighlighted];
        [_previousButton addTarget:self action:@selector(onClickPrevious) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:_previousButton];
        
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat xValule = (frame.size.width - 40 )/2;
        _pauseButton.frame = CGRectMake(xValule, height - 10, 40, 40);
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_pause_v5.png"] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_pausepress_v5.png"] forState:UIControlStateHighlighted];
        [_pauseButton addTarget:self action:@selector(onClickPause) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pauseButton];
        
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(320-39-30, buttonHeight, 39, 39);
        [_nextButton setBackgroundImage:[UIImage themeImageNamed:@"news_speaker_next_normal.png"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage themeImageNamed:@"news_speaker_next_highlight.png"] forState:UIControlStateHighlighted];
        [_nextButton addTarget:self action:@selector(onClickNext) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:_nextButton];
        
        [SNNewsSpeaker shareSpeaker].delegate = self;
        
        //sdk链接信息
        NSString *description = [[SNAppConfigManager sharedInstance] voiceCloudConfig].theCopyWriting;
        CGSize size = [description sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
        BOOL isOpen = [[SNAppConfigManager sharedInstance] voiceCloudConfig].isOpen;
        
        UIButton *sdkLinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sdkLinkBtn.backgroundColor = [UIColor clearColor];
        [sdkLinkBtn setTitle:description forState:UIControlStateNormal];
        [sdkLinkBtn setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
        sdkLinkBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        sdkLinkBtn.size = CGSizeMake(size.width, size.height+10);
        sdkLinkBtn.bottom = self.height - 5;
        sdkLinkBtn.centerX = self.centerX;
        [sdkLinkBtn addTarget:self action:@selector(clickLink:) forControlEvents:UIControlEventTouchUpInside];
        sdkLinkBtn.hidden = !isOpen;
        
        [self addSubview:sdkLinkBtn];
        
        [self becomeFirstResponder];
    }
    return self;
}

- (void)dealloc
{
    [SNNewsSpeaker shareSpeaker].delegate = nil;
     //(_titleLabel);
     //(_previousButton);
     //(_pauseButton);
     //(_nextButton);
     //(_closeBlock);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)onClickClose
{
    if(_closeBlock)
    {
        _closeBlock();
    }
}

- (void)onClickPrevious
{
    if ([self checkNetworkIsEnableAndTell:YES]) {
        [[SNNewsSpeaker shareSpeaker] speakPrevious];
    }
}

- (void)onClickPause
{
    if ([self checkNetworkIsEnableAndTell:YES]) {
        [[SNNewsSpeaker shareSpeaker] playOrPause];
    }
}

- (void)onClickNext
{
    if ([self checkNetworkIsEnableAndTell:YES]) {
        [[SNNewsSpeaker shareSpeaker] speakNext];
    }
}

#pragma mark SNNewsSpeakerDelegate

- (void)newsSpeakerContentDidChanged:(NSString*)title isFirst:(BOOL)first isEnd:(BOOL)end
{
    _titleLabel.text = title;
    if(first)
    {
        _previousButton.alpha = 0.3;
        _previousButton.enabled = NO;
    }
    else
    {
        _previousButton.alpha = 1.0;
        _previousButton.enabled = YES;
    }
    if(end)
    {
        _nextButton.alpha = 0.3;
        _nextButton.enabled = NO;
    }
    else
    {
        _nextButton.alpha = 1.0;
        _nextButton.enabled = YES;
    }
}

- (void)newsSpeakerStateDidChanged
{
    SNNewsSpeakerState state = [SNNewsSpeaker shareSpeaker].state;
    if(state == SNNewsSpeakerStateWorking)
    {
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_pause_v5.png"] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_pausepress_v5.png"] forState:UIControlStateHighlighted];
    }
    else if(state == SNNewsSpeakerStatePaused)
    {
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_play_v5.png"] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_playpress_v5.png"] forState:UIControlStateHighlighted];
    }
    else if(state == SNNewsSpeakerStateStopped)
    {
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_play_v5.png"] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[UIImage themeImageNamed:@"icofloat_playpress_v5.png"] forState:UIControlStateHighlighted];
    }
}

- (void)newsSpeakerDidFinished
{
//    [self showToast:@"语音新闻已播放完毕"];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"语音新闻已播放完毕" toUrl:nil mode:SNCenterToastModeOnlyText];
}

- (void)newsSpeakerDidFailed:(IFlySpeechError*)error
{
    if (error.errorCode == SNListenNewsErrorNoNetWork)
    {
//        [self showToast:@"暂无法连接网络"];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    switch (error.errorCode)
    {
        case SNListenNewsErrorNoNetWork:
        case SNListenNewsErrorTimeOut:
        {
//            [self showToast:@"暂无法连接网络"];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            break;
        }
        default:
//            [self showToast:@"暂无法播放语音"];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法播放语音" toUrl:nil mode:SNCenterToastModeWarning];
            break;
    }
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)clickLink:(id)sender
{
    if(_closeBlock)
    {
        _closeBlock();
    }
    NSString *url = [[SNAppConfigManager sharedInstance] voiceCloudConfig].url;
    [SNUtility openProtocolUrl:url];
}

#pragma mark- privateFunc
- (void)showToast:(NSString *)message
{
//    CGPoint toastPoint = CGPointMake(kAppScreenWidth / 2, kAppScreenHeight - 25);
//    [[TTNavigator navigator].window  makeToast:message
//                                         image:nil
//                                      duration:2.0
//                                      position:[NSValue valueWithCGPoint:toastPoint]];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:message toUrl:nil mode:SNCenterToastModeOnlyText];
}

- (BOOL)checkNetworkIsEnableAndTell:(BOOL)showMsg {
    BOOL bRet = YES;
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        bRet = NO;
        if (showMsg) {
//            [SNNotificationCenter showExclamation:NSLocalizedString(SN_String("network error"), @"")];
            [self showToast:NSLocalizedString(SN_String("network error"), @"")];
        }
    }
    return bRet;
}

#pragma mark - Remote control
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    SNDebugLog(@"type = %d, subType = %d", receivedEvent.type, receivedEvent.subtype);
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause: {
                if (self.delegate) {
                    [self.delegate remoteControlPauseOrPlay];
                }
                break;
            }
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:{
                if (self.delegate) {
                    [self.delegate remoteControlPreviousTrack];
                }
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:{
                if (self.delegate) {
                    [self.delegate remoteControlNextTrack];
                }
                break;
            }
            default:
                break;
        }
    }
}

@end
