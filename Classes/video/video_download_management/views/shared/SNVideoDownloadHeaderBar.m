//
//  SNVideoDownloadHeaderBar.m
//  sohunews
//
//  Created by handy wang on 8/30/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadHeaderBar.h"
#import "UIColor+ColorUtils.h"

#define kTitleLabelMarginLeft                                       (10.0f)
#define kTitleLabelFontSize                                         (21.0f)

@interface SNVideoDownloadHeaderBar()
@property (nonatomic, strong)UILabel *titleLabel;
@end

@implementation SNVideoDownloadHeaderBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        
        //Title label
        self.titleLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(kTitleLabelMarginLeft,
                                                                                     kSystemBarHeight,
                                                                                     self.width-kTitleLabelMarginLeft,
                                                                                     self.height-kSystemBarHeight)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment   = NSTextAlignmentLeft;
        self.titleLabel.textColor       = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadHeaderBar_TitleTextColor]];
        self.titleLabel.font            = [UIFont systemFontOfSize:kTitleLabelFontSize];
        self.titleLabel.text            = NSLocalizedString(@"kVideoDownloadHeaderBar_Title", nil);
        [self addSubview:self.titleLabel];
        
        //添加红线
        UIImage *image = [UIImage themeImageNamed:@"icotitlebar_redstripe_v5.png"];
        image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 170, 2)];
        imageView.top = self.titleLabel.bottom - kSystemBarHeight - 3.0;
        imageView.image = image;
        [self.titleLabel addSubview:imageView];
        
        [SNNotificationManager addObserver: self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    float lineW = [UIScreen mainScreen].scale == 2.0f ? 0.5f : 1.0f;
    //用2像素的白色描边遮挡1像素的灰色描边,达到画1像素灰线下面2像素白线的目的
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
	CGContextSetFillColorWithColor(context, grayColor.CGColor);
    float yPos = self.bounds.size.height-lineW*2;
    CGRect tempRect = CGRectMake(0, yPos, self.bounds.size.width, lineW);
    CGContextFillRect(context, tempRect);
    
    UIColor *whiteColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor2]];
    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    yPos = self.bounds.size.height-lineW;
    tempRect = CGRectMake(0, yPos, self.bounds.size.width, lineW);
    CGContextFillRect(context, tempRect);
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.titleLabel.textColor = SNUICOLOR(kVideoDownloadHeaderBar_TitleTextColor);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
