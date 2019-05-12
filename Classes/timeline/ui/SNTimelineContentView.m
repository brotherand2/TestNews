//
//  SNTimelineContentView.m
//  sohunews
//
//  Created by jojo on 13-7-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineContentView.h"

#define kTimelineContentViewContentTopMargin            (kTLShareInfoViewContentTopMargin + 20)
#define kTimelineContentViewOriginContentWidth          (TTApplicationFrame().size.width - 2 * kTLViewSideMargin)
#define kTimelineContentViewImageWidth                  (490 / 2)
#define kTimelineContentViewImageMaxHeight              (kTLOriginalContentIamgeMaxHeight)

@implementation SNTimelineContentView
@synthesize timelineObj = _timelineObj;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.width = TTApplicationFrame().size.width;
    }
    return self;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_timelineObj);
    
    TT_RELEASE_SAFELY(_headIconView);
    TT_RELEASE_SAFELY(_nameLabel);
    TT_RELEASE_SAFELY(_timeLabel);
    TT_RELEASE_SAFELY(_contentLabel);
    TT_RELEASE_SAFELY(_abstractLabel);
    
    TT_RELEASE_SAFELY(_originalTapview);
    TT_RELEASE_SAFELY(_originalImageView);
    TT_RELEASE_SAFELY(_commentNumLabel);
    TT_RELEASE_SAFELY(_videoIconView);
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat startX = CGRectGetMinX(_originalContentRect);
    CGFloat startY = CGRectGetMinY(_originalContentRect);
    
    if (self.timelineObj.originContentObj.type != SNTimelineOriginContentTypeSub) {
        CGFloat textWidth = kTimelineContentViewOriginContentWidth - 2 * kTLOriginalContentTextSideMargin;
        
        // 全都用没有上三角的背景图
        if (YES || self.timelineObj.content.length > 0) {
            UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg.png"];
            if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
                bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            else
                bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
            
            [bgImage drawInRect:_originalContentRect];
        }
        else {
            UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg_with_angle.png"];
            if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
                bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            else
                bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
            
            [bgImage drawInRect:CGRectMake(_originalContentRect.origin.x, _originalContentRect.origin.y - 5,
                                           _originalContentRect.size.width, _originalContentRect.size.height + 5)];
        }
        
        // draw title
        NSString *titleColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellTitleUnreadColor];
        [[UIColor colorFromString:titleColorString] set];
        UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
        CGRect titleRect = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                      kTLOriginalContentTitleTopMargin + startY,
                                      textWidth,
                                      CGFLOAT_MAX);
        [self.timelineObj.originContentObj.title drawInRect:titleRect
                                                   withFont:titleFont
                                              lineBreakMode:UILineBreakModeCharacterWrap];
        
        startY += _heightTitle + kTLOriginalContentFromTopMargin;
        
        // draw from
        NSString *fromTextColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor];
        [[UIColor colorFromString:fromTextColorString] set];
        UIFont *fromFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
        CGRect fromRect = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                     startY,
                                     textWidth,
                                     _heightFrom + 1);
        [self.timelineObj.originContentObj.fromDisplayString drawInRect:fromRect
                                                               withFont:fromFont
                                                          lineBreakMode:UILineBreakModeCharacterWrap];
        
        startY += _heightFrom + kTLOriginalContentAbstractTopMargin;
        
        // draw abstract
        _abstractLabel.top = startY;
        _abstractLabel.height = _heightAbstract;
    }
    // draw sub style
    else {
        
        UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg.png"];
        if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        else
            bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        
        if (bgImage) [bgImage drawInRect:_originalContentRect];
        
        CGRect iconBgRect = CGRectMake(startX + kTLViewSideMargin,
                                       startY + kTLViewSubIconTopMargin,
                                       kTLViewSubIconSize,
                                       kTLViewSubIconSize);
        UIImage *iconBgImage = [UIImage imageNamed:@"subinfo_article_iconBg.png"];
        [iconBgImage drawInRect:iconBgRect];
        
        CGFloat titleWidth = _originalContentRect.size.width - 2 * kTLViewSubTextLeftMargin;
        NSString *titleTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewTitleTextColor];
        [[UIColor colorFromString:titleTextColorStr] set];
        [self.timelineObj.originContentObj.subName textDrawAtPoint:CGPointMake(startX + kTLViewSubTextLeftMargin, startY + kTLViewSubNameTopMargin)
                                                          forWidth:titleWidth
                                                          withFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
                                                     lineBreakMode:UILineBreakModeTailTruncation
                                                         textColor:[UIColor colorFromString:titleTextColorStr]];
        
        NSString *countTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor];
        [[UIColor colorFromString:countTextColorStr] set];
        NSString *drawText = [NSString stringWithFormat:@"订阅人数 %@", self.timelineObj.originContentObj.subCount];
        [drawText textDrawAtPoint:CGPointMake(startX + kTLViewSubTextLeftMargin,
                                          startY + _originalContentRect.size.height - kTLViewSubCountBottomMargin - kTLViewFromFontSize)
                         forWidth:titleWidth
                         withFont:[UIFont systemFontOfSize:kTLViewFromFontSize]
                    lineBreakMode:UILineBreakModeTailTruncation
                        textColor:[UIColor colorFromString:countTextColorStr]];
    }
    
    [UIView drawCellSeperateLine:rect];
}

