//
//  SNSlideshowFooterView.m
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSlideshowFooterView.h"
#import "UIControl+Blocks.h"
#import "UIColor+ColorUtils.h"
#import "NSString+Utilities.h"
#import "SNPhoto.h"
#import "SNPhotoSlideshow.h"
#import "SNAbstractTextView.h"

float const kPictureTitleFont = 18.f;
float const kPictureIndexFont = 13.f;
float const kPictureAbstractContentFont = 13.f;

float const kPictureTitleHeight = 20.f;

float const kPictureIndexWidth = 40.f;
float const kPictureIndexHeight = 14.f;

float const kPictureCommentButtonLeft = 230.f;

float const kPictureAbstractMargin = 10.f; //左右离屏幕的边距
float const kPicturePading = 10.f;  //间隔单位

float const kButtonWidth = 43.f;
float const kButtonHeight = 43.f;


@interface SNSlideshowFooterView()
{
    UIImageView *_maskImageView;
    
    UILabel *_titleLabel;
    UILabel *_indexLabel;
    UITextView *_abstractContentView;
    
    UIButton *_backButton;
    UIButton *_commentButton;
    UIButton *_downloadButton;
    UIButton *_shareButton;
}
@end

@implementation SNSlideshowFooterView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame pictureInfo:nil];
}

- (id)initWithFrame:(CGRect)frame pictureInfo:(SNPhoto *)picture
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        float alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
        
        _maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, -5*kPicturePading, self.width, self.height + 5*kPicturePading)];
        _maskImageView.image = [UIImage imageNamed:@"photo_slideshow_bottomMask.png"];
        _maskImageView.alpha = alpha;
        [self addSubview:_maskImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPictureAbstractMargin, 0.f, self.width - kPictureIndexWidth - 2*kPictureAbstractMargin - kPicturePading, kPictureTitleHeight)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_titleLabel setFont:[UIFont systemFontOfSize:kPictureTitleFont]];
        [_titleLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        _titleLabel.alpha = alpha;
        [self addSubview:_titleLabel];
        
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - kPictureIndexWidth - kPictureAbstractMargin, 0.f, kPictureIndexWidth, kPictureIndexHeight)];
        _indexLabel.bottom = _titleLabel.bottom - 2.f;
        _indexLabel.backgroundColor = [UIColor clearColor];
        [_indexLabel setFont:[UIFont systemFontOfSize:kPictureIndexFont]];
        [_indexLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
        [_indexLabel setTextAlignment:NSTextAlignmentRight];
        _indexLabel.alpha = alpha;
        [self addSubview:_indexLabel];
        
        _abstractContentView = [[SNAbstractTextView alloc] initWithFrame:CGRectMake(2.f, _titleLabel.bottom + 4.f, kAppScreenWidth - kPicturePading/2, 50.f)];
        _abstractContentView.showsVerticalScrollIndicator = YES;
        _abstractContentView.showsHorizontalScrollIndicator = NO;
        _abstractContentView.backgroundColor = [UIColor clearColor];
        _abstractContentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _abstractContentView.scrollsToTop = NO;
        [_abstractContentView setFont:[UIFont systemFontOfSize:kPictureAbstractContentFont]];
        [_abstractContentView setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
        _abstractContentView.alpha = alpha;
        _abstractContentView.editable = NO;
        [self addSubview:_abstractContentView];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, kButtonWidth, kButtonHeight)];
        [_backButton setImage:[UIImage themeImageNamed:@"photo_slideshow_back.png"] forState:UIControlStateNormal];
        _backButton.alpha = alpha;
        _backButton.bottom = self.height;
        _backButton.accessibilityLabel = @"返回";
        [self addSubview:_backButton];
                
        CGFloat btnX = [UIScreen mainScreen].bounds.size.width - kButtonWidth;
        
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0.f, kButtonWidth, kButtonHeight)];
        [_shareButton setImage:[UIImage themeImageNamed:@"photo_slideshow_share.png"] forState:UIControlStateNormal];
        _shareButton.alpha = alpha;
        _shareButton.bottom = _backButton.bottom;
        _shareButton.accessibilityLabel = @"分享";
        [self addSubview:_shareButton];
        
        _downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(_shareButton.left - 4 - kButtonWidth, 0.f, kButtonWidth, kButtonHeight)];
        [_downloadButton setImage:[UIImage themeImageNamed:@"photo_slideshow_download.png"] forState:UIControlStateNormal];
        _downloadButton.alpha = alpha;
        _downloadButton.bottom = _backButton.bottom;
        _downloadButton.accessibilityLabel = @"下载图片";
        [self addSubview:_downloadButton];
                
        [self updateAbstract:picture];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateAbstract:(SNPhoto *)picture
{
    if (picture)
    {
        _titleLabel.text = picture.caption.length > 0 ?
                            picture.caption : (picture.photoSource.title.length > 0 ? picture.photoSource.title: @"");
        SNPhotoSlideshow *photoSource = (SNPhotoSlideshow *)picture.photoSource;
        if ([[photoSource.photos lastObject] isKindOfClass:[NSDictionary class]])
        {
            _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",picture.index + 1,photoSource.photos.count - 1];
        }
        else
        {
            _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",picture.index + 1,photoSource.photos.count];
        }
        _abstractContentView.text = [picture.info trim];
        [_abstractContentView setContentInset:UIEdgeInsetsMake(-7.f, 0.f, -7.f, -7.f)];
        [_abstractContentView setContentOffset:CGPointMake(0.f, 7.f) animated:NO];
        if (_abstractContentView.contentSize.height > _abstractContentView.height)
        {
            [_abstractContentView flashScrollIndicators];
        }
    }
    else
    {
        _titleLabel.text = @"";
        _indexLabel.text = @"";
        _abstractContentView.text = @"";
    }
}

