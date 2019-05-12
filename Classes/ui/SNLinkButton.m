//
//  SNLinkButton.m
//  sohunews
//
//  Created by guoyalun on 7/1/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNLinkButton.h"
#import "UIColor+ColorUtils.h"
@interface SNLinkButton()
{
    UIImageView *linkIconView;
    UIImageView *linkArrowView;
}
@end

@implementation SNLinkButton
@synthesize url;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundImage:[[UIImage imageNamed:@"link_bg.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:6] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"link_bgpress.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:6] forState:UIControlStateHighlighted];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 2)];
        titleLabel.text = @"打开链接";
        titleLabel.userInteractionEnabled = NO;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:@"night"]) {
            titleLabel.textColor = [UIColor colorFromString:@"5f7081"];
        } else {
            titleLabel.textColor = [UIColor colorFromString:@"6f8bb7"];
        }
        [self addSubview:titleLabel];
        
        UIImage *image1 = [UIImage imageNamed:@"link_icon.png"];
        
        CGFloat imageHeight = self.height*30.0/53.0;
        CGFloat imageWidth = image1.size.width * (self.height*30.0/53.0)/image1.size.height;

        linkIconView = [[UIImageView alloc] initWithImage:image1];
        linkIconView.frame = CGRectMake(floorf(self.width*20.0/222.0), ceilf((self.height*19.0/53.0)/2),imageWidth,imageHeight);
        [self addSubview:linkIconView];

        linkArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"link_arrow.png"]];
        linkArrowView.frame = CGRectMake(floorf(self.width*184.0/222.0), ceilf((self.height*19.0/53.0)/2),imageWidth,imageHeight);
        [self addSubview:linkArrowView];
    }
    return self;
}

- (void)setTitleFont:(UIFont *)font
{
    titleLabel.font = font;
    titleLabel.frame = CGRectMake(0, (self.height-font.lineHeight+(font.lineHeight-font.pointSize)/2)/2, self.width, font.lineHeight);
}

- (UILabel *)titleLabel
{
    return titleLabel;
}


@end