- (void)setTimelineObj:(SNTimelineTrendItem *)timelineObj {
    [timelineObj retain];
    TT_RELEASE_SAFELY(_timelineObj);
    _timelineObj = timelineObj;
    
    if (!_headIconView) {
        _headIconView = [[SNHeadIconView alloc] initWithFrame:CGRectMake(kTLViewSideMargin,
                                                                             kTLShareInfoViewIconTopMargin,
                                                                             kTLShareInfoViewIconSize,
                                                                             kTLShareInfoViewIconSize)];
        [_headIconView setTarget:self tapSelector:@selector(userIconOrNameTapped:)];
        [self addSubview:_headIconView];
    }
    
    [_headIconView setIconUrl:_timelineObj.userHeadUrl passport:nil gender:_timelineObj.gender];
    _headIconView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
    
    if (!_nameLabel) {
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
        UIColor *authorColor = [UIColor colorFromString:strColor];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTLShareInfoViewTextLeftMargin,
                                                               kTLShareInfoViewNameTopMargin,
                                                               self.width - kTLViewSideMargin - kTLShareInfoViewTextLeftMargin,
                                                               kTLShareInfoViewNameFontSize + 1)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewNameFontSize];
        _nameLabel.textColor = authorColor;
        [self addSubview:_nameLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconOrNameTapped:)];
        _nameLabel.userInteractionEnabled = YES;
        [_nameLabel addGestureRecognizer:tap];
        TT_RELEASE_SAFELY(tap);
    }
    _nameLabel.centerY = _headIconView.centerY;
    _nameLabel.text = _timelineObj.userNickName;
    // 计算namelabel width
    _nameLabel.width = MIN([_nameLabel.text sizeWithFont:_nameLabel.font].width, self.width - kTLViewSideMargin - 100 - _nameLabel.left - 10);
    
    if (!_timeLabel) {
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorCommentDateColor];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - kTLViewSideMargin - 100,
                                                               kTLShareInfoViewTimeTopMargin,
                                                               100,
                                                               kTLShareInfoViewTimeFontSize + 1)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize];
        _timeLabel.textAlignment = UITextAlignmentRight;
        _timeLabel.textColor = [UIColor colorFromString:strColor];
        [self addSubview:_timeLabel];
    }
    
    _timeLabel.centerY = _headIconView.centerY;
    _timeLabel.text = [NSDate relativelyDate:_timelineObj.time];
    
    if (!_contentLabel) {
        _contentLabel = [[SNLabel alloc] initWithFrame:CGRectMake(kTLViewSideMargin,
                                                                  kTimelineContentViewContentTopMargin,
                                                                  self.width - 2 * kTLViewSideMargin,
                                                                  kTLShareInfoViewContentFontSize + 1)];
        
        NSString *contentColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor];
        _contentLabel.textColor = [UIColor colorFromString:contentColorStr];
        _contentLabel.lineHeight = kTLShareInfoViewContentLineHeight;
        _contentLabel.font = [UIFont systemFontOfSize:kTLShareInfoViewContentFontSize];
        _contentLabel.delegate = self;
        [self addSubview:_contentLabel];
    }
    
    _contentLabel.top = kTimelineContentViewContentTopMargin;
    // 计算一下 就有数据了
    [self heightForShareInfo:_timelineObj];
    _contentLabel.height = _heightContent;
    _contentLabel.text = _timelineObj.content;
    
    CGSize originSize = CGSizeMake(kTimelineContentViewOriginContentWidth, llroundf([self heightForOriginContent:_timelineObj]));
    _originalContentRect = CGRectMake((self.width - kTimelineContentViewOriginContentWidth) / 2, // 翔鹤要求  内容这一块 整体左移 1px on 2013-07-15
                                      _contentLabel.bottom + kTLCellOriginContentTopMargin,
                                      originSize.width,
                                      originSize.height);
    
    if (!_originalTapview) {
        _originalTapview = [[UIView alloc] init];
        [self addSubview:_originalTapview];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOriginalContentAction:)];
        [_originalTapview addGestureRecognizer:tap];
        TT_RELEASE_SAFELY(tap);
    }
    _originalTapview.frame = _originalContentRect;
    
    if (self.timelineObj.originContentObj.type != SNTimelineOriginContentTypeSub) {
        if (!_abstractLabel) {
            NSString *absColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor];
            _abstractLabel = [[SNLabel alloc] initWithFrame:CGRectZero];
            _abstractLabel.delegate = self;
            _abstractLabel.font = [UIFont systemFontOfSize:kTLOriginalContentAbstractFontSize];
            _abstractLabel.lineHeight = kTLOriginalContentAbstractLineHeight;
            _abstractLabel.textColor = [UIColor colorFromString:absColorStr];
            _abstractLabel.userInteractionEnabled = NO;
            [self addSubview:_abstractLabel];
        }
        _abstractLabel.hidden = NO;
        CGFloat textWidth = kTimelineContentViewOriginContentWidth - 2*kTLOriginalContentTextSideMargin;
        _abstractLabel.left = CGRectGetMinX(_originalContentRect) + kTLOriginalContentTextSideMargin;
        _abstractLabel.width = textWidth;
        _abstractLabel.height = _heightAbstract;
        _abstractLabel.text = self.timelineObj.originContentObj.abstract;
    } else {
        _abstractLabel.hidden = YES;
    }
    
    
    if (!_originalImageView) {
        _originalImageView = [[SNWebImageView alloc] init];
        _originalImageView.layer.cornerRadius = 2;
        _originalImageView.clipsToBounds = YES;
        _originalImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_originalImageView];
        
        _originalImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        [_originalImageView addGestureRecognizer:tap];
        TT_RELEASE_SAFELY(tap);
    }
    
    if ([_originalImageView.urlPath length] > 0) {
        [_originalImageView unsetImage];
        _originalImageView.urlPath = nil;
    }
    
    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        _originalImageView.defaultImage = [UIImage imageNamed:@"timeline_default.png"];
    } else {
        _originalImageView.defaultImage = [UIImage imageNamed:@"timeline_click_default.png"];
    }
    
    CGRect imageRect = CGRectZero;
    if (_timelineObj.originContentObj.type == SNTimelineOriginContentTypeSub) {
        imageRect = CGRectMake(kTLViewSideMargin + CGRectGetMinX(_originalContentRect),
                               kTLViewSubIconTopMargin + CGRectGetMinY(_originalContentRect),
                               kTLViewSubIconSize,
                               kTLViewSubIconSize);
    }
    else {
        CGSize imageSize = [self imageSizeFromSizeString:_timelineObj.originContentObj.picSize];
        imageRect = CGRectMake(CGRectGetMinX(_originalContentRect) + kTLOriginalContentImageSideMargin,
                               CGRectGetMaxY(_originalContentRect) - kTLOriginalContentImageBottomMargin - _timelineObj.originContentObj.picDisplaySize.height,
                               imageSize.width,
                               imageSize.height);
    }
    
    _originalImageView.hidden = (CGRectIsEmpty(imageRect) || !self.timelineObj.originContentObj.picUrl);
    _originalImageView.frame = imageRect;
    _originalImageView.image = _originalImageView.defaultImage;
    
    _originalImageView.urlPath = self.timelineObj.originContentObj.picUrl;
    _originalImageView.alpha = _headIconView.alpha;
    
    _originalImageView.userInteractionEnabled = NO;
    
    if (_timelineObj.originContentObj.type == SNTimelineOriginContentTypeSub) {
        _originalImageView.userInteractionEnabled = NO;
        [_originalImageView loadUrlPath:_originalImageView.urlPath];
    }
    else if ([SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        _originalImageView.userInteractionEnabled = ([[TTURLCache sharedCache] imageForURL:_originalImageView.urlPath] == nil);
    }
    
    if (!_videoIconView) {
        UIImage *videoImage = [UIImage imageNamed:@"news_video.png"];
        _videoIconView = [[UIImageView alloc] initWithImage:videoImage];
        [self addSubview:_videoIconView];
    }
    
    _videoIconView.alpha = _originalImageView.alpha;
    
    if (_timelineObj.originContentObj.type != SNTimelineOriginContentTypeSub && !_originalImageView.isHidden) {
        _videoIconView.right = CGRectGetMaxX(_originalImageView.frame) - 2;
        _videoIconView.bottom = CGRectGetMaxY(_originalImageView.frame) - 2;
        _videoIconView.hidden = !_timelineObj.originContentObj.hasTv;
    }
    else {
        _videoIconView.hidden = YES;
    }
    
    if (!_commentNumLabel) {
        _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)];
        _commentNumLabel.backgroundColor = [UIColor clearColor];
        _commentNumLabel.font = [UIFont systemFontOfSize:14];
        _commentNumLabel.textColor = _timeLabel.textColor;
        _commentNumLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:_commentNumLabel];
    }
    
    _commentNumLabel.top = CGRectGetMaxY(_originalContentRect) + 14;
    _commentNumLabel.right = self.width - kTLViewSideMargin;