- (void)setBackButtonActionBlock:(SNPictureFooterActionBlock)backButtonActionBlock commentButtonActionBlock:(SNPictureFooterActionBlock)commentButtonActionBlock downloadButtonActionBlock:(SNPictureFooterActionBlock)downloadButtonActionBlock shareButtonActionBlock:(SNPictureFooterActionBlock)shareButtonActionBlock commentCount:(NSString *)commentCount
{
    [_backButton setActionBlock:^(UIControl *control) {
        if (backButtonActionBlock)
        {
            backButtonActionBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
//    [_commentListButton setActionBlock:^(UIControl *control) {
//        if (commentListButtonActionBlock)
//        {
//            commentListButtonActionBlock();
//        }
//    } forControlEvents:UIControlEventTouchUpInside];
    
    [_commentButton setActionBlock:^(UIControl *control) {
        if (commentButtonActionBlock)
        {
            commentButtonActionBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [_downloadButton setActionBlock:^(UIControl *control) {
        if (downloadButtonActionBlock)
        {
            downloadButtonActionBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [_shareButton setActionBlock:^(UIControl *control) {
        if (shareButtonActionBlock)
        {
            shareButtonActionBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
//    [_commentListButton setTitle:(commentCount == nil) ? @"0" : commentCount];
//    _commentListButton.right = _commentButton.left - 4.f;
//    _commentListButton.bottom = _backButton.bottom - 10.f;
}

//- (void)updateCommentCount:(NSString *)commentCount
//{
//    [_commentListButton setTitle:(commentCount == nil) ? @"0" : commentCount];
//    _commentListButton.right = _commentButton.left - 4.f;
//    _commentListButton.bottom = _backButton.bottom - 10.f;
//}

- (void)showAllButtons
{
    _titleLabel.hidden = NO;
    _indexLabel.hidden = NO;
    _abstractContentView.hidden = NO;
    
    _downloadButton.hidden = NO;
    _shareButton.hidden = NO;
    _backButton.hidden = NO;
    _maskImageView.hidden = NO;
}

- (void)showAdButtons
{
    _titleLabel.hidden = YES;
    _indexLabel.hidden = YES;
    _abstractContentView.hidden = YES;
    
    _downloadButton.hidden = YES;
    _shareButton.hidden = NO;
    _backButton.hidden = NO;
    _maskImageView.hidden = NO;
}

- (void)hideAllButtons
{
    _titleLabel.hidden = YES;
    _indexLabel.hidden = YES;
    _abstractContentView.hidden = YES;
    
    _downloadButton.hidden = YES;
    _shareButton.hidden = YES;
    _backButton.hidden = YES;
    _maskImageView.hidden = YES;
}

- (void)updateTheme {
    float alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
    _maskImageView.alpha = alpha;
    [_backButton setImage:[UIImage themeImageNamed:@"photo_slideshow_back.png"] forState:UIControlStateNormal];
    _backButton.alpha = alpha;
    [_downloadButton setImage:[UIImage themeImageNamed:@"photo_slideshow_download.png"] forState:UIControlStateNormal];
    _downloadButton.alpha = alpha;
    [_shareButton setImage:[UIImage themeImageNamed:@"photo_slideshow_share.png"] forState:UIControlStateNormal];
    _shareButton.alpha = alpha;
    
    [_titleLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    _titleLabel.alpha = alpha;
    [_indexLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    _indexLabel.alpha = alpha;
    [_abstractContentView setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    _abstractContentView.alpha = alpha;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

@end
