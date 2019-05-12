//
//  SNRollingTrainPGCVideoCell.m
//  sohunews
//
//  Created by HuangZhen on 2017/11/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainPGCVideoCell.h"
#import "SNRollingNewsTableItem.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNRollingTrainCellConst.h"

@implementation SNRollingTrainPGCVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGRect cellContentViewFrame = CGRectMake(0, 0, self.width, self.height);
        _autoPlayCellContentView = [[SNAutoPlayVideoContentView alloc] initWithFrame:cellContentViewFrame];
        _autoPlayCellContentView.clipsToBounds = YES;
        _autoPlayCellContentView.layer.cornerRadius = kTrainCardCornerRadius;
        [self insertSubview:_autoPlayCellContentView aboveSubview:self.cellImageView];
        [_autoPlayCellContentView addMaskView:self.maskShadow];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _isPlaying = NO;
}

- (void)updateTheme {
    [super updateTheme];
//    [self resetCoverInfo];
    UIImage* defaultImage = [UIImage themeImageNamed:@"icohome_cardzwtsp_v5.png"];
    [self.cellImageView updateImageWithUrl:self.news.picUrl defaultImage:defaultImage showVideo:NO];
    [self.cellImageView updateTheme];
    [self updateVideoData];
    [_autoPlayCellContentView updateTheme];
    [_autoPlayCellContentView layoutCountDownCenterY:self.commentLabel.centerY];
}
- (void)cellIsDisplaying {
    [super cellIsDisplaying];
    CGRect frame = [self convertRect:self.bounds toView:nil];
    if (frame.origin.x + frame.size.width > kAppScreenWidth || frame.origin.x < 0) {
        _isPlaying = NO;
        [self resetCoverInfo];
    }
}

- (void)cellFullDisplaying {
    [super cellFullDisplaying];
}

- (void)cellDidEndDisplaying {
    [super cellDidEndDisplaying];
    _isPlaying = NO;
    [self resetCoverInfo];
}

- (void)updateVideoData {
    if (nil == _playerData) {
        _playerData = [[SNVideoData alloc] init];
    }
    [_autoPlayCellContentView settingPlayButton];
    if (self.news.picUrl &&
        ![self.news.picUrl isKindOfClass:[NSNull class]]) {
        _playerData.poster = self.news.picUrl;
        _playerData.poster_4_3 = self.news.picUrl;
    }
    _playerData.vid = self.news.playVid;
    _playerData.videoUrl = [[SNVideoUrl alloc] init];
    _playerData.isNewsVideo = YES;
//    _playerData.isRecommend = self.news.isRecommend;
    //视频样式
    _playerData.templateType = kNewsTypeRollingBigVideo;
    _playerData.recomInfo = self.news.recomInfo;
    if (self.news.tvPlayTime) {
        _playerData.duration = [self.news.tvPlayTime integerValue];
    }
    SNVideoSiteInfo *siteinfo = [[SNVideoSiteInfo alloc] init];
    siteinfo.site2 = [NSString stringWithFormat:@"%d", self.news.siteValue];
    if (nil == siteinfo.site2 || siteinfo.site2.length <= 0) {
        siteinfo.site2 = @"2";
    }
    siteinfo.playById = @"1";
    siteinfo.siteId = self.news.playVid;
    siteinfo.playAd = @"0";
    _playerData.siteInfo = siteinfo;
    
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    
    [_autoPlayCellContentView setObject:_playerData];
    //视频样式
    [_autoPlayCellContentView setPlayStyle:AutoPlayStyleBigImage];
    
    //如果需要重新设置Frame
    [_autoPlayCellContentView resetPlayerViewFrame:self.bounds];
    //不Reset的话需要设置封面图
//    [_autoPlayCellContentView setPosterImage];
}

- (void)autoPlay {
    SNAutoPlaySharedVideoPlayer *autoPlayer = [SNAutoPlaySharedVideoPlayer sharedInstance];
    SNTimelineSharedVideoPlayerView *timelinePlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    
    if (![[autoPlayer getMoviePlayer].currentPlayMedia.vid isEqualToString:self.news.playVid]) {
        [SNAutoPlaySharedVideoPlayer forceStopVideo];
    } else {
        return;
    }
    if (autoPlayer.moviePlayer) {
        _isPlaying = YES;
        [self resetCoverInfo];
        [self hideCoverInfoWithDelay:5];
        //如果有其他播放器, 停止
        if ([timelinePlayer getMoviePlayer].playbackState == SHMoviePlayStatePlaying) {
            [SNTimelineSharedVideoPlayerView forceStop];
        }
        [_autoPlayCellContentView autoPlayVideo];
        [_autoPlayCellContentView layoutCountDownCenterY:self.commentLabel.centerY];
    }
}

- (void)stopPlay {
    SNAutoPlaySharedVideoPlayer *play = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (_isPlaying || [play getMoviePlayer].playbackState == SHMoviePlayStatePlaying) {
        _isPlaying = NO;
        [self resetCoverInfo];
        [SNAutoPlaySharedVideoPlayer forceStopVideo];
        [_autoPlayCellContentView layoutCountDownCenterY:self.commentLabel.centerY];
    }
}

- (void)hideCoverInfoWithDelay:(int)delayTime {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.cellTitleLabel.alpha = 0;
            self.commentLabel.alpha = 0;
            self.mediaLabel.alpha = 0;
            self.maskShadow.alpha = 0;
        }];
    });
}

- (void)resetCoverInfo {
    self.cellTitleLabel.alpha = 1;
    self.commentLabel.alpha = 1;
    self.mediaLabel.alpha = 1;
    self.maskShadow.alpha = 1;
}

@end