//    _commentNumLabel.text = [NSString stringWithFormat:@"%@条评论", _timelineObj.commentNum];
    
    [self sizeToFit];
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.timelineObj) {
        CGFloat viewHeight = 0;
        
        viewHeight += [self heightForShareInfo:self.timelineObj];
        viewHeight += [self heightForOriginContent:self.timelineObj];
        
        viewHeight += 70; // 可能还要加别的高度
        
        return CGSizeMake(TTApplicationFrame().size.width, llroundf(viewHeight));
    }
    return CGSizeZero;
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    SNDebugLog(@"link : %@",link);
    if ([link length] > 0) {
        if ([link hasPrefix:@"link://"]) {
            NSString *pid = [link substringFromIndex:7];
            TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : pid}] applyAnimated:YES];
            [[TTNavigator navigator] openURLAction:urlAction];
        } else {
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            
            [query setObject:link forKey:@"address"];
            
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
            [[TTNavigator navigator] openURLAction:urlAction];
            
        }
    }
    
}

- (void)tapOnNotLink:(SNLabel *)label
{
    if (label == _abstractLabel) {
        [self openOriginalContentAction:nil];
    }
}

#pragma mark - actions

- (void)openOriginalContentAction:(id)sender {
    if (self.timelineObj.originContentObj.link.length > 0) {
        [SNUtility openProtocolUrl:self.timelineObj.originContentObj.link context:nil];
    }
}

