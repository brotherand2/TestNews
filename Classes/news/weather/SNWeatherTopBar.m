//
//  SNWeatherTopBar.m
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherTopBar.h"
#import "SNThemeManager.h"
#import "UIImage+Utility.h"
#import "UIColor+ColorUtils.h"

#define kSideMargin         (7.0)
#define kTitleFont          (36.0 / 2)
#define kTitleButtonWidth   (80.0)

@implementation SNWeatherTopBar
@synthesize title = _title;
@synthesize titleButton = _titleButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *fileName = nil;
        _titleView = [[UILabel alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.font = [UIFont systemFontOfSize:kTitleFont];
        _titleView.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]];
        [self addSubview:_titleView];
        
        fileName = @"weather_arrow.png";
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
        _arrowView.frame = CGRectMake(-_arrowView.width, -_arrowView.height, (22 / 2), (11 / 2));
        //[self addSubview:_arrowView];
        
        _titleButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - kTitleButtonWidth) / 2,
                                                                  0,
                                                                  kTitleButtonWidth,
                                                                  frame.size.height)];
        _titleButton.showsTouchWhenHighlighted = YES;
        _titleButton.backgroundColor = [UIColor clearColor];
        
        //[self addSubview:_titleButton];
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)image {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
    }
    _backgroundView.image = image;
}

- (void)dealloc {
     //(_title);
     //(_titleView);
     //(_titleButton);
     //(_arrowView);
     //(_backgroundView);
}

- (void)setTitle:(NSString *)title {
     //(_title);
    _title = [title copy];
    [self setNeedsLayout];
}

- (void)titleTouched {
    
}

- (void)layoutSubviews {
    if (self.title) {
        CGSize titleSize = [_title sizeWithFont:[UIFont systemFontOfSize:kTitleFont]];
        _titleView.frame = CGRectMake((self.width - titleSize.width) / 2, 0, titleSize.width, self.height);
        _titleView.text = _title;
        
        _arrowView.frame = CGRectMake(_titleView.right + 3, (self.height - _arrowView.height) / 2, _arrowView.width, _arrowView.height);
    }
}

@end
