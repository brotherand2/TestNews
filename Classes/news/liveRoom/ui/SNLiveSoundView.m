//
//  SNLiveSoundView.m
//  sohunews
//
//  Created by chenhong on 13-4-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveSoundView.h"
#import "SNLiveContentObjects.h"
#import "UIColor+ColorUtils.h"
#import "SNThemeManager.h"
#import "SNLiveRoomConsts.h"
#import "SNLiveBannerView.h"
#import "ASIHTTPRequest.h"
#import "SNPickStatisticRequest.h"

//#import "NSString+URLEncoding.h"
#import "SNWaitingActivityView.h"

#define MIN_W (140/2)
#define MAX_W (400/2)

#define DEBUG_SOUNDVIEW 0

@interface SNLiveSoundView () {
    UIImageView *_bar;
    double _startTime;
}

@end

@implementation SNLiveSoundView
@synthesize url, duration;
@synthesize commentID = _commentID;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [SNNotificationManager addObserver:self selector:@selector(onSoundDownloaded:) name:kSoundDownloaded object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onSoundPlayFinished:) name:kSoundPlayFinished object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onSoundStatusChanged:) name:kSoundPlayStatusChanged object:nil];
        
        
    }
    return self;
}

- (void)loadIfNeeded {
    if (_bar) {
        return;
    }

    CGRect frame = self.frame;
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, frame.size.height)];
    bg.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    bg.userInteractionEnabled = YES;
    UIImage *img = [UIImage imageNamed:@"live_sound_btn.png"];
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        bg.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    }
    else {
        bg.image = [img stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    [self addSubview:bg];
    _bar = bg;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBtn)];
    [bg addGestureRecognizer:tap];
    
    // 喇叭动画
    UIImage *snd1 = [UIImage imageNamed:@"live_snd1.png"];
    UIImage *snd2 = [UIImage imageNamed:@"live_snd2.png"];
    UIImage *snd3 = [UIImage imageNamed:@"live_snd3.png"];
    UIImage *snd4 = [UIImage imageNamed:@"live_snd4.png"];
    
    _speaker = [[UIImageView alloc] initWithFrame:CGRectMake(8, (frame.size.height - snd1.size.height)/2, snd1.size.width, snd1.size.height)];
    _speaker.image = snd4;
    _speaker.animationImages = [NSArray arrayWithObjects:snd1, snd2, snd3, snd4, nil];
    _speaker.animationDuration = 1;
    [self addSubview:_speaker];
    
#if DEBUG_SOUNDVIEW
    // 状态label
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 100, frame.size.height)];
    _statusLabel.textAlignment = NSTextAlignmentLeft;
    _statusLabel.font = [UIFont systemFontOfSize:10];
    _statusLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kReplyAuthorNameColor]];
    _statusLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_statusLabel];
    [_statusLabel release];
#endif
    
    // 时长Label
    _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(bg.right + 6, 0, 60, frame.size.height)];
    _durationLabel.textAlignment = NSTextAlignmentLeft;
    _durationLabel.font = [UIFont systemFontOfSize:10];
    _durationLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kReplyAuthorNameColor]];
    _durationLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_durationLabel];
    
    _indicator = [[SNWaitingActivityView alloc] init];

    [self addSubview:_indicator];
    
    _errorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _errorView.image = [UIImage imageNamed:@"audio_error.png"];
    _errorView.hidden = YES;
    [self addSubview:_errorView];
}

- (void)updateTheme {
    UIImage *img = [UIImage imageNamed:@"live_sound_btn.png"];
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _bar.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    }
    else {
        _bar.image = [img stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    
    // 喇叭动画
    UIImage *snd1 = [UIImage imageNamed:@"live_snd1.png"];
    UIImage *snd2 = [UIImage imageNamed:@"live_snd2.png"];
    UIImage *snd3 = [UIImage imageNamed:@"live_snd3.png"];
    UIImage *snd4 = [UIImage imageNamed:@"live_snd4.png"];
    
    _speaker.image = snd4;
    _speaker.animationImages = [NSArray arrayWithObjects:snd1, snd2, snd3, snd4, nil];
    
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kReplyAuthorNameColor];
    //_statusLabel.textColor = [UIColor colorFromString:strColor];
    _durationLabel.textColor = [UIColor colorFromString:strColor];
    
    _errorView.image = [UIImage imageNamed:@"audio_error.png"];
    
    [_indicator updateTheme];
}

