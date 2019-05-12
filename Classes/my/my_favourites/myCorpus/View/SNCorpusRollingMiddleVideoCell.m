//
//  SNCorpusRollingMiddleVideoCell.m
//  sohunews
//
//  Created by Scarlett on 16/6/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNCorpusRollingMiddleVideoCell.h"
#import "NSCellLayout.h"
#import "SNCellImageView.h"
#import "SNAutoPlayVideoContentView.h"

#define kTitleFont ((kAppScreenWidth > 375.0) ? kThemeFontSizeE : kThemeFontSizeD)

@interface SNCorpusRollingMiddleVideoCell () {
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    SNAutoPlayVideoContentView *_cellContentView;
    SNVideoData *_videoData;
}

@end

@implementation SNCorpusRollingMiddleVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgImageView = [[UIView alloc] init];
        bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self setSelectedBackgroundView:bgImageView];
        self.backgroundColor = [UIColor clearColor];
        [self setCellFrame];
        
        [self initSelectButton];
        [self initPhotoView];
        [self initTitleLabel];
        [self initTimeLabel];
    }
    return self;
}

#pragma mark init
- (void)initPhotoView {
    _cellContentView = [[SNAutoPlayVideoContentView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, (self.height-kMiddleVideoImageHeight)/2, kMiddleVideoImageWidth, kMiddleVideoImageHeight)];
    [_cellContentView updateTheme];
    _cellContentView.alpha = themeImageAlphaValue();
    [self addSubview:_cellContentView];
}

- (void)initTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*3 - _cellContentView.width,[SNUtility getNewsTitleFontSize]*3)];
        _titleLabel.left = _cellContentView.right + CONTENT_LEFT;
        _titleLabel.top = _cellContentView.top - 4.0;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
        if ([SNUtility shownBigerFont]) {
            _titleLabel.numberOfLines = 3;
        }
        else {
            _titleLabel.numberOfLines = 2;
        }
        _titleLabel.font = [SNUtility getNewsTitleFont];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
}

- (void)initTimeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*3 - _cellContentView.width,40)];
        _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
        _timeLabel.bottom = _cellContentView.bottom;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
        _timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
    }
}

- (void)setCellInfoWithUrl:(NSString *)url newsType:(NSString *)newsType title:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link videoID:(NSString *)videoID site:(NSString *)site tvPlayTime:(NSString *)tvPlayTime isItemSelected:(BOOL)isItemSelected {
    [self setPlayerVideoData:url link:link videoID:videoID site:site tvPlayTime:tvPlayTime];
    
    _titleLabel.text = title;
    CGSize titleSize = [time sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    _timeLabel.text = [NSDate relativelyDate:time];
    _timeLabel.height = titleSize.height;
    [self resetLabel];
    
    self.idsString = ids;
    self.linkString = link;
    if (isEditMode) {
        [self setEditMode];
    }
    else {
        [self setNormalMode];
    }
    _selectButton.centerY = self.height/2;
    _selectButton.selected = isItemSelected;
}

- (void)resetLabel {
    _titleLabel.font = [SNUtility getNewsTitleFont];
    if ([SNUtility shownBigerFont]) {
        _titleLabel.numberOfLines = 3;
    }
    else {
        _titleLabel.numberOfLines = 2;
    }
    [_titleLabel sizeToFit];
    _titleLabel.width = kAppScreenWidth-CONTENT_LEFT*3 - _cellContentView.width;
    
    [self setCellFrame];
    
    _timeLabel.bottom = [SNCorpusRollingMiddleVideoCell getCellHeight];
}

- (void)setPlayerVideoData:(NSString *)picUrl link:(NSString *)link videoID:(NSString*)videoID site:(NSString *)site tvPlayTime:(NSString *)tvPlayTime{
    NSString *decodeLink = [link stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *videoDict = [SNUtility parseURLParam:decodeLink schema:kProtocolVideoV2];
    self.videoID = videoID;
    _videoData = [[SNVideoData alloc] init];
    _videoData.poster = picUrl;
    _videoData.poster_4_3 = picUrl;
    _videoData.vid = videoID;
    _videoData.videoUrl = [[SNVideoUrl alloc] init];
    _videoData.isNewsVideo = YES;
    _videoData.duration = [tvPlayTime intValue];
    _videoData.templateType = kNewsTypeRollingMiddleVideo;
    SNVideoSiteInfo *siteinfo = [[SNVideoSiteInfo alloc] init];
    siteinfo.site2 = site;
    if (site.length == 0) {
        siteinfo.site2 = @"2";
    }
    siteinfo.playById = @"1";
    siteinfo.siteId  = [videoDict stringValueForKey:@"vid" defaultValue:@""];
    siteinfo.playAd = @"1";
    _videoData.siteInfo = siteinfo;
    
    [_cellContentView setObject:_videoData];
    [_cellContentView setPlayStyle:AutoPlayStyleMinImage];
    
    [_cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, (self.height-kMiddleVideoImageHeight)/2, kMiddleVideoImageWidth, kMiddleVideoImageHeight)];
    [_cellContentView showPlayTime];
}


- (void)updateTheme {
    [super updateTheme];
    _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
    _cellContentView.alpha = themeImageAlphaValue();
}

- (void)setCellFrame {
    self.frame = CGRectMake(0, 0, kAppScreenWidth, CONTENT_LEFT + kMiddleVideoImageHeight + 5);
}
+ (CGFloat)getCellHeight {
    return CONTENT_LEFT + kMiddleVideoImageHeight + 5;
}

- (void)setEditMode {
    
    _selectButton.left = kSelectButtonLeftDistance;
    _cellContentView.left = kSelectButtonLeftDistance*2 + _selectButton.width;
    _titleLabel.left = _cellContentView.right + CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT*2 - _cellContentView.right;
    _cellContentView.isEditMode = YES;
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    [_cellContentView settingPlayButton];
}

- (void)setNormalMode {
    
    _selectButton.right = 0;
    _cellContentView.left = CONTENT_LEFT;
    _titleLabel.left = _cellContentView.right + CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth-CONTENT_LEFT*3 - _cellContentView.width;
    _cellContentView.isEditMode = NO;
    if (![SNAutoPlaySharedVideoPlayer sharedInstance].isPlaying) {
        [_cellContentView settingPlayButton];
    }
}

- (void)autoPlayVideo {
    [_cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, (self.height-kMiddleVideoImageHeight)/2, kMiddleVideoImageWidth, kMiddleVideoImageHeight)];
    
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (player.moviePlayer && player.moviePlayer.playbackState != SHMoviePlayStatePlaying) {
        [_cellContentView autoPlayVideo];
    }
}

- (void)stopPlayVideo {
    [_cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, (self.height-kMiddleVideoImageHeight)/2, kMiddleVideoImageWidth, kMiddleVideoImageHeight)];
    [_cellContentView stopVideo];
}

@end
