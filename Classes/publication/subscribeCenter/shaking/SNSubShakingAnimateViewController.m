//
//  SNSubShakingAnimateViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubShakingAnimateViewController.h"
#import "SNSubShakingCenterViewController.h"

@interface SNSubShakingAnimateViewController()
-(void)timeout;
-(void)customerBg;
-(void)initAnimationInfoArray;
-(void)initGuideAnimationInfoArray;
-(void)shakingNow;
@end

@implementation SNSubShakingAnimateViewController
@synthesize _infoArray;
@synthesize _guideInfoArray;
@synthesize _subViewController;
@synthesize _animationReady;
@synthesize _animationOpen;
@synthesize _animationWillStop;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)dealloc
{
    UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
    CALayer* layer = [imageView layer];
    [layer removeAllAnimations];
    
}

-(id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self._animationOpen = NO;
        self._animationReady = NO;
        self._animationWillStop = NO;
        [self initAnimationInfoArray];
        [self initGuideAnimationInfoArray];
    }
    return self;
}

- (void)updateTheme:(NSNotification*)notifiction
{
    [super updateTheme:notifiction];
    [self customerBg];
    
    //摇晃图片
    UIImage* image = [UIImage imageNamed:@"shaking_big_image.png"];
    UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
    imageView.image = image;
}

-(void)loadView
{
    [super loadView];
    UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingLabelColor]];
    
    //摇晃图片
    CGRect subRect = CGRectMake(81, 47, 158, 158);
    UIImage* image = [UIImage imageNamed:@"shaking_big_image.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:subRect];
    imageView.tag = 101;
    imageView.image = image;
    [self.view addSubview:imageView];
    
    //文字提示
    subRect = CGRectMake(0, 202, 320, 32);
    UILabel* tipLabel = [[UILabel alloc] initWithFrame:subRect];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.tag = 102;
    tipLabel.textColor = labelColor;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.userInteractionEnabled = YES;
    tipLabel.text = NSLocalizedString(@"shaking_shake_tip", nil);
    [self.view addSubview:tipLabel];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
    CALayer* layer = [imageView layer];
    [layer removeAllAnimations];
    
    //确保打开锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	[self customerBg];
    //[self startAnimation];
    
    if(_subViewController!=nil && [_subViewController respondsToSelector:@selector(notifyShaking:)])
        [_subViewController notifyShaking:NO];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)startAnimation
{
    if(self._animationOpen || self._animationWillStop)
        return;
    
    _currentIndex = 0;
    self._animationOpen = YES;
    self._animationReady = NO;
    
    //设置初始状态
    UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
    CALayer* layer = [imageView layer];
    [layer removeAllAnimations];
    
    CGPoint oldAnchorPoint = imageView.layer.anchorPoint;
    layer.anchorPoint = CGPointMake(0.924,0.728);
    [layer setPosition:CGPointMake(layer.position.x + layer.bounds.size.width * (layer.anchorPoint.x - oldAnchorPoint.x), layer.position.y + layer.bounds.size.height * (layer.anchorPoint.y - oldAnchorPoint.y))];
    
    [self performSelector:@selector(timeout) withObject:nil afterDelay:1.5f];
    [self shakingNow];
    
    UILabel* label = (UILabel*)[self.view viewWithTag:102];
    label.text =  NSLocalizedString(@"shaking_shaking", nil);
    
    //关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)startGuideAnimation
{
    if(self._animationOpen || self._animationWillStop)
        return;
    
    _currentIndex = 0;
    self._animationOpen = YES;
    self._animationReady = NO;
    
    //设置初始状态
    UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
    CALayer* layer = [imageView layer];
    [layer removeAllAnimations];
    
    CGPoint oldAnchorPoint = imageView.layer.anchorPoint;
    layer.anchorPoint = CGPointMake(0.924,0.728);
    [layer setPosition:CGPointMake(layer.position.x + layer.bounds.size.width * (layer.anchorPoint.x - oldAnchorPoint.x), layer.position.y + layer.bounds.size.height * (layer.anchorPoint.y - oldAnchorPoint.y))];

    [self guideShakingNow];
    
    //关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)stopAnimation:(NSInteger)aResult
{
    self._animationReady = NO;
    self._animationWillStop = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    //[self performSelector:@selector(realStopNow) withObject:nil afterDelay:1.0f];
    
    UILabel* label = (UILabel*)[self.view viewWithTag:102];
    if(aResult==0)
        label.text =  NSLocalizedString(@"shaking_shake_tip", nil);
    else if(aResult==1)
        label.text =  NSLocalizedString(@"shaking_shake_fail", nil);
    else if(aResult==2)
        label.text =  NSLocalizedString(@"shaking_shake_too_much", nil);
    
    //打开锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)realStopNow
{
    self._animationOpen = NO;
    self._animationWillStop = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shakingNow) object:nil];
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)timeout
{
    self._animationReady = YES;
    [_subViewController showSubinfoIfReady];
}

-(void)customerBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

-(void)initAnimationInfoArray
{
    _currentIndex = 0;
    NSMutableDictionary* dic;
    self._infoArray = [NSMutableArray arrayWithCapacity:0];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:0] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.15f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseIn] forKey:@"curve"];
    [self._infoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:M_PI/8] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.15f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseOut] forKey:@"curve"];
    [self._infoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:0] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.15f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseIn] forKey:@"curve"];
    [self._infoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:-M_PI/8] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.15f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseOut] forKey:@"curve"];
    [self._infoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:0] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.15f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseIn] forKey:@"curve"];
    [self._infoArray addObject:dic];
}