- (void)setBackgroundWithImage:(UIImage *) backgroundImage{
    
    if ([backgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _bar.image = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    }
    else {
        _bar.image = [backgroundImage stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    if (_commentID) {
         //(_commentID)
    }
     //(_liveId);
}

- (void)setFrame:(CGRect)frame {
    float w = [self getBarWidthByDuration:duration];
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, w, frame.size.height)];
//    _speaker.frame = CGRectMake(8, (frame.size.height - 18)/2, 12, 18);
//    _statusLabel.frame = CGRectMake(32, 0, 100, frame.size.height);
//    _durationLabel.frame = CGRectMake(_bar.right + 6, 0, 60, frame.size.height);

    [self relayoutSubviews];
}

/*
- (void)setUrl:(NSString *)url_ {
    if (url != url_) {
        [url release];
        url = [url_ retain];
    }
    
    if (url.length > 0) {
        SNSoundStatusType status = [[SNSoundManager sharedInstance] statusForSoundUrl:url];
        [self setStatus:status];
    }
}
*/

- (void)setDuration:(int)duration_ {
    duration = duration_;
//    if (duration > 0) {
//        if (duration > 60) {
//            _durationLabel.text = [NSString stringWithFormat:@"%d'%d''", duration/60, duration%60];
//        } else {
//            _durationLabel.text = [NSString stringWithFormat:@"%d''", duration];
//        }
//    } else {
//        _durationLabel.text = nil;
//    }
    if (duration <= 0) {
        duration = 1;
    }
    
    if (duration > 0) {
        NSString *minutes = [NSString stringWithFormat:@"%02d",duration/60];
        NSString *seconds = [NSString stringWithFormat:@"%02d",duration%60];
        _durationLabel.text = [NSString stringWithFormat:@"%@:%@", minutes,seconds];
    } else {
        _durationLabel.text = @"";
    }
    
    self.width = [self getBarWidthByDuration:duration];
}

#if DEBUG_SOUNDVIEW
- (void)setCommentID:(NSString *)commentID {
    [_commentID autorelease];
    _commentID = [commentID copy];
    _statusLabel.text = commentID;
}
#endif

- (int)getBarWidthByDuration:(float)dur {
    float w = MIN_W + dur/60.0f*(MAX_W - MIN_W);
    if (w > MAX_W) {
        w = MAX_W;
    } else if (w < MIN_W) {
        w = MIN_W;
    }
    return (int)(w + 0.5f);
}

- (void)relayoutSubviews {
    CGSize durationSize = [_durationLabel.text sizeWithFont:[UIFont systemFontOfSize:10.0]];
    
    _durationLabel.frame = CGRectMake(10, 0-1, durationSize.width, self.frame.size.height);
    _speaker.frame = CGRectMake(10 + durationSize.width +5, (self.frame.size.height - 18)/2-1, 12, 18);
    _indicator.center = CGPointMake(self.width + 15, _speaker.centerY);
    _errorView.center = CGPointMake(self.width + 15, _speaker.centerY);
#if DEBUG_SOUNDVIEW
    _statusLabel.frame = CGRectMake(10 + durationSize.width +5 +12 +5, 0, 100, self.frame.size.height);
#endif
    _bar.width = [self getBarWidthByDuration:duration];
}

- (void)setStatus:(SNSoundStatusType)status {
    _soundStatus = status;
    switch (status) {
        case SNSoundStatusDefault:
            //_statusLabel.hidden = YES;
            _errorView.hidden = YES;
            [_speaker stopAnimating];
            [_indicator stopAnimating];
            break;
            
        case SNSoundStatusPlaying:
            //_statusLabel.hidden = YES;
            _errorView.hidden = YES;
            [_speaker startAnimating];
            [_indicator stopAnimating];
            break;
            
        case SNSoundStatusDownloading:
            //_statusLabel.hidden = NO;
            _errorView.hidden = YES;
            //_statusLabel.text = @"加载中...";
            [_speaker stopAnimating];
            [_indicator startAnimating];
            break;
            
        case SNSoundStatusDownloadFailed:
            //_statusLabel.hidden = NO;
            _errorView.hidden = NO;
            //_statusLabel.text = @"点击重新加载";
            [_speaker stopAnimating];
            [_indicator stopAnimating];
            break;
            
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

- (void)onSoundPlayFinished:(NSNotification*)notification {
    if (url) {
        NSDictionary* userInfo = (NSDictionary*)notification.object;
        
        NSString *tag = [[TTURLCache sharedCache] keyForURL:url];
        NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
        
        if ([sndId isEqualToString:[userInfo objectForKey:@"id"]]) {
            if ([NSThread isMainThread]) {
                [self setStatus:SNSoundStatusDefault];
                [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setStatus:SNSoundStatusDefault];
                    [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
                });
            }
        }
    }
    [self reportPlayingTime];
}

- (void)stopSoundPlay
{
    [self setStatus:SNSoundStatusDefault];
    [[SNSoundManager sharedInstance] stopByUrl:url];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
    [self reportPlayingTime];
}

- (BOOL)isSameCommentId{
    BOOL isSame;
    if ([SNSoundManager sharedInstance].playCommentId && _commentID) {
        // 不能确保commentId一定为NSString，可能为NSNumber，所以都转为longlong比较
        if ([[SNSoundManager sharedInstance].playCommentId longLongValue] == [_commentID longLongValue]) {
            isSame = YES;
        }else{
            isSame = NO;
        }
    }else{
        isSame = NO;
        if (![SNSoundManager sharedInstance].playCommentId && !_commentID) {
            isSame = YES;
        }
    }
    return isSame;
}

- (void)setUrl:(NSString *)url_ {
    if (url != url_) {
        url = url_;
    }
    
    if (url.length > 0) {
        SNSoundStatusType status = [[SNSoundManager sharedInstance] statusForSoundUrl:url];
        if (status == SNSoundStatusPlaying && ![self isSameCommentId]) {
            status = SNSoundStatusDefault;
        }
        [self setStatus:status];
    }
}

- (void)clickBtn{
    
    if (url.length > 0) {
        
        NSString *localPath = [SNSoundManager soundFileDownloadPathWithURL:url];
        
        // mp3在线播放不下载
        BOOL bMP3 = [url hasSuffix:@".mp3"];
        
        if (!bMP3 && ![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            SNSoundItem *sndItem = [[SNSoundItem alloc] init];
            sndItem.url = url;
            sndItem.localPath = localPath;
            
            [[SNSoundManager sharedInstance] stopAll];
            
            if (![[SNSoundManager sharedInstance] isSoundItemDownloading:sndItem]) {
                [[SNSoundManager sharedInstance] cancelAllDownloads];
                [[SNSoundManager sharedInstance] downloadSoundItem:sndItem];
                [self setStatus:SNSoundStatusDownloading];
                [SNNotificationManager postNotificationName:kSNLiveBannerViewPauseVideoNotification object:nil];
                [SNSoundManager sharedInstance].playCommentId = _commentID;
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:sndItem];
            } else {
                
                [[SNSoundManager sharedInstance] cancelAllDownloads];
                [self setStatus:SNSoundStatusDefault];
                [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
                [SNSoundManager sharedInstance].playCommentId = nil;
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
            }
            
        } else {
            [[SNSoundManager sharedInstance] cancelAllDownloads];
            
            SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundUrl:url];
            
            if (sndStatus == SNSoundStatusPlaying && [self isSameCommentId]) {
                [self setStatus:SNSoundStatusDefault];
                [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
                
                [[SNSoundManager sharedInstance] stopAll];
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
                [SNSoundManager sharedInstance].playCommentId = nil;
                
            } else {
                SNSoundItem *sndItem = [[SNSoundItem alloc] init];
                sndItem.url = url;
                sndItem.localPath = localPath;
                [SNSoundManager sharedInstance].playCommentId = _commentID;
                BOOL bOK = [[SNSoundManager sharedInstance] playSound:sndItem];
                if (bOK) {
                    [SNNotificationManager postNotificationName:kSNLiveBannerViewPauseVideoNotification object:nil];
                    [self setStatus:bMP3?SNSoundStatusDownloading:SNSoundStatusPlaying];
                    _startTime = [[NSDate date] timeIntervalSince1970];
                    
                } else {
                    [self setStatus:SNSoundStatusDefault];
                    [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
                    
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"无法播放该音频" toUrl:nil mode:SNCenterToastModeWarning];
                    
                    // 删除无法播放的本地文件
//                    [ASIHTTPRequest removeFileAtPath:localPath error:nil];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                        NSError *removeError = nil;
                        [[NSFileManager defaultManager] removeItemAtPath:localPath error:&removeError];
                    }
                }
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
            }
        }
    }
}

- (void)onSoundDownloaded:(NSNotification*)notification{
    
    if (url) {
        SNSoundItem *nextToPlayItem = [SNSoundManager sharedInstance].sndItemNextToPlay;
        if (nextToPlayItem && [nextToPlayItem.url isEqualToString:url] && [self isSameCommentId]) {
            NSDictionary* userInfo = (NSDictionary*)notification.object;
            
            NSString *tag = [[TTURLCache sharedCache] keyForURL:url];
            NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
            
            if ([sndId isEqualToString:[userInfo objectForKey:@"id"]]) {
                NSString *localPath = [SNSoundManager soundFileDownloadPathWithURL:url];
                if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                    SNSoundItem *sndItem = [[SNSoundItem alloc] init];
                    sndItem.url = url;
                    sndItem.localPath = localPath;
                    SNDebugLog(@"onSoundDownloaded: %@, %@", self, localPath);
                    SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundItem:sndItem];
                    
                    BOOL bOK = NO;
                    if (sndStatus == SNSoundStatusPlaying) {
                        bOK = YES;
                    } else {
                        bOK = [[SNSoundManager sharedInstance] playSound:sndItem];
                    }
                    
                    if (bOK) {
                        [self setStatus:SNSoundStatusPlaying];
                        [SNNotificationManager postNotificationName:kSNLiveBannerViewPauseVideoNotification object:nil];
                        [SNSoundManager sharedInstance].playCommentId = _commentID;
                        _startTime = [[NSDate date] timeIntervalSince1970];
                    } else {
                        [self setStatus:SNSoundStatusDefault];
                        [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"无法播放该音频" toUrl:nil mode:SNCenterToastModeWarning];
                    }
                } else {
                    [self setStatus:SNSoundStatusDownloadFailed];
                    [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
                    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"无网络连接，无法播放该音频" toUrl:nil mode:SNCenterToastModeWarning];
                    }
                }
            }
        }
    }
}

