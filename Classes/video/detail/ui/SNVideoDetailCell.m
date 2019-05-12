//
//  SNVideoDetailCell.m
//  sohunews
//
//  Created by jojo on 13-9-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoDetailCell.h"
#import "SNVideosTableCell.h"
#import "SDImageCache.h"


#define kVideoCellTitleTopMargin                    (20 / 2)
#define kVideoCellTitleRightSpacing                 (24 / 2)
#define kVideoCellTitleFontSize                     (34 / 2)
#define kVideoCellTitleLineHeight                   (kVideoCellTitleFontSize + 5)

#define kVideoCellPlayMarkRightMargin               (5 / 2)
#define kVideoCellPlayMarkBottomMargin              (5 / 2)

#define kVideoCellAuthorBottomMargin                (kVideoCellImageTopMargin)

static CGFloat const kThumbnailImgViewMarginLeft = 10.0f;
static CGFloat const kThumbnailImgViewMarginTop = 7.0f;
static CGFloat const kThumbnailImgViewWidth = 90.0f;
static CGFloat const kThumbnailImgViewHeight = 65.0f;
static CGFloat const kThumbnailAndTitleHPadding = 12.0f;

static CGFloat const kTitleLabelMarginLeft = kThumbnailImgViewMarginLeft+kThumbnailImgViewWidth+kThumbnailAndTitleHPadding;
static CGFloat const kTitleLabelMarginRight = 10.0f;
#define kTitleLabelWidth (kAppScreenWidth-kThumbnailImgViewMarginLeft-kTitleLabelMarginRight-kThumbnailAndTitleHPadding-kThumbnailImgViewWidth)

@implementation SNVideoDetailCell
@synthesize titleLabel = _titleLabel;
@synthesize videoImageView = _videoImageView;
@synthesize authorLabel = _authorLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
     //(_video);
     //(_titleLabel);
     //(_videoImageView);
     //(_cellSelectedBg);
     //(_authorLabel);
    
}

- (void)showSelectedBg:(BOOL)show {
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    } else {
        if (_cellSelectedBg.alpha > 0 && ![self isPlaying]) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
            _cellSelectedBg.alpha = 0;
            [UIView commitAnimations];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self showSelectedBg:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [self showSelectedBg:selected];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [UIView drawCellSeperateLine:rect];
}

#pragma mark -

- (SNLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SNLabel alloc] initWithFrame:CGRectMake(kTitleLabelMarginLeft,
                                                                kVideoCellTitleTopMargin,
                                                                kTitleLabelWidth,
                                                                kVideoCellTitleLineHeight * 2)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kVideoCellTitleFontSize];
        _titleLabel.lineHeight = kVideoCellTitleLineHeight;
        _titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellTitleUnreadColor]];
        _titleLabel.disableLinkDetect = YES;
        _titleLabel.userInteractionEnabled = NO;
        
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SNWebImageView *)videoImageView {
    if (!_videoImageView) {
        BOOL isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
        
        UIView *imageBgView = [[UIView alloc] initWithFrame:CGRectZero];
        imageBgView.backgroundColor = [UIColor colorFromString:isNight ? @"888888" : @"f2f2f2"];
        imageBgView.clipsToBounds = YES;
        imageBgView.layer.cornerRadius = 5;
        imageBgView.tag = 1000;
        [self addSubview:imageBgView];
         //(imageBgView);

        _videoImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(kThumbnailImgViewMarginLeft,
                                                                           kThumbnailImgViewMarginTop,
                                                                           kThumbnailImgViewWidth,
                                                                           kThumbnailImgViewHeight)];
        _videoImageView.backgroundColor = [UIColor clearColor];
        _videoImageView.defaultImage = [UIImage imageNamed:@"timeline_default.png"];
        _videoImageView.clipsToBounds = YES;
        _videoImageView.layer.cornerRadius = 5;
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill; // 缩略图保持比例充满
        
        [self addSubview:_videoImageView];
        
        // play mark icon
        UIImage *playMarkImage = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
        UIImageView *playMark = [[UIImageView alloc] initWithImage:playMarkImage];
        playMark.bottom = _videoImageView.height - kVideoCellPlayMarkBottomMargin;
        playMark.right = _videoImageView.width - kVideoCellPlayMarkRightMargin;
        [_videoImageView addSubview:playMark];
         //(playMark);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadCellImage:)];
        [_videoImageView addGestureRecognizer:tap];
         //(tap);
    }
    return _videoImageView;
}

