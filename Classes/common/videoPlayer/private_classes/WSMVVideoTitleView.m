//
//  WSMVVideoTitleView.m
//  WeSee
//
//  Created by handy wang on 9/6/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoTitleView.h"
#import "UIViewAdditions+WSMV.h"

#define kRecommendBtnWidth                                  (166.0f/2.0f)
#define kRecommendBtnHeight                                 (88/2.0f)
#define kRecommendBtnMarginRight                            (20.0f/2.0f)
#define kRecommendBtnMarginTop                              (20.0f/2.0f)

#define kHeadlineTitlePaddingRightToRecommendBtn_FullScreen (10.0f)
#define kHeadlineMarginTop_NonFullScreen                    (14.0f/2.0f)
#define kHeadlineMarginTop_FullScreen                       (14.0f/2.0f)
#define kHeadlineMarginLeftAndRight                         (7.0f)
#define kHeadlineTitleWidth_NonFullScreen                   (self.width-2*kHeadlineMarginLeftAndRight-15.f)
#define kHeadlineTitleWidth_FullScreen                      (self.width-2*kHeadlineMarginLeftAndRight-kHeadlineTitlePaddingRightToRecommendBtn_FullScreen-kRecommendBtnWidth)

#define kHeadlineTitleHeight_FullScreen                     (30.0f/2.0f)
#define kHeadlineTitleFontSize_FullScreen                   (28.0f/2.0f)

#define kSubtitleHeight_FullScreen                          (20.0f/2.0f)
#define kSubtitleFontSize_FullScreen                        (18.0f/2.0f)

#define kSubtitleFontSize_NonFullScreen                     (18.0f/2.0f)
#define kSubtitleHeight_NonFullScreen                       (20.0f/2.0f)

#define kSubtitlePaddingTopToHeadline                       (10.0f/2.0f)

@implementation WSMVVideoTitleView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame delegate:(id)delegateParam {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.image = [[UIImage imageNamed:@"wsmv_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        
        //Headline label
        BOOL _isFullScreen = NO;
        if ([self.delegate respondsToSelector:@selector(isFullScreen)]) {
            _isFullScreen = [self.delegate isFullScreen];
        }
        self.headlineLabel = [[UILabel alloc] init];
        self.headlineLabel.numberOfLines = 1;
        CGFloat _headlineLabelWidth = _isFullScreen ? kHeadlineTitleWidth_FullScreen : kHeadlineTitleWidth_NonFullScreen;
        self.headlineLabel.frame = CGRectMake(kHeadlineMarginLeftAndRight, kHeadlineMarginTop_NonFullScreen, _headlineLabelWidth, kHeadlineTitleHeight_NonFullScreen);
        self.headlineLabel.backgroundColor = [UIColor clearColor];
        self.headlineLabel.textAlignment = NSTextAlignmentLeft;
        self.headlineLabel.font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
        self.headlineLabel.textColor = [UIColor whiteColor];
        self.headlineLabel.numberOfLines = NSIntegerMax;
        self.headlineLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.headlineLabel];
        
        //Subtitle label
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.frame = CGRectMake(kHeadlineMarginLeftAndRight, CGRectGetMaxY(self.headlineLabel.frame)+kSubtitlePaddingTopToHeadline,self.headlineLabel.width, kSubtitleHeight_NonFullScreen);
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        self.subtitleLabel.textAlignment   = NSTextAlignmentLeft;
        self.subtitleLabel.font = [UIFont systemFontOfSize:kSubtitleFontSize_NonFullScreen];
        self.subtitleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        self.subtitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
        self.subtitleLabel.shadowColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.5f];
        [self addSubview:self.subtitleLabel];
        
        //Recommend btn
        self.recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.recommendBtn.frame = CGRectMake(0,
                                             1,
                                             kRecommendBtnWidth,
                                             kRecommendBtnHeight);
        self.recommendBtn.left = kRecommendBtnMarginTop;
        self.recommendBtn.exclusiveTouch = YES;
        self.recommendBtn.hidden = YES;
        self.recommendBtn.backgroundColor = [UIColor clearColor];
        [self.recommendBtn setBackgroundImage:[UIImage imageNamed:@"wsmv_recommend_btn.png"] forState:UIControlStateNormal];
        [self.recommendBtn setBackgroundImage:[UIImage imageNamed:@"wsmv_recommend_btn_hl.png"] forState:UIControlStateHighlighted];
        [self.recommendBtn addTarget:self action:@selector(recommendAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.recommendBtn];
    }
    return self;
}


