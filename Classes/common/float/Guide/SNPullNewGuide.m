//
//  SNPullNewGuide.m
//  sohunews
//
//  Created by wangyy on 2017/4/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPullNewGuide.h"
#import "UIFont+Theme.h"

@interface SNPullNewGuide ()<CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *handImageView;

@end

@implementation SNPullNewGuide

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        UIImage *bgImage = [UIImage imageNamed:@"icofloat_bg_v5.png"];
        [bgView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeStretch]];
        bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:bgView];
        
        UIImage *leftImage = [UIImage imageNamed:@"icofloat_arrow_v5.png"];
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 19, leftImage.size.width, leftImage.size.height)];
        [leftImageView setImage:leftImage];
        [bgView addSubview:leftImageView];
        
        UIImage *handImage = [UIImage imageNamed:@"icofloat_hand_v5.png"];
        self.handImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftImageView.right -4, leftImageView.top, handImage.size.width, handImage.size.height)];
        [self.handImageView setImage:handImage];
        [bgView addSubview:self.handImageView];
        [self addHandAnimations];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.handImageView.right + 11, self.handImageView.top, frame.size.width - self.handImageView.right - 11, self.handImageView.size.height)];
        tipLabel.text = @"下拉刷新获取更多资讯";
        tipLabel.textColor = SNUICOLOR(kThemeCheckLineColor);
        tipLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeG];
        [bgView addSubview:tipLabel];
        
    }
    return self;
}

- (void)addHandAnimations{
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(25.0);
    animation1.duration = 1.3f;
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.beginTime = 0.0;
    animation2.duration = 1.3f;
    animation2.toValue = @(0);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.3;
    group.repeatCount = 3;
    group.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
    group.delegate = self;
    [self.handImageView.layer addAnimation:group forKey:@"groupAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0.0f;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