-(void)initGuideAnimationInfoArray
{
    _currentIndex = 0;
    NSMutableDictionary* dic;
    self._guideInfoArray = [NSMutableArray arrayWithCapacity:0];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:0] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.1f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseIn] forKey:@"curve"];
    [self._guideInfoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:M_PI/16] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.1f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseOut] forKey:@"curve"];
    [self._guideInfoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:0] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.1f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseIn] forKey:@"curve"];
    [self._guideInfoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:-M_PI/16] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.1f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseOut] forKey:@"curve"];
    [self._guideInfoArray addObject:dic];
    
    dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithFloat:0] forKey:@"angle"];
    [dic setObject:[NSNumber numberWithFloat:0.1f] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:UIViewAnimationCurveEaseIn] forKey:@"curve"];
    [self._guideInfoArray addObject:dic];
}

-(void)shakingNow
{
    if(!_animationOpen)
    {
        [self realStopNow];
        return;
    }
    else if(_animationWillStop && _currentIndex>=[self._infoArray count]) //如果被停止了，那么把这次执行完
    {
        [self realStopNow];
        return;
    }
    else if(_currentIndex>=[self._infoArray count]) //否则继续执行
        _currentIndex = 0;
    
    NSDictionary* dic = [self._infoArray objectAtIndex:_currentIndex++];
    NSNumber* time = (NSNumber*)[dic objectForKey:@"time"];
    NSNumber* angle = (NSNumber*)[dic objectForKey:@"angle"];
    NSNumber* curve = (NSNumber*)[dic objectForKey:@"curve"];
    
    [UIView beginAnimations:@"present-countdown" context:nil];
    [UIView setAnimationDuration:[time floatValue]];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:(UIViewAnimationCurve)[curve intValue]];
    [UIView setAnimationDidStopSelector:@selector(shakingNow)];
    
    UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
    CALayer* layer = [imageView layer];
    [layer removeAllAnimations];
    
    CGPoint oldAnchorPoint = imageView.layer.anchorPoint;
    layer.anchorPoint = CGPointMake(0.924,0.728);
    [layer setPosition:CGPointMake(layer.position.x + layer.bounds.size.width * (layer.anchorPoint.x - oldAnchorPoint.x), layer.position.y + layer.bounds.size.height * (layer.anchorPoint.y - oldAnchorPoint.y))];
    
    layer.transform = CATransform3DMakeRotation([angle floatValue],0.0, 0.0, [time floatValue]);
    [UIView commitAnimations];
}

-(void)guideShakingNow
{
    if(!_animationOpen || _currentIndex>=[self._guideInfoArray count])
    {
        [self realStopNow];
        return;
    }
    else
    {
        NSDictionary* dic = [self._guideInfoArray objectAtIndex:_currentIndex++];
        NSNumber* time = (NSNumber*)[dic objectForKey:@"time"];
        NSNumber* angle = (NSNumber*)[dic objectForKey:@"angle"];
        NSNumber* curve = (NSNumber*)[dic objectForKey:@"curve"];
        
        [UIView beginAnimations:@"present-countdown" context:nil];
        [UIView setAnimationDuration:[time floatValue]];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:(UIViewAnimationCurve)[curve intValue]];
        [UIView setAnimationDidStopSelector:@selector(guideShakingNow)];
        
        UIImageView* imageView = (UIImageView*)[self.view viewWithTag:101];
        CALayer* layer = [imageView layer];
        [layer removeAllAnimations];
        
        CGPoint oldAnchorPoint = imageView.layer.anchorPoint;
        layer.anchorPoint = CGPointMake(0.924,0.728);
        [layer setPosition:CGPointMake(layer.position.x + layer.bounds.size.width * (layer.anchorPoint.x - oldAnchorPoint.x), layer.position.y + layer.bounds.size.height * (layer.anchorPoint.y - oldAnchorPoint.y))];
        
        layer.transform = CATransform3DMakeRotation([angle floatValue],0.0, 0.0, [time floatValue]);
        [UIView commitAnimations];
    }
}
@end