- (void)onSoundStatusChanged:(NSNotification*)notification{
    if (url) {
        if ([NSThread isMainThread]) {
            SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundUrl:url];
            if ([self isSameCommentId]) {
                [self setStatus:sndStatus];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundUrl:url];
                if ([self isSameCommentId]) {
                    [self setStatus:sndStatus];
                }
            });
        }
    }
}

- (void)reportPlayingTime
{
    double endTime = [[NSDate date] timeIntervalSince1970];
    double interval = endTime - _startTime;
    if(_liveId && url)
    {
//        NSString* urlString = [SNAPI nDotGifUrlPrefixWithParameters:[NSString stringWithFormat:@"objType=n_voice_play&liveId=%@&plays=%f&audurl=%@",_liveId, interval, [url URLEncodedString]]];
//        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
//        request.requestMethod = @"GET";
//        request.shouldContinueWhenAppEntersBackground = YES;
//        [request startAsynchronous];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
        [params setValue:@"n_voice_play" forKey:@"objType"];
        [params setValue:_liveId forKey:@"liveId"];
        [params setValue:[NSString stringWithFormat:@"%f",interval] forKey:@"plays"];
        [params setValue:[url URLEncodedString] forKey:@"audurl"];
        [[[SNPickStatisticRequest alloc] initWithDictionary:params
                                           andStatisticType:PickLinkDotGifTypeN] send:nil failure:nil];
    }
}

@end
