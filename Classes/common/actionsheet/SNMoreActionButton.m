//
//  SNMoreActionButton.m
//  sohunews
//
//  Created by lhp on 11/20/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNMoreActionButton.h"

@interface SNMoreActionButton ()

@end

@implementation SNMoreActionButton

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame buttonType:(SNMoreActionButtonType) type
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonType = type;
        isNightMode = [[SNThemeManager sharedThemeManager] isNightTheme];
        NSString *picMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
        isNonePicMode = [picMode intValue] == kPicModeWiFi ? YES: NO;
        [self addTarget:self action:@selector(moreActionTouched) forControlEvents:UIControlEventTouchUpInside];
        
        buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kButtonImageWidth, kButtonImageWidth)];
        [self addSubview:buttonImageView];
        
        UIFont *titleFont = [UIFont systemFontOfSize:9.0f];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, kButtonImageWidth+10, 40, 10.0)];
        titleLabel.font = titleFont;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 2;
        titleLabel.textColor = RGBCOLOR(66,66,66);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        [self updateButtonImage];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    buttonImageView.highlighted = highlighted;
    if (buttonType == SNMoreActionButtonTypeNight || buttonType == SNMoreActionButtonTypePic) {
        [self updateButtonImage];
    }
}

- (void)updateButtonImage
{
    UIImage *normalImage = nil;
    UIImage *highlightImage = nil;
    switch (buttonType) {
        case SNMoreActionButtonTypeNight:{
            if (isNightMode) {
                normalImage = [UIImage imageNamed:@"act_btn_default_normal.png"];
                highlightImage = [UIImage imageNamed:@"act_btn_default_highlight.png"];
                titleLabel.text = @"日间模式";
                self.accessibilityLabel = @"日间模式";
            }else {
                normalImage = [UIImage imageNamed:@"act_btn_night_normal.png"];
                highlightImage = [UIImage imageNamed:@"act_btn_night_highlight.png"];
                titleLabel.text = @"夜间模式";
                self.accessibilityLabel = @"夜间模式";
            }
            break;
        }
        case SNMoreActionButtonTypePic:{
            if (isNonePicMode) {
                normalImage = [UIImage imageNamed:@"act_btn_pic_normal.png"];
                highlightImage = [UIImage imageNamed:@"act_btn_pic_highlight.png"];
                titleLabel.text = @"有图模式";
                self.accessibilityLabel = @"有图模式";
            }else {
                normalImage = [UIImage imageNamed:@"act_btn_pic_none_normal.png"];
                highlightImage = [UIImage imageNamed:@"act_btn_pic_none_highlight.png"];
                titleLabel.text = @"无图模式";
                self.accessibilityLabel = @"无图模式";
            }
            break;
        }
        case SNMoreActionButtonTypeUninterested: {
            normalImage = [UIImage imageNamed:@"act_btn_uninterested_normal.png"];
            highlightImage = [UIImage imageNamed:@"act_btn_uninterested_highlight.png"];
            titleLabel.text = @"不感兴趣";
            self.accessibilityLabel = @"不感兴趣";
            break;
        }
        case SNMoreActionButtonTypeReport: {
            normalImage = [UIImage imageNamed:@"act_btn_report_normal.png"];
            highlightImage = [UIImage imageNamed:@"act_btn_report_highlight.png"];
            titleLabel.text = @"举报内容";
            self.accessibilityLabel = @"举报内容";
            break;
        }
        case SNMoreActionButtonTypeShare: {
            normalImage = [UIImage imageNamed:@"act_btn_share_normal.png"];
            highlightImage = [UIImage imageNamed:@"act_btn_share_highlight.png"];
            titleLabel.text = @"分享";
            self.accessibilityLabel = @"分享";
            break;
        }
        default:
            break;
    }
    
    BOOL isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) && !isNight) {
        buttonImageView.image = normalImage;
        buttonImageView.highlightedImage = normalImage;
    }else {
        buttonImageView.image = normalImage;
        buttonImageView.highlightedImage = highlightImage;
    }
    
}

- (void)moreActionTouched
{
    if (buttonType == SNMoreActionButtonTypeNight) {
        isNightMode = !isNightMode;
    }
    
    if (buttonType == SNMoreActionButtonTypePic) {
        isNonePicMode = !isNonePicMode;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(moreActionButtonSelectedType:isNightMode:isNonePicMode:)]) {
        [delegate moreActionButtonSelectedType:buttonType isNightMode:isNightMode isNonePicMode:isNonePicMode];
    }
}

- (void)dealloc
{
    self.delegate = nil;
     //(buttonImageView);
     //(titleLabel);
}

@end
