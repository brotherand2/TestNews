//
//  SNProgressBar.m
//  sohunews
//
//  Created by weibin cheng on 14-10-9.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNProgressBar.h"

@implementation SNProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        _progressView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
        [self addSubview:_progressView];
    }
    return self;
}

- (void)dealloc
{
     //(_progressView);
    if(_timer)
    {
        [_timer invalidate];
         //(_timer);
    }
}

- (void)startProgress
{
    if(_timer)
    {
        [_timer invalidate];
         //(_timer);
    }
    _curProgress = 0.0;
    _progressView.alpha = 1.0;
    _progressView.width = self.width * _curProgress;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)resetProgress
{
    if(_timer)
    {
        [_timer invalidate];
         //(_timer);
    }
    _curProgress = 0.0;
    _progressView.alpha = 1.0;
    _progressView.width = self.width * _curProgress;
}

- (void)updateProgress
{
    if(_curProgress < 0.89)
    {
        _curProgress += 0.15;
        _progressView.width = self.width * _curProgress;
    }
}

- (void)setCurProgress:(CGFloat)curProgress
{
    if(curProgress > _curProgress)
    {
        if(_timer)
        {
            [_timer invalidate];
             //(_timer);
        }
        _curProgress = curProgress;
        _progressView.width = self.width * _curProgress;
    }
    if(_curProgress == 1.0)
    {
        [self hideProgressWithAnimation];
        if(_timer)
        {
            [_timer invalidate];
             //(_timer);
        }
    }
}

- (void)hideProgressWithAnimation
{
    [UIView animateWithDuration:0.8 animations:^{
        _progressView.alpha = 0.0;
    }];
}

- (void)updateTheme
{
    _progressView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
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
