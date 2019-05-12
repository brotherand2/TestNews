//
//  SNVideoComplexImageView.m
//  sohunews
//
//  Created by weibin cheng on 14-8-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNVideoComplexImageView.h"


@implementation SNVideoComplexImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 55 * kAppScreenWidth / 320)];
        _imageView.defaultImage = [UIImage themeImageNamed:@"rolling_default_image.png"];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode= UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
        
        NSString* colorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.bottom + 5, self.width, 13)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor colorFromString:colorString];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.numberOfLines = 1;
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)dealloc
{
     //(_imageView);
     //(_titleLabel);
     //(_clickBlock);
}

- (void)handleTapGesture:(UITapGestureRecognizer*)gesture
{
    if(self.clickBlock)
        self.clickBlock(self.tag);
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setImageUrl:(NSString *)url
{
    _imageView.urlPath = url;
}

- (void)updateTheme
{
    NSString* colorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor];
    _titleLabel.textColor = [UIColor colorFromString:colorString];
    _imageView.alpha = themeImageAlphaValue();
    _imageView.contentMode= UIViewContentModeScaleToFill;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
