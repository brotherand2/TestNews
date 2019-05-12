//
//  SNShareItemView.m
//  sohunews
//
//  Created by TengLi on 2017/6/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareItemView.h"
#import "SNNewsShareParamsHeader.h"

@interface SNShareItemView ()

@end

@implementation SNShareItemView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title iconName:(NSString *)iconName
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        [self setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@press_v5.png",[iconName substringToIndex:iconName.length - 7],iconName]] forState:UIControlStateHighlighted];
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [self setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
        [self setTitleColor:SNUICOLOR(kThemeBg1Color) forState:UIControlStateHighlighted];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGFloat horizontal_space = kAppScreenHeight* (14/1280.0);
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.frame.size.height - newFrame.size.height;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    
    // Center image
    [self.imageView setFrame:CGRectMake(0, 0, newFrame.origin.y-horizontal_space, newFrame.origin.y-horizontal_space)];
    
    self.imageView.center = CGPointMake(self.frame.size.width/2.0, (self.frame.size.height-self.titleLabel.frame.size.height-horizontal_space)/2.0);
}

@end
