//
//  UISwitchCityButton.m
//  sohunews
//
//  Created by wangyy on 15/5/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "UISwitchCityButton.h"
#import "NSCellLayout.h"

@implementation UISwitchCityButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        UIImageView *ButtonBg = [[UIImageView alloc] initWithFrame:CGRectZero];
//        ButtonBg.backgroundColor = [UIColor clearColor];
//        [self addSubview:ButtonBg];
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width -12 -CONTENT_LEFT, 13, 11, 11)];
        iconImageView.image = [UIImage themeImageNamed:@"icoLocal_location_v5.png"];
        iconImageView.highlightedImage = [UIImage themeImageNamed:@"icoLocal_locationpress_v5.png"];
        [self addSubview:iconImageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 45, 12)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"切换城市";
        titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.right = iconImageView.left - 1;
        [self addSubview:titleLabel];
        
//        CGFloat width = 7 + titleLabel.size.width + 2 + iconImageView.size.width + 3;
//        ButtonBg.frame = CGRectMake(0, 10, width, 22);
//        ButtonBg.right = self.right - CONTENT_LEFT;
//        ButtonBg.image = [UIImage themeImageNamed:@"icohouse_bg_v5@2x.png"];
//        if ([ButtonBg.image respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
//            ButtonBg.image = [ButtonBg.image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
//        }
//        else{
//            ButtonBg.image = [ButtonBg.image stretchableImageWithLeftCapWidth:20 topCapHeight:10];
//        }
//          [ButtonBg release];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    iconImageView.highlighted = highlighted;
}


- (void)updateTheme{
    iconImageView.image = [UIImage themeImageNamed:@"icoLocal_location_v5.png"];
    iconImageView.highlightedImage = [UIImage themeImageNamed:@"icoLocal_locationpress_v5.png"];
}

@end