- (UILabel *)authorLabel {
    if (!_authorLabel) {
        UIFont *font = [UIFont systemFontOfSize:9];
        _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitleLabelMarginLeft, 0, self.width, font.lineHeight)];
        _authorLabel.font = font;
        _authorLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellCommentColor]];
        _authorLabel.bottom = _videoImageView.bottom + 2;
        _authorLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_authorLabel];
    }
    return _authorLabel;
}

- (void)setVideo:(SNVideoData *)video {
    _video = nil;
    _video = video;
    
    self.titleLabel.text = self.video.title;
    [self.titleLabel removeAllCustomLinks];
    
    if (self.videoImageView.urlPath) {
        [self.videoImageView unsetImage];
    }
    
    self.authorLabel.text = nil;
    if (self.video.author) {
        // 自媒体账号 用columnName
        if (self.video.author.type == VideoAuthorType_OrgnizationSelfMedia || self.video.author.type == VideoAuthorType_PersonalSelfMedia) {
            self.authorLabel.text = self.video.columnName;
        }
        else if (self.video.author.type == VideoAuthorType_SocialMedia || self.video.author.type == VideoAuthorType_SohuRecommend) {
            self.authorLabel.text = self.video.author.name;
        }
    }
    
    if ([SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        self.videoImageView.userInteractionEnabled = YES;
    }
    else {
        self.videoImageView.userInteractionEnabled = NO;
    }
    
    self.videoImageView.urlPath = self.video.smallImageUrl;
    
    [self updateTheme];
    /**
     * 因为正常逻辑下detailcell是使用smallImageUrl显示图片的。
     * 为了避免在Timeline上下载一个视频后在无网络时进入离线列表播放时相关视频列表中不能显示图片的情况发生，所以在无网时，如果poster_4_3对应的图片被缓存了则用poster_4_3缓存图片
     */
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.video.poster_4_3];
        if (!!cachedImage) {
            self.videoImageView.image = cachedImage;
        }
    }

    // 当前播放状态 需要高亮显示
    [self setSelected:[self isPlaying] animated:YES];
    [self setNeedsLayout];
}

- (void)updateTheme
{
    self.videoImageView.alpha = themeImageAlphaValue();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cellSelectedBg.frame = self.bounds;
    
    _videoImageView.left = kThumbnailImgViewMarginLeft;
    
    _titleLabel.left = kTitleLabelMarginLeft;
    _authorLabel.left = kTitleLabelMarginLeft;
    _authorLabel.bottom = _videoImageView.bottom + 2;
    
    UIView *imageBgView = [self viewWithTag:1000];
    imageBgView.frame = _videoImageView.frame;
}

#pragma mark - actions

- (void)reloadCellImage:(id)sender {
//    [self.videoImageView loadUrlPath:self.videoImageView.urlPath];
//    self.videoImageView.userInteractionEnabled = NO;
    if ([self.delegate respondsToSelector:@selector(didTapCellThumbnailInCell:)]) {
        [self.delegate didTapCellThumbnailInCell:self];
    }
}

#pragma mark - Private
- (BOOL)isPlaying {
    NSString *playingMessageId = nil;
    if ([self.delegate respondsToSelector:@selector(playingMessageId)]) {
        playingMessageId = [self.delegate playingMessageId];
    }
    return [self.video.messageId isEqualToString:playingMessageId];
}

@end
