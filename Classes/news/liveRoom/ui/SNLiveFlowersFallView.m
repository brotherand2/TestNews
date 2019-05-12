//
//  SNLiveFlowersFallView.m
//  sohunews
//
//  Created by Chen Hong on 7/7/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNLiveFlowersFallView.h"

@implementation SNLiveFlowersFallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _spriteImg = [UIImage imageNamed:@"flake.png"];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)dealloc {
     //(_spriteImg);
    [self stopTimer];
}

- (void)strewFlowers {
    if (![_timer isValid]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:(0.05) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
        [self performSelector:@selector(stopTimer) withObject:nil afterDelay:2];
    }
}

- (void)stopTimer {
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

	UIImageView* flakeView = [[UIImageView alloc] initWithImage:_spriteImg];
    //flakeView.backgroundColor = [UIColor purpleColor];

	int startX = round(random() % (int)screenSize.width);
	int endX = round(random() % (int)screenSize.width);
	//double scale = 1;// / round((random() % 100) + 1) + 1.0;
	double speed = 1 / round((random() % 100) + 1) + 1.0;
	//flakeView.frame = CGRectMake(startX, -50.0, 25.0 * scale, 25.0 * scale);
    flakeView.frame = CGRectMake(startX, -50.0, _spriteImg.size.width, _spriteImg.size.height);
	//flakeView.alpha = 0.8 * scale;
	[self addSubview:flakeView];
    [self runSpinAnimationOnView:flakeView duration:10 * speed rotations:1*speed repeat:0];
	[UIView beginAnimations:nil context:(__bridge void * _Nullable)(flakeView)];
	[UIView setAnimationDuration:2 * speed];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
	flakeView.frame = CGRectMake(endX, screenSize.height + 50, _spriteImg.size.width, _spriteImg.size.height);
    flakeView.transform = CGAffineTransformRotate(flakeView.transform, M_PI * 2);
	[UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIImageView *flakeView = (__bridge UIImageView *)(context);
	[flakeView removeFromSuperview];
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;

    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
