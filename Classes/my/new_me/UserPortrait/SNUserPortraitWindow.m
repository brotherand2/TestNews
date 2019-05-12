//
//  SNUserPortraitWindow.m
//  sohunews
//
//  Created by wang shun on 2017/1/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserPortraitWindow.h"
#import "SNUserPortrait.h"

@implementation SNUserPortraitWindow

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    self.layer.cornerRadius = 4;
    self.backgroundColor = [UIColor grayColor];
    
    _contentlabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.bounds.size.width-10, self.bounds.size.height-10)];
    _contentlabel.font = [SNUserPortrait windowFont];
    _contentlabel.numberOfLines = 0;
    _contentlabel.backgroundColor = [UIColor clearColor];
    _contentlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_contentlabel];
    
}

- (void)setContentText:(NSString *)str{
    [_contentlabel setText:str];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
