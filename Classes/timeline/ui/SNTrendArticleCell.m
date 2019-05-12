//
//  SNTrendCommentCell.m
//  sohunews
//
//  Created by jialei on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendArticleCell.h"
#import "UIImage+MultiFormat.h"

@implementation SNTrendArticleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawTimelineOriginContent
{
}

//用户ugc显示
- (void)setContent
{
    [super setContent];
    [self setContentImage];
    [self setContentSound];
}

//动态原文
- (void)setOriginTitleAndFrom
{
    [super setOriginTitleAndFrom];
    
    CGFloat startX = CGRectGetMinX(_originalContentRect);
    CGFloat startY = CGRectGetMinY(_originalContentRect);
    CGFloat textWidth = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
    
    //title
    UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
    _originTitleLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                         kTLOriginalContentTitleTopMargin + startY,
                                         textWidth,
                                         self.timelineTrendObj.originContentObj.titleHeight);
    _originTitleLabel.text = self.timelineTrendObj.originContentObj.title;
    _originTitleLabel.font = titleFont;
    
    //from
    startY = _originTitleLabel.bottom + kTLOriginalContentVerticalMargin;
    UIFont *fromFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
    _originFromLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                        startY,
                                        textWidth,
                                        self.timelineTrendObj.originContentObj.fromHeight);
    _originFromLabel.text = self.timelineTrendObj.originContentObj.fromDisplayString;
    _originFromLabel.font = fromFont;
}

- (void)setOriginView
{
    [super setOriginView];
    
    if (!_abstractLabel) {
        _abstractLabel = [[SNLabel alloc] initWithFrame:CGRectZero];
        _abstractLabel.delegate = self;
        _abstractLabel.font = [UIFont systemFontOfSize:kTLOriginalContentAbstractFontSize];
        _abstractLabel.lineHeight = kTLOriginalContentAbstractLineHeight;
        _abstractLabel.textColor = SNUICOLOR(kRollingNewsCellDetailTextUnreadColor);
        _abstractLabel.tapEnable = YES;
        [self addSubview:_abstractLabel];
    }
    
    if (self.timelineTrendObj.originContentObj.abstract.length > 0) {
        _abstractLabel.hidden = NO;
        CGFloat textWidth = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
        _abstractLabel.top = _originFromLabel.bottom + kTLOriginalContentTextSideMargin;
        _abstractLabel.left = CGRectGetMinX(_originalContentRect) + kTLOriginalContentTextSideMargin;
        _abstractLabel.width = textWidth;
        _abstractLabel.height = self.timelineTrendObj.originContentObj.abstractHeight;
        _abstractLabel.text = self.timelineTrendObj.originContentObj.abstract;
    }
    else {
        _abstractLabel.hidden = YES;
    }
}

- (void)setOriginalImageView
{
    CGRect imageRect = CGRectMake(CGRectGetMinX(_originalContentRect) + kTLOriginalContentImageSideMargin,
                                  CGRectGetMaxY(_originalContentRect) - kTLOriginalContentImageBottomMargin - self.timelineTrendObj.originContentObj.picDisplaySize.height,
                                  self.timelineTrendObj.originContentObj.picDisplaySize.width,
                                  self.timelineTrendObj.originContentObj.picDisplaySize.height);
    if (!_originalImageView) {
        _originalImageView = [[SNWebImageView alloc] init];
        _originalImageView.clipsToBounds = YES;
        [self addSubview:_originalImageView];
        _originalImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        [_originalImageView addGestureRecognizer:tap];
        TT_RELEASE_SAFELY(tap);
    }
    
    if ([_originalImageView.urlPath length] > 0) {
        _originalImageView.urlPath = nil;
    }
    [_originalImageView setFrame:imageRect];
    _originalImageView.defaultImage = _originDefaultImage;
    _originalImageView.hidden = (CGRectIsEmpty(imageRect) || !self.timelineTrendObj.originContentObj.picUrl);
    _originalImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
    [self setOriginalImageUrl:self.timelineTrendObj.originContentObj.picUrl isRelyNetwork:YES];
    
    if (!_videoIconView) {
        UIImage *videoImage = [UIImage imageNamed:@"news_video.png"];
        _videoIconView = [[UIImageView alloc] initWithImage:videoImage];
        _videoIconView.size = CGSizeMake(videoImage.size.width, videoImage.size.height);
        [self addSubview:_videoIconView];
    }
    
    _videoIconView.alpha = _originalImageView.alpha;
    
    if (!_originalImageView.isHidden) {
        _videoIconView.right = CGRectGetMaxX(_originalImageView.frame) - 2;
        _videoIconView.bottom = CGRectGetMaxY(_originalImageView.frame) - 2;
        _videoIconView.hidden = !self.timelineTrendObj.originContentObj.hasTv;
    }
    else {
        _videoIconView.hidden = YES;
    }
}


//用户评论图
- (void)setContentImage
{
    NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_photolist_click_recommend.png" : @"default_photolist_recommend.png";
    UIImage *defaultImage = [UIImage imageNamed:defautlImgName];
    
    if (!_picView) {
        _picView = [[SNWebImageView alloc] initWithFrame:CGRectMake(_contentLabel.left,
                                                                    _viewOffsetY + kTLShareInfoViewNameContentMargin,
                                                                    kPicViewWidth,
                                                                    kPicViewHeight)];
        _picView.showFade = NO;
        _picView.clipsToBounds = YES;
        _picView.layer.cornerRadius = 3;
        _picView.userInteractionEnabled = YES;
        [self addSubview:_picView];
        
        //图片添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView)];
        [_picView addGestureRecognizer:tap];
        [tap release];
    }
    
    // set image data
    if (self.timelineTrendObj.ugcSmallImageUrl.length > 0) {
        _picView.defaultImage = defaultImage;
        _picView.top = _viewOffsetY + kTLShareInfoViewNameContentMargin;
        _picView.hidden = NO;
        _viewOffsetY = _picView.bottom;
        _picView.urlPath = self.timelineTrendObj.ugcSmallImageUrl;
        BOOL bNightMode = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight];
        _picView.alpha = bNightMode ? 0.7 : 1;
    }
    else {
        _picView.hidden = YES;
    }
}

//用户评论语音
- (void)setContentSound
{
    if (!_soundView) {
        _soundView = [[SNLiveSoundView alloc] initWithFrame:CGRectMake(_contentLabel.left,
                                                                       _viewOffsetY + kTLShareInfoViewNameContentMargin,
                                                                       SOUNDVIEW_WIDTH,
                                                                       SOUNDVIEW_HEIGHT)];
        
        [self addSubview:_soundView];
    }
    
    if (self.timelineTrendObj.ugcAudUrl.length > 0) {
        [_soundView loadIfNeeded];
        _soundView.top = _viewOffsetY + kTLShareInfoViewNameContentMargin;
        _soundView.duration = self.timelineTrendObj.ugcAudLen;
        _soundView.commentID = self.timelineTrendObj.actId;
        _soundView.url = self.timelineTrendObj.ugcAudUrl;
        
        _soundView.hidden = NO;
        _viewOffsetY = _soundView.bottom;
    }
    else {
        _soundView.hidden = YES;
    }
}

- (void)updateTheme {
    [_soundView updateTheme];
    [super updateTheme];
}

#pragma mark - action
- (void)setOriginalImageUrl:(NSString *)urlPath isRelyNetwork:(BOOL)isDownload
{
    [super setOriginalImageUrl:urlPath isRelyNetwork:isDownload];
}

@end
