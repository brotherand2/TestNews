//
//  SNNewsCommentSoundView.m
//  sohunews
//
//  Created by 赵青 on 2017/3/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsCommentSoundView.h"
#import "SNLiveContentObjects.h"
#import "UIColor+ColorUtils.h"
#import "SNThemeManager.h"
#import "SNLiveBannerView.h"
#import "ASIHTTPRequest.h"
#import "SNPickStatisticRequest.h"

#import "SNWaitingActivityView.h"

#define MIN_W (140/2)
#define MAX_W (400/2)

@interface SNNewsCommentSoundView () {
    UIImageView *_bar;
    double _startTime;
}

@end

@implementation SNNewsCommentSoundView
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
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 128/2, 68/2)];
    bg.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    bg.userInteractionEnabled = YES;
    UIImage *img = [UIImage imageNamed:@"icopl_bg_v5.png"];
    bg.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [self addSubview:bg];
    _bar = bg;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBtn)];
    [bg addGestureRecognizer:tap];
    
    // 喇叭动画
    UIImage *snd1 = [UIImage imageNamed:@"icopl_yi2_v5.png"];
    UIImage *snd2 = [UIImage imageNamed:@"icopl_yi3_v5.png"];
    UIImage *snd3 = [UIImage imageNamed:@"icopl_yi4_v5.png"];
    UIImage *snd4 = [UIImage imageNamed:@"icopl_yi4_v5.png"];
    
    _speaker = [[UIImageView alloc] initWithFrame:CGRectMake(8, (frame.size.height - snd1.size.height)/2, snd1.size.width, snd1.size.height)];
    _speaker.image = snd4;
    _speaker.animationImages = [NSArray arrayWithObjects:snd1, snd2, snd3, snd4, nil];
    _speaker.animationDuration = 1;
    [self addSubview:_speaker];
    
    // 时长Label
    _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(bg.right + 6, 0, 20, frame.size.height)];
    _durationLabel.textAlignment = NSTextAlignmentLeft;
    _durationLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    _durationLabel.textColor = SNUICOLOR(kThemeText8Color);
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
    UIImage *img = [UIImage imageNamed:@"icopl_bg_v5.png"];
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _bar.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    }
    else {
        _bar.image = [img stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    
    // 喇叭动画
    UIImage *snd1 = [UIImage imageNamed:@"icopl_yi2_v5.png"];
    UIImage *snd2 = [UIImage imageNamed:@"icopl_yi3_v5.png"];
    UIImage *snd3 = [UIImage imageNamed:@"icopl_yi4_v5.png"];
    UIImage *snd4 = [UIImage imageNamed:@"icopl_yi4_v5.png"];
    
    _speaker.image = snd4;
    _speaker.animationImages = [NSArray arrayWithObjects:snd1, snd2, snd3, snd4, nil];
    
    _durationLabel.textColor = SNUICOLOR(kThemeText8Color);
    
    _errorView.image = [UIImage imageNamed:@"audio_error.png"];
    
    [_indicator updateTheme];
}

- (void)setBackgroundWithImage:(UIImage *) backgroundImage{
    _bar.image = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setDuration:(int)duration_ {
    duration = duration_;
        if (duration <= 0) {
        duration = 1;
    }
    
    if (duration > 0) {
        _durationLabel.text = [NSString stringWithFormat:@"%d\"",duration];
    } else {
        _durationLabel.text = @"";
    }
    if (_bar) {
        [self relayoutSubviews];
    }
}

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
    CGSize durationSize = [_durationLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]];
    
    _durationLabel.frame = CGRectMake(16, 0, durationSize.width, self.frame.size.height);
    _speaker.frame = CGRectMake(16 + durationSize.width + 12, (self.frame.size.height - 17)/2, 23.0/2, 34/2);
    _indicator.center = CGPointMake(self.width + 15, _speaker.centerY);
    _errorView.center = CGPointMake(self.width + 15, _speaker.centerY);
    _bar.width = _speaker.right + 14;
    self.width = _bar.width;
}

- (void)setStatus:(SNSoundStatusType)status {
    _soundStatus = status;
    switch (status) {
        case SNSoundStatusDefault:
            _errorView.hidden = YES;
            [_speaker stopAnimating];
            [_indicator stopAnimating];
            break;
            
        case SNSoundStatusPlaying:
            _errorView.hidden = YES;
            [_speaker startAnimating];
            [_indicator stopAnimating];
            break;
            
        case SNSoundStatusDownloading:
            _errorView.hidden = YES;
            [_speaker stopAnimating];
            [_indicator startAnimating];
            break;
            
        case SNSoundStatusDownloadFailed:
            _errorView.hidden = NO;
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
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
        [params setValue:@"n_voice_play" forKey:@"objType"];
        [params setValue:_liveId forKey:@"liveId"];
        [params setValue:[NSString stringWithFormat:@"%f",interval] forKey:@"plays"];
        [params setValue:[url URLEncodedString] forKey:@"audurl"];
        [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeN] send:nil failure:nil];
    }
}

@end
