//
//  SNGalleryBrowserFooter.m
//  sohunews
//
//  Created by Huang Zhen on 06/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNGalleryBrowserFooter.h"

float const kPhotoTitleFont = 18.f;
float const kPhotoIndexFont = 13.f;
float const kPhotoAbstractContentFont = 13.f;

float const kPhotoTitleHeight = 20.f;

float const kPhotoIndexWidth = 60.f;
float const kPhotoIndexHeight = 14.f;

float const kPhotoCommentButtonLeft = 230.f;

float const kPhotoAbstractMargin = 10.f; //左右离屏幕的边距
float const kPhotoPading = 10.f;  //间隔单位

float const kBackButtonWidth = 43.f;
float const kBackButtonHeight = 43.f;

@interface SNGalleryBrowserFooter ()

@end

@implementation SNGalleryBrowserFooter

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createContent];
    }
    return self;
}

- (void)createContent {
    self.backgroundColor = [UIColor clearColor];
    float alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
    
    self.maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, -5*kPhotoPading, self.width, self.height + 5*kPhotoPading)];
    self.maskImageView.image = [UIImage imageNamed:@"photo_slideshow_bottomMask.png"];
    self.maskImageView.alpha = alpha;
    [self addSubview:self.maskImageView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPhotoAbstractMargin, 0.f, self.width - kPhotoIndexWidth - 2*kPhotoAbstractMargin - kPhotoPading, kPhotoTitleHeight)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kPhotoTitleFont]];
    [self.titleLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    self.titleLabel.alpha = alpha;
    [self addSubview:self.titleLabel];
    
    self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - kPhotoIndexWidth - kPhotoAbstractMargin, 0.f, kPhotoIndexWidth, kPhotoIndexHeight)];
    self.indexLabel.bottom = self.titleLabel.bottom - 2.f;
    self.indexLabel.numberOfLines = 1;
    self.indexLabel.backgroundColor = [UIColor clearColor];
    [self.indexLabel setFont:[UIFont systemFontOfSize:kPhotoIndexFont]];
    [self.indexLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    [self.indexLabel setTextAlignment:NSTextAlignmentRight];
    self.indexLabel.alpha = alpha;
    [self addSubview:self.indexLabel];
    
    self.abstractContentView = [[SNAbstractTextView alloc] initWithFrame:CGRectMake(2.f, self.titleLabel.bottom + 4.f, kAppScreenWidth - kPhotoPading/2, 50.f)];
    self.abstractContentView.showsVerticalScrollIndicator = YES;
    self.abstractContentView.showsHorizontalScrollIndicator = NO;
    self.abstractContentView.backgroundColor = [UIColor clearColor];
    self.abstractContentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.abstractContentView.scrollsToTop = NO;
    [self.abstractContentView setFont:[UIFont systemFontOfSize:kPhotoAbstractContentFont]];
    [self.abstractContentView setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    self.abstractContentView.alpha = alpha;
    self.abstractContentView.editable = NO;
    self.abstractContentView.selectable = NO;
    [self addSubview:self.abstractContentView];
 
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, kBackButtonWidth, kBackButtonHeight)];
    [self.backButton setImage:[UIImage themeImageNamed:@"photo_slideshow_back.png"] forState:UIControlStateNormal];
    self.backButton.alpha = alpha;
    self.backButton.bottom = self.height;
    self.backButton.accessibilityLabel = @"返回";
    [self addSubview:self.backButton];
    CGFloat btnX = [UIScreen mainScreen].bounds.size.width - kBackButtonWidth;
    
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0.f, kBackButtonWidth, kBackButtonHeight)];
    [self.shareButton setImage:[UIImage themeImageNamed:@"icoatlas_share_v5.png"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage themeImageNamed:@"icoatlas_sharepress_v5.png"] forState:UIControlStateHighlighted];
    self.shareButton.alpha = alpha;
    self.shareButton.bottom = self.backButton.bottom;
    self.shareButton.accessibilityLabel = @"分享";
    [self addSubview:self.shareButton];
    
    self.downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(self.shareButton.left - 4 - kBackButtonWidth, 0.f, kBackButtonWidth, kBackButtonHeight)];
    [self.downloadButton setImage:[UIImage themeImageNamed:@"photo_slideshow_download.png"] forState:UIControlStateNormal];
    self.downloadButton.alpha = alpha;
    self.downloadButton.bottom = self.backButton.bottom;
    self.downloadButton.accessibilityLabel = @"下载图片";
    [self addSubview:self.downloadButton];
    
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];

}

- (void)updateAbstract:(NSString *)abstract title:(NSString *)newsTitle currentIndex:(NSUInteger)index total:(NSUInteger)count;
{

    self.titleLabel.text = newsTitle.length > 0 ? newsTitle : @"";
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",index + 1,count];
    self.indexLabel.right = self.width - kPhotoAbstractMargin;
    if (abstract.trim.length == 0) {
        self.titleLabel.height = kPhotoTitleHeight * 2 + 4;
        self.titleLabel.numberOfLines = 0;
        self.abstractContentView.text = @"";
    }else{
        self.titleLabel.height = kPhotoTitleHeight;
        self.abstractContentView.text = [abstract trim];
    }
    [self.abstractContentView setContentInset:UIEdgeInsetsMake(-7.f, 0.f, -7.f, -7.f)];
    [self.abstractContentView setContentOffset:CGPointMake(0.f, 7.f) animated:NO];
    if (self.abstractContentView.contentSize.height > self.abstractContentView.height)
    {
        [self.abstractContentView flashScrollIndicators];
    }
}

- (void)updateIndex:(NSUInteger)index count:(NSUInteger)count {
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",index + 1,count];
}

- (void)updateTheme
{
    float alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
    self.maskImageView.alpha = alpha;
    [self.backButton setImage:[UIImage themeImageNamed:@"photo_slideshow_back.png"] forState:UIControlStateNormal];
    self.backButton.alpha = alpha;
    [self.downloadButton setImage:[UIImage themeImageNamed:@"photo_slideshow_download.png"] forState:UIControlStateNormal];
    self.downloadButton.alpha = alpha;
    [self.shareButton setImage:[UIImage themeImageNamed:@"photo_slideshow_share.png"] forState:UIControlStateNormal];
    self.shareButton.alpha = alpha;
    
    [self.titleLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    self.titleLabel.alpha = alpha;
    [self.indexLabel setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    self.indexLabel.alpha = alpha;
    [self.abstractContentView setTextColor:[UIColor colorWithCGColor:SNUICOLORREF(kPhotoSliderAbstractTextColor)]];
    self.abstractContentView.alpha = alpha;
}

- (void)setBackButtonActionBlock:(SNPictureFooterActionBlock)backButtonActionBlock
       downloadButtonActionBlock:(SNPictureFooterActionBlock)downloadButtonActionBlock
          shareButtonActionBlock:(SNPictureFooterActionBlock)shareButtonActionBlock

{
    [_backButton setActionBlock:^(UIControl *control) {
        if (backButtonActionBlock)
        {
            backButtonActionBlock();
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
}

- (void)hideSomeButtons {
    
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

@end
