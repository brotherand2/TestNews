//
//  SNTimelineVideoCellTitleView.m
//  sohunews
//
//  Created by handy wang on 11/23/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoCellTitleView.h"

#define kHeadlineMarginTop_NonFullScreen                    (22.0f/2.0f)
#define kHeadlineMarginLeftAndRight                         (20.0f/2.0f)
#define kHeadlineTitleWidth_NonFullScreen                   (self.width-2*kHeadlineMarginLeftAndRight)
#define kSubtitlePaddingTopToHeadline                       (10.0f/2.0f)
#define kSubtitleHeight_NonFullScreen                       (20.0f/2.0f)
#define kSubtitleFontSize_FullScreen                        (18.0f/2.0f)
#define kSubtitleFontSize_NonFullScreen                     (18.0f/2.0f)


@interface SNTimelineVideoCellTitleView()
@property (nonatomic, strong)UILabel    *titleLabel;
@property (nonatomic, strong)UILabel    *subtitleLabel;
@end

@implementation SNTimelineVideoCellTitleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
//        self.image = [[UIImage imageNamed:@"timeline_videoplay_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        
        CGRect titleLabelFrame = CGRectMake(kHeadlineMarginLeftAndRight,
                                            kHeadlineMarginTop_NonFullScreen,
                                            kHeadlineTitleWidth_NonFullScreen,
                                            kHeadlineTitleHeight_NonFullScreen);
        self.titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
        self.titleLabel.numberOfLines = NSIntegerMax;
        self.titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingHeadLineTextColor]];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];
        
        //Subtitle label
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom+kSubtitlePaddingTopToHeadline,
                                              self.titleLabel.width, kSubtitleHeight_NonFullScreen);
        self.subtitleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingHeadLineTextColor]];
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        self.subtitleLabel.textAlignment   = NSTextAlignmentLeft;
        self.subtitleLabel.font = [UIFont systemFontOfSize:kSubtitleFontSize_NonFullScreen];
        [self addSubview:self.subtitleLabel];
        
        //Notification
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    
}

#pragma mark - Public
- (void)updateTitle:(NSString *)titleText subTitle:(NSString *)subtitleText {
    self.titleLabel.text = titleText;
    self.subtitleLabel.text = subtitleText;
    
    if (titleText.length <= 0) {
        return;
    }
    self.image = [[UIImage imageNamed:@"timeline_videoplay_titleviewbg_nonfullscreen.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];

    CGSize headlineTextSize = CGSizeZero;
    UIFont *font = [UIFont systemFontOfSize:kHeadlineTitleFontSize_NonFullScreen];
    CGSize constrainedSize = CGSizeMake(kHeadlineTitleWidth_NonFullScreen, self.height);
    headlineTextSize = [titleText sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
    headlineTextSize.width = kHeadlineTitleWidth_NonFullScreen;
    headlineTextSize.height = ceilf(headlineTextSize.height);
    if (headlineTextSize.height > 38) {
        headlineTextSize.height = 38;
    }
    self.titleLabel.size = headlineTextSize;
    self.subtitleLabel.top = self.titleLabel.bottom + kSubtitlePaddingTopToHeadline;
}

#pragma mark - Private
- (void)updateTheme:(NSNotification *)notifiction {
    NSString *strTitleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingHeadLineTextColor];
    self.titleLabel.textColor = [UIColor colorFromString:strTitleColor];
    self.subtitleLabel.textColor = [UIColor colorFromString:strTitleColor];
}

@end
