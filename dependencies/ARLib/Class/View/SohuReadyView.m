//
//  SohuReadyView.m
//  SohuAR
//
//  Created by sun on 2016/12/12.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuReadyView.h"

@interface SohuReadyView () <CAAnimationDelegate>

@property(nonatomic,strong) UIImageView *backgroundImageView;

@end

@implementation SohuReadyView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroundImageView];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOfBackgroundView)];
        [self.backgroundImageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupReadyViewWithAnimation {
    [self addSubview:self.readyView];
    [self addSubview:self.goView];
    [self.readyView.layer addAnimation:[self createGroupAnimation] forKey:@"group"];
}
-(void)tapOfBackgroundView{

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [self.readyView.layer animationForKey:@"group"]) {
        [self.readyView.layer removeAllAnimations];
        [self.readyView removeFromSuperview];
        [self.goView.layer addAnimation:[self createGroupAnimation] forKey:@"group"];
    } else if (anim == [self.goView.layer animationForKey:@"group"]) {
        [self.goView.layer removeAllAnimations];
        [self.goView removeFromSuperview];
    }
}

- (CAAnimationGroup *)createGroupAnimation {
    
    CABasicAnimation *moveY_01 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveY_01.toValue = @100;
    moveY_01.duration = 0.5;
    moveY_01.fillMode = kCAFillModeForwards;
    moveY_01.removedOnCompletion = NO;
    
    CABasicAnimation *moveY_02 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveY_02.toValue = @(-40);
    moveY_02.duration = 0.2;
    moveY_02.fillMode = kCAFillModeForwards;
    moveY_02.beginTime = 0.8;
    moveY_02.removedOnCompletion = NO;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:moveY_01, moveY_02, nil];
    group.duration = 1.0;
    group.removedOnCompletion = NO;
    group.delegate=self;
    
    return group;
}

#pragma mark - getter
- (UIImageView *)readyView {
    if (!_readyView) {
        _readyView = [[UIImageView alloc] init];
        _readyView.bounds = CGRectMake(0, 0, 120, 45);
        _readyView.center = CGPointMake(self.center.x, self.bounds.size.height + 50);
    }
    return _readyView;
}

- (UIImageView *)goView {
    if (!_goView) {
        _goView = [[UIImageView alloc] init];
        _goView.bounds = CGRectMake(0, 0, 70, 35);
        _goView.center = CGPointMake(self.center.x, self.bounds.size.height + 50);
    }
    return _goView;
}

-(UIImageView *)backgroundImageView{
    if (_backgroundImageView==nil) {
        _backgroundImageView=[[UIImageView alloc]initWithFrame:self.frame];
        _backgroundImageView.userInteractionEnabled=YES;
        _backgroundImageView.backgroundColor=[UIColor blackColor];
        _backgroundImageView.alpha=0.3;
    }
    return _backgroundImageView;
}
@end