#pragma mark - Public

- (void)updateViewsInFullScreenMode {
    self.image = [[UIImage imageNamed:@"wsmv_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    
    self.headlineLabel.font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_FullScreen];
    self.headlineLabel.height = kHeadlineTitleHeight_FullScreen;
    self.headlineLabel.top = kHeadlineMarginTop_FullScreen;
    self.headlineLabel.width = kHeadlineTitleWidth_FullScreen;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        self.headlineLabel.left = 7+24;
    }
    
    self.subtitleLabel.font = [UIFont systemFontOfSize:kSubtitleFontSize_FullScreen];
    self.subtitleLabel.height = kSubtitleHeight_FullScreen;
    self.subtitleLabel.top = CGRectGetMaxY(self.headlineLabel.frame)+kSubtitlePaddingTopToHeadline;
    self.subtitleLabel.width = self.headlineLabel.width;
    
    self.recommendBtn.center = self.headlineLabel.center;
    self.recommendBtn.left = self.width - kRecommendBtnMarginRight - kRecommendBtnWidth;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        self.recommendBtn.left = self.width - kRecommendBtnMarginRight - kRecommendBtnWidth - 20;
    }
    self.recommendBtn.hidden = NO;
    
    [self updateHeadline:self.headlineLabel.text subtitle:self.subtitleLabel.text];
}

- (void)updateViewsInNonScreenMode {
    self.image = [[UIImage imageNamed:@"wsmv_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    
    self.headlineLabel.font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
    self.headlineLabel.height = kHeadlineTitleHeight_NonFullScreen;
    self.headlineLabel.top = kHeadlineMarginTop_NonFullScreen;
    self.headlineLabel.width = kHeadlineTitleWidth_NonFullScreen;
    
    self.subtitleLabel.font = [UIFont systemFontOfSize:kSubtitleFontSize_NonFullScreen];
    self.subtitleLabel.height = kSubtitleHeight_NonFullScreen;
    self.subtitleLabel.top = CGRectGetMaxY(self.headlineLabel.frame)+kSubtitlePaddingTopToHeadline;
    self.subtitleLabel.width = self.headlineLabel.width;
    
    self.recommendBtn.hidden = YES;
    
    [self updateHeadline:self.headlineLabel.text subtitle:self.subtitleLabel.text];
}

- (void)updateHeadline:(NSString *)headline subtitle:(NSString *)subtitle {
    self.headlineLabel.text = headline;
    if (self.headlineLabel.text.length <= 0) {
        self.headlineLabel.hidden = YES;
    }
    else {
        self.headlineLabel.hidden = NO;
    }
    
    self.subtitleLabel.text = subtitle;
    if (subtitle.length <= 0) {
        self.subtitleLabel.hidden = YES;
    }
    else {
        self.subtitleLabel.hidden = NO;
    }
    
    //--- 动态两行或一行
    CGSize headlineTextSize = CGSizeZero;
    if ([self.delegate isFullScreen]) {
        UIFont *font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_FullScreen];
        CGSize constrainedSize = CGSizeMake(kHeadlineTitleWidth_FullScreen, self.height);
        headlineTextSize = [headline sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
        headlineTextSize.width = kHeadlineTitleWidth_FullScreen;
    }
    else {
        UIFont *font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
        CGSize constrainedSize = CGSizeMake(kHeadlineTitleWidth_NonFullScreen, self.height);
        headlineTextSize = [headline sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
        headlineTextSize.width = kHeadlineTitleWidth_NonFullScreen;
        headlineTextSize.height = ceilf(headlineTextSize.height);
        if (headlineTextSize.height > 38) {
            headlineTextSize.height = 39;
        }
    }
    self.headlineLabel.size = headlineTextSize;
    
    self.subtitleLabel.top = self.headlineLabel.bottom + kSubtitlePaddingTopToHeadline;
}

#pragma mark - Private
- (void)recommendAction {
    if ([self.delegate respondsToSelector:@selector(didTapRecommendBtn)]) {
        [self.delegate didTapRecommendBtn];
    }
}

@end