- (void)userIconOrNameTapped:(id)sender {
    TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : self.timelineObj.pid}] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)imageViewTapped:(id)sender {
    [_originalImageView loadUrlPath:_originalImageView.urlPath];
    _originalImageView.userInteractionEnabled = NO;
}

#pragma mark - private

- (CGFloat)heightForShareInfo:(SNTimelineTrendItem *)timelineObj {
    CGFloat viewHeight = 0;
    if (timelineObj) {
        // 计算share info 高度
        CGFloat contentWidth = TTApplicationFrame().size.width - kTLViewSideMargin * 2;
        viewHeight = [SNLabel heightForContent:timelineObj.content maxWidth:contentWidth font:kTLShareInfoViewContentFontSize lineHeight:kTLShareInfoViewContentLineHeight];
        _heightContent = viewHeight;
        if (viewHeight > 0) {
            viewHeight = viewHeight + kTimelineContentViewContentTopMargin;
        }
        else {
            viewHeight = kTLShareInfoViewIconTopMargin + kTLShareInfoViewIconSize + 10;
        }
    }
    return viewHeight;
}

- (CGFloat)heightForOriginContent:(SNTimelineTrendItem *)timelineObj {
    CGFloat viewHeight = 0;
    if (timelineObj) {
        
        // 计算original content 高度
        if (timelineObj.originContentObj.type != SNTimelineOriginContentTypeSub) {
            // 计算高度  要考虑到图片的大小  文字最多显示的行数
            CGFloat width = kTimelineContentViewOriginContentWidth - 2 * kTLOriginalContentTextSideMargin;
            CGFloat height = 0;
            
            height += kTLOriginalContentTitleTopMargin;
            UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
            CGSize titleSize = [timelineObj.originContentObj.title sizeWithFont:titleFont
                                                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                  lineBreakMode:UILineBreakModeCharacterWrap];
            height += titleSize.height;
            _heightTitle = titleSize.height;
            
            height += kTLOriginalContentFromTopMargin;
            
            UIFont *fromStringFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
            CGSize fromSize = [timelineObj.originContentObj.fromDisplayString sizeWithFont:fromStringFont
                                                                         constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                             lineBreakMode:UILineBreakModeCharacterWrap];
            height += fromSize.height;
            _heightFrom = fromSize.height;
            
            // 文字最多显示六行
            if (timelineObj.originContentObj.picsArray.count > 0) {
                CGFloat maxHeight = 6 * kTLOriginalContentAbstractLineHeight;
                CGSize absSize = [SNLabel sizeForContent:timelineObj.originContentObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
                
                _heightAbstract = MIN(absSize.height,maxHeight);
                
                if (absSize.height > 0) {
                    height += kTLOriginalContentAbstractTopMargin;
                    height += _heightAbstract;
                }
                
                height += kTLOriginalContentImageTopMargin;
                height += [self imageSizeFromSizeString:timelineObj.originContentObj.picSize].height;
                height += kTLOriginalContentImageBottomMargin;
                height -= kTLOriginalContentAbstractLineSpacing;
            }
            // 文字最多显示八行
            else {
                CGFloat maxHeight = 8 * kTLOriginalContentAbstractLineHeight;
                CGSize absSize = [SNLabel sizeForContent:timelineObj.originContentObj.abstract maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:kTLOriginalContentAbstractFontSize lineHeight:kTLOriginalContentAbstractLineHeight];
                
                _heightAbstract = MIN(maxHeight,absSize.height);
                
                if (absSize.height > 0) {
                    height += kTLOriginalContentAbstractTopMargin;
                    height += _heightAbstract;
                }
            }
            
            viewHeight += height;
        }
        else {
            viewHeight += kTLViewSubViewHeight;
        }
        
        return viewHeight;
    }
    return viewHeight;
}

- (CGSize)imageSizeFromSizeString:(NSString *)sizeString {
    if (sizeString.length > 0) {
        NSArray *sizeArray = [sizeString componentsSeparatedByString:@"*"];
        if (sizeArray.count < 2)
            sizeArray = [sizeString componentsSeparatedByString:@"x"];
        if (sizeArray.count < 2)
            sizeArray = [sizeString componentsSeparatedByString:@"X"];
        
        if (sizeArray.count >= 2) {
            CGSize _picFullSize = CGSizeMake([sizeArray[0] floatValue], [sizeArray[1] floatValue]);
            CGFloat dHeight = MIN(kTimelineContentViewImageWidth * _picFullSize.height / _picFullSize.width, kTimelineContentViewImageMaxHeight);
            return CGSizeMake(kTimelineContentViewImageWidth, dHeight);
        }
    }
    return CGSizeZero;
}

@end
