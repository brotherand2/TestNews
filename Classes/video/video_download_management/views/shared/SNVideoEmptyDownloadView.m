//
//  SNVideoEmptyDownloadView.m
//  sohunews
//
//  Created by handy wang on 8/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoEmptyDownloadView.h"
#import "UIColor+ColorUtils.h"

#define kImgViewMarginTop                           (230.0f/2.0f)

#define kPaddingTopBtwImgViewAndHeadline            (11)
#define kHeadlineLabelWidth                         (300.0f)
#define kHeadlineLabelHeight                        (26.0f)
#define kHeadlineFontSize                           (30.0f/2.0f)

#define kPaddingTopBtwHeadlineAndSubhead            (10.0f/2.0f)
#define kSubheadLabelWidth                          (300.0f)
#define kSubheadLabelHeight                         (14.0f)
#define kSubheadFontSize                            (24.0f/2.0f)

@interface SNVideoEmptyDownloadView()
@property (nonatomic, strong)UIImageView    *imgView;
@property (nonatomic, strong)UILabel        *headlineLabel;
@property (nonatomic, strong)UILabel        *subheadLabel;
@end

@implementation SNVideoEmptyDownloadView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor            = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        
        //Img view
        UIImage *emptyImg = [UIImage imageNamed:@"video_download_empty_img.png"];
        self.imgView                    = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-emptyImg.size.width)/2.0f,
                                                                                        (self.height-emptyImg.size.width)/2.0f-25,
                                                                                        emptyImg.size.width,
                                                                                        emptyImg.size.height)];
        self.imgView.image              = emptyImg;
        [self addSubview:self.imgView];
        
        //Headline
        self.headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.width-kHeadlineLabelWidth)/2.0f,
                                                                        CGRectGetMaxY(self.imgView.frame)+kPaddingTopBtwImgViewAndHeadline,
                                                                        kHeadlineLabelWidth,
                                                                        kHeadlineLabelHeight)];
        self.headlineLabel.backgroundColor  = [UIColor clearColor];
        self.headlineLabel.font             = [UIFont systemFontOfSize:kHeadlineFontSize];
        self.headlineLabel.textAlignment    = NSTextAlignmentCenter;
        self.headlineLabel.text             = NSLocalizedString(@"kVideoEmptyDownloadView_HeadlineText", nil);
        self.headlineLabel.textColor        = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoEmptyDownloadView_HeadlineTextColor]];
        CGSize headLabelActualSize = [self.headlineLabel.text sizeWithFont:[UIFont systemFontOfSize:kHeadlineFontSize]];
        self.headlineLabel.height = headLabelActualSize.height;
        [self addSubview:self.headlineLabel];
        
        //Subhead
        self.subheadLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.width-kSubheadLabelWidth)/2.0f,
                                                                       self.headlineLabel.bottom+kPaddingTopBtwHeadlineAndSubhead,
                                                                       kSubheadLabelWidth,
                                                                       kSubheadLabelHeight)];
        self.subheadLabel.backgroundColor   = [UIColor clearColor];
        self.subheadLabel.font              = [UIFont systemFontOfSize:kSubheadFontSize];
        self.subheadLabel.textAlignment     = NSTextAlignmentCenter;
        self.subheadLabel.text              = nil;
        self.subheadLabel.textColor         = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoEmptyDownloadView_SubheadTextColor]];
        CGSize subheadLabelActualSize = [self.subheadLabel.text sizeWithFont:[UIFont systemFontOfSize:kSubheadFontSize]];
        self.subheadLabel.height = subheadLabelActualSize.height;
        [self addSubview:self.subheadLabel];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.imgView.image = [UIImage imageNamed:@"video_download_empty_img.png"];
    self.headlineLabel.textColor = SNUICOLOR(kVideoEmptyDownloadView_HeadlineTextColor);
    self.subheadLabel.textColor = SNUICOLOR(kVideoEmptyDownloadView_SubheadTextColor);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
