//
//  SNTrendSubScribeCell.m
//  sohunews
//
//  Created by jialei on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendSubScribeCell.h"

@implementation SNTrendSubScribeCell

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
    TT_RELEASE_SAFELY(_iconBgImage);
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawTimelineOriginContent
{
}

- (void)setOriginView
{
    [super setOriginView];
}

- (void)setOriginalImageView
{
    //icon back
    if (!_iconBgImage) {
        _iconBgImage = [[UIImageView alloc]initWithImage:_subIconBgImage];
        [self insertSubview:_iconBgImage aboveSubview:_originalBgView];
    }
    
    
    _iconBgImage.frame = CGRectMake(CGRectGetMinX(_originalContentRect) + kTLViewSideMargin,
                                    CGRectGetMinY(_originalContentRect) + kTLViewSubIconTopMargin,
                                    kTLViewSubIconSize,
                                    kTLViewSubIconSize);
    
    CGRect imageRect = CGRectMake(kTLViewSideMargin + CGRectGetMinX(_originalContentRect),
                                  kTLViewSubIconTopMargin + CGRectGetMinY(_originalContentRect),
                                  kTLViewSubIconSize,
                                  kTLViewSubIconSize);
    if (!_originalImageView) {
        _originalImageView = [[SNWebImageView alloc] initWithFrame:imageRect];
        _originalImageView.clipsToBounds = YES;
        [self addSubview:_originalImageView];
        _originalImageView.userInteractionEnabled = YES;
        _originalImageView.defaultImage = _originDefaultImage;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        [_originalImageView addGestureRecognizer:tap];
        TT_RELEASE_SAFELY(tap);
    }
    
    if ([_originalImageView.urlPath length] > 0) {
        _originalImageView.urlPath = nil;
    }
    _originalImageView.hidden = (CGRectIsEmpty(imageRect) || !self.timelineTrendObj.originContentObj.picUrl);
    BOOL isTapEnabled = ([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:self.timelineTrendObj.originContentObj.picUrl] == nil);
    _originalImageView.userInteractionEnabled = isTapEnabled;
    
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.timelineTrendObj.originContentObj.picUrl]) {
        [_originalImageView setImageWithURL:[NSURL URLWithString:self.timelineTrendObj.originContentObj.picUrl]
                           placeholderImage:_originDefaultImage];
    } else {
        [_originalImageView loadUrlPath:self.timelineTrendObj.originContentObj.picUrl];
    }
    _originalImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
    _originalImageView.frame = imageRect;
}

- (void)setOriginTitleAndFrom
{
    [super setOriginTitleAndFrom];
    
    CGFloat startX = CGRectGetMinX(_originalContentRect);
    CGFloat startY = CGRectGetMinY(_originalContentRect);
    
    //subName
    UIFont *subFont = [UIFont systemFontOfSize:kTLViewTitleFontSize];
    CGFloat titleWidth = _originalContentRect.size.width - 2 * kTLViewSideMargin - kTLViewSubIconSize;
    _originTitleLabel.text = self.timelineTrendObj.originContentObj.title;
    _originTitleLabel.frame = CGRectMake(startX + kTLViewSubTextLeftMargin, startY + kTLViewSubNameTopMargin - 2
                                         , titleWidth, subFont.lineHeight + 2);
    _originTitleLabel.font = subFont;
    
    //subCount
    UIFont *fromFont = [UIFont systemFontOfSize:kTLViewFromFontSize];
    _originFromLabel.frame = CGRectMake(startX + kTLViewSubTextLeftMargin,
                                        startY + _originalContentRect.size.height - kTLViewSubCountBottomMargin - kTLViewFromFontSize - 2,
                                        titleWidth,
                                        fromFont.lineHeight + 2);
//    _originFromLabel.text = [NSString stringWithFormat:@"订阅人数 %@", self.timelineTrendObj.originContentObj.subCount];
    _originFromLabel.text = self.timelineTrendObj.originContentObj.abstract;
    _originFromLabel.font = fromFont;
}

- (void)updateTheme
{
    _iconBgImage.image = [UIImage imageNamed:@"subinfo_article_iconBg.png"];
    [super updateTheme];
}
@end
