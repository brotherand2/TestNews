//
//  SNNewsLastThirdLoginIcon.m
//  sohunews
//
//  Created by wang shun on 2017/9/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLastThirdLoginIcon.h"

@interface SNNewsLastThirdLoginIcon ()

@property (nonatomic,strong) UILabel* lastlabel;//上次登录

@end

@implementation SNNewsLastThirdLoginIcon

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.image = [UIImage themeImageNamed:@"ico_dlbg_v5.png"];
        [self createLabel];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)createLabel{
    self.lastlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, self.bounds.size.width, self.bounds.size.height)];
    [self.lastlabel setTextAlignment:NSTextAlignmentCenter];
    [self.lastlabel setTextColor:SNUICOLOR(kThemeText5Color)];
    [self.lastlabel setBackgroundColor:[UIColor clearColor]];
    self.lastlabel.font = [UIFont systemFontOfSize:9];
    [self addSubview:_lastlabel];
    self.lastlabel.text = @"上次登录";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
