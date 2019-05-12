//
//  SNTimelineVideoTitleView.m
//  sohunews
//
//  Created by handy wang on 11/15/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoTitleView.h"

#define kRecommendBtnWidth                                  (166.0f/2.0f)

#define kHeadlineTitleFontSize_FullScreen                   (28.0f/2.0f)
#define kHeadlineMarginTop_NonFullScreen                    (22.0f/2.0f)

#define kHeadlineTitlePaddingRightToRecommendBtn_FullScreen (10.0f)
#define kHeadlineMarginLeftAndRight                         (20.0f/2.0f)
#define kHeadlineTitleWidth_NonFullScreen                   (self.width-2*kHeadlineMarginLeftAndRight)
#define kHeadlineTitleWidth_FullScreen                      (self.width-2*kHeadlineMarginLeftAndRight-kHeadlineTitlePaddingRightToRecommendBtn_FullScreen-kRecommendBtnWidth)

#define kSubtitlePaddingTopToHeadline                       (10.0f/2.0f)

@implementation SNTimelineVideoTitleView

- (id)initWithFrame:(CGRect)frame delegate:(id)delegateParam {
    if (self = [super initWithFrame:frame delegate:delegateParam]) {
        self.userInteractionEnabled = NO;
        self.image = [[UIImage imageNamed:@"timeline_videoplay_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        
        self.headlineLabel.left = kHeadlineMarginLeftAndRight;
        self.headlineLabel.top = kHeadlineMarginTop_NonFullScreen;
        self.headlineLabel.font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
        self.headlineLabel.height = kHeadlineTitleHeight_NonFullScreen;
        self.headlineLabel.width = kHeadlineTitleWidth_NonFullScreen;
        self.headlineLabel.numberOfLines = NSIntegerMax;
        self.headlineLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingHeadLineTextColor]];

        [self.subtitleLabel removeFromSuperview];
        self.subtitleLabel = nil;
//        self.subtitleLabel.left = self.headlineLabel.left;
//        self.subtitleLabel.top = self.headlineLabel.bottom + kSubtitlePaddingTopToHeadline;
//        self.subtitleLabel.textColor = [UIColor colorFromString:strTitleColor];
        
        //Notification
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
}

- (void)updateViewsInFullScreenMode {
    [super updateViewsInFullScreenMode];
    self.userInteractionEnabled = YES;
    
    self.image = [[UIImage imageNamed:@"wsmv_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    
    self.headlineLabel.width = kHeadlineTitleWidth_FullScreen;
    
    [self updateHeadlineSizeWithText:self.headlineLabel.text];
}

- (void)updateViewsInNonScreenMode {
    [super updateViewsInNonScreenMode];
    self.userInteractionEnabled = NO;
    
    self.height = kTimelineVideoTitleViewHeight_NonFullScreen;

    self.image = [[UIImage imageNamed:@"timeline_videoplay_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];

    self.headlineLabel.width = kHeadlineTitleWidth_NonFullScreen;
    self.headlineLabel.font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
    self.headlineLabel.height = kHeadlineTitleHeight_NonFullScreen;
    self.headlineLabel.top = kHeadlineMarginTop_NonFullScreen;
    
    [self updateHeadlineSizeWithText:self.headlineLabel.text];
}

- (void)updateHeadline:(NSString *)headline subtitle:(NSString *)subtitle {
    [super updateHeadline:headline subtitle:subtitle];
    
    [self updateHeadlineSizeWithText:headline];
}

- (void)updateHeadlineSizeWithText:(NSString *)headlineText {
    if (headlineText.length <= 0) {
        return;
    }

    CGSize headlineTextSize = CGSizeZero;
    if ([self.delegate isFullScreen]) {
        UIFont *font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_FullScreen];
        CGSize constrainedSize = CGSizeMake(kHeadlineTitleWidth_FullScreen, self.height);
        headlineTextSize = [headlineText sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
        headlineTextSize.width = kHeadlineTitleWidth_FullScreen;
    }
    else {
        UIFont *font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
        CGSize constrainedSize = CGSizeMake(kHeadlineTitleWidth_NonFullScreen, self.height);
        headlineTextSize = [headlineText sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
        headlineTextSize.width = kHeadlineTitleWidth_NonFullScreen;
        headlineTextSize.height = ceilf(headlineTextSize.height);
        if (headlineTextSize.height > 38) {
            headlineTextSize.height = 38;
        }
    }
    self.headlineLabel.size = headlineTextSize;
    
    self.subtitleLabel.top = self.headlineLabel.bottom + kSubtitlePaddingTopToHeadline;
}

- (void)updateTheme:(NSNotification *)notifiction {
    NSString *strTitleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingHeadLineTextColor];
    self.headlineLabel.textColor = [UIColor colorFromString:strTitleColor];
    self.subtitleLabel.textColor = [UIColor colorFromString:strTitleColor];
}

@end
