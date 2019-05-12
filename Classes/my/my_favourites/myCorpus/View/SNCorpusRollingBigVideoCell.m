//
//  SNCorpusRollingBigVideoCell.m
//  sohunews
//
//  Created by Scarlett on 16/6/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNCorpusRollingBigVideoCell.h"
#import "SNCellImageView.h"
#import "NSCellLayout.h"
#import "SNAutoPlayVideoContentView.h"

#define kTitleFont ((kAppScreenWidth > 375.0) ? kThemeFontSizeE : kThemeFontSizeD)
#define kTitleLableTopDistance 36/2.0
#define kTitleLableBottomDistance ((kAppScreenWidth > 375.0) ? 17.0/3 : 10/2.0)
#define kImageBottomDistance (kTitleLableTopDistance + 4.0)

@interface SNCorpusRollingBigVideoCell () {
    
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    SNAutoPlayVideoContentView *_cellContentView;
    CGSize _titleSize;
    
    SNVideoData *_videoData;
}
@end

@implementation SNCorpusRollingBigVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgImageView = [[UIView alloc] init];
        bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self setSelectedBackgroundView:bgImageView];
        _titleSize = [kCorpusFolderName getTextSizeWithFontSize:kTitleFont];
        [self setCellFrame];

        [self initSelectButton];
        [self initTitleLabel];
        [self initPhotoView];
        [self initTimeLabel];
    }
    return self;
}

- (void)setCellInfoWithUrl:(NSString *)url newsType:(NSString *)newsType title:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link videoID:(NSString *)videoID site:(NSString *)site tvPlayTime:(NSString *)tvPlayTime isItemSelected:(BOOL)isItemSelected {
    [self setPlayerVideoData:url link:link videoID:videoID site:site tvPlayTime:tvPlayTime];
    
    _titleLabel.text = title;
    _timeLabel.text = [NSDate relativelyDate:time];
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
    [_titleLabel sizeToFit];
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT*2;
    
    _cellContentView.top = _titleLabel.bottom + 10;
    
    [self setCellFrame];
    
    _timeLabel.top = _cellContentView.bottom;
}

- (void)initTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTitleLableTopDistance, kAppScreenWidth-CONTENT_LEFT*2, 2*[SNUtility getNewsTitleFontSize] + 5)];
        _titleLabel.left = CONTENT_LEFT;
        _titleLabel.top = 5;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
        _titleLabel.font = [SNUtility getNewsTitleFont];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
    }
}

- (void)initPhotoView {
    _cellContentView = [[SNAutoPlayVideoContentView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, _titleLabel.bottom + 10, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT)];
    [_cellContentView updateTheme];
    _cellContentView.alpha = themeImageAlphaValue();
    [self addSubview:_cellContentView];
}

- (void)initTimeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*3,_titleSize.height)];
        _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
        _timeLabel.bottom = self.bottom;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
        _timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
    }
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
    _videoData.templateType = kNewsTypeRollingBigVideo;
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
    [_cellContentView setPlayStyle:AutoPlayStyleBigImage];
    
    [_cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, _titleLabel.bottom + 10, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT)];
    [_cellContentView showPlayTime];
}

- (void)setCellFrame {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kAppScreenWidth, kTitleLableTopDistance + _titleLabel.height + kTitleLableBottomDistance + VIDEO_CELL_PLAYERHEIGHT + kImageBottomDistance);
}

+ (CGFloat)getCellHeight:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.font = [SNUtility getNewsTitleFont];
    label.text = title;
    label.numberOfLines = 2;
    label.width  = kAppScreenWidth-CONTENT_LEFT*2;
    [label sizeToFit];
    
    return kTitleLableTopDistance + label.height + kTitleLableBottomDistance + VIDEO_CELL_PLAYERHEIGHT + kImageBottomDistance;
}

- (void)setEditMode {
    
    _selectButton.left = kSelectButtonLeftDistance;
    _titleLabel.left = _selectButton.right + kSelectButtonLeftDistance;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT - _selectButton.right - kSelectButtonLeftDistance;
    _cellContentView.left = kSelectButtonLeftDistance * 2 + _selectButton.width;
    _cellContentView.isEditMode = YES;
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    [_cellContentView settingPlayButton];
}

- (void)setNormalMode {
    
    _selectButton.right = 0;
    _selectButton.selected = NO;
    _titleLabel.left = CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT*2;
    _cellContentView.left = CONTENT_LEFT;
    _cellContentView.isEditMode = NO;
    [_cellContentView settingPlayButton];
}

- (void)updateTheme {
    [super updateTheme];
    _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
    _cellContentView.alpha = themeImageAlphaValue();
}

- (void)autoPlayVideo {
    [_cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, _titleLabel.bottom + 10, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT)];
    
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (player.moviePlayer && [player getMoviePlayer].playbackState != SHMoviePlayStatePlaying) {
        [_cellContentView autoPlayVideo];
    }
}

- (void)stopPlayVideo {
    [_cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, _titleLabel.bottom + 10, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT)];
    [_cellContentView stopVideo];
}

@end
