//
//  SNNewsScreenShareTouchView.m
//  sohunews
//
//  Created by wang shun on 2017/7/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareTouchView.h"

@interface SNNewsScreenShareTouchView ()

@property (nonatomic,strong) UIView* touchBgView;
@property (nonatomic,strong) UIView* touchView;

@end

@implementation SNNewsScreenShareTouchView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
       // [self createTouchView];
    }
    return self;
}

//- (void)createTouchView{
//    self.touchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    self.touchBgView.userInteractionEnabled = NO;
//    self.touchBgView.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.touchBgView];
//    
//    self.touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    self.touchView.userInteractionEnabled = YES;
//    self.touchView.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.touchView];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
