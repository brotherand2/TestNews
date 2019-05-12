//
//  DACircularProgressView.m
//  DACircularProgress
//
//  Created by Daniel Amitay on 2/6/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DACircularProgressView.h"

#define float_epsilon 0.00001
#define float_equal(a,b) (fabs((a) - (b)) < float_epsilon)
#define float_larger(a,b) (a - b > float_epsilon)
#define float_smaller(a,b) (a - b < float_epsilon)

@interface DACircularProgressView()
{
    CGFloat _progress;
    CGFloat _updateStep;
    CGFloat _objectPercent;
    TDirection _clockwise;
    NSTimer* _updateTimer;
}

@property(nonatomic, assign)CGFloat progress;
@property(nonatomic, retain)NSTimer* updateTimer;
@property(nonatomic, assign)CGFloat objectPercent;
@property(nonatomic, assign)TDirection clockwise;
@property(nonatomic, assign)CGFloat updateStep;

-(BOOL)doNotifyUpdateIfNeed:(NSInteger)aUpdateTo;
@end

@implementation DACircularProgressView
@synthesize progress = _progress;
@synthesize dySpeed = _dySpeed;
@synthesize increaseOnly = _increaseOnly;
@synthesize lastNotifyUpdate = _lastNotifyUpdate;
@synthesize updateTimer = _updateTimer;
@synthesize objectPercent = _objectPercent;
@synthesize clockwise = _clockwise;
@synthesize delegate = _delegate;
@synthesize trackTintColor = _trackTintColor;
@synthesize progressTintColor = _progressTintColor;
@synthesize trackRate = _trackRate;
@synthesize trackRadius = _trackRadius;
@synthesize innerRadius = _innerRadius;
@synthesize updateStep = _updateStep;

-(void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgressNow) object:nil];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    self.delegate = nil;
    
    self.trackTintColor = nil;
    self.progressTintColor = nil;
    [super dealloc];
}

-(id)init
{
    self = [super initWithFrame:DEFAULT_RECT];
    if(self)
    {
        self.lastNotifyUpdate = 0;
        self.trackRate = DEFAULT_TRACK_RATE;
        self.trackRadius = DEFAULT_RADIUS;
        self.innerRadius = DEFAULT_RADIUS;
        self.updateStep = UPDATE_STEP;
        self.backgroundColor = [UIColor clearColor];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(updateProgressNow) userInfo:nil repeats:YES];
        self.clockwise = EUnset;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.lastNotifyUpdate = 0;
        self.trackRate = DEFAULT_TRACK_RATE;
        self.trackRadius = DEFAULT_RADIUS;
        self.innerRadius = DEFAULT_RADIUS;
        self.updateStep = UPDATE_STEP;
        self.backgroundColor = [UIColor clearColor];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(updateProgressNow) userInfo:nil repeats:YES];
        self.clockwise = EUnset;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(UIColor*)trackTintColor
{
    if(!_trackTintColor)
        self.trackTintColor = [UIColor blueColor];
    return _trackTintColor;
}

-(UIColor*)progressTintColor
{
    if(!_progressTintColor)
        self.progressTintColor = [UIColor redColor];
    return _progressTintColor;
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

-(BOOL)validateRadius
{
    return self.trackRadius>0 && self.innerRadius>0 && self.trackRadius>=self.innerRadius;
}

-(CGFloat)getValidateTrackRate
{
    CGFloat rate = DEFAULT_TRACK_RATE;
    if(self.trackRate>0.0f && self.trackRate<1.0f)
        rate = self.trackRate;
    return rate;
}

//圆环宽度
-(CGFloat)pathWidth
{
    if([self validateRadius])
        return self.trackRadius-self.innerRadius;
    else
    {
        CGRect rect = self.frame;
        CGFloat rate = [self getValidateTrackRate];
        CGFloat radius = MIN(rect.size.height, rect.size.width)/2;
        return radius * rate;
    }
}

//内圆半径
-(CGFloat)insideWidth
{
    if([self validateRadius])
        return self.innerRadius;
    else
    {
        CGRect rect = self.frame;
        CGFloat rate = [self getValidateTrackRate];
        CGFloat radius = MIN(rect.size.height, rect.size.width)/2;
        return radius*(1-rate);
    }
}

//圆环中心到圆形宽度
-(CGFloat)pathCenterWidth
{
    if([self validateRadius])
        return (self.trackRadius+self.innerRadius)/2;
    else
    {
        CGRect rect = self.frame;
        CGFloat rate = [self getValidateTrackRate];
        CGFloat radius = MIN(rect.size.height, rect.size.width)/2;
        return radius*(1-rate/2);
    }
}

-(void)drawRect:(CGRect)rect
{
    //目前暂时忽略trackRadius参数
    self.trackRadius = rect.size.width/2;
    
    //处理数据到合理范围
    if(self.progress<0.0f) self.progress = 0.0f;
    if(self.progress>1.0f) self.progress = 1.0f;
    
    CGPoint centerPoint = CGPointMake(rect.size.height/2, rect.size.width/2);
    CGFloat radius = MIN(rect.size.height, rect.size.width)/2;
    
    CGFloat pathWidth = [self pathWidth];
    
    CGFloat radians = DEGREES_2_RADIANS((self.progress*359.99)-90);
    CGFloat xOffset = radius + [self pathCenterWidth]*cosf(radians);
    CGFloat yOffset = radius + [self pathCenterWidth]*sinf(radians);
    CGPoint endPoint = CGPointMake(xOffset, yOffset);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.trackTintColor setFill];
    
    //绘制背景大圈
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, DEGREES_2_RADIANS(270), DEGREES_2_RADIANS(-90), NO);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    //开始绘制核心区颜色
    [self.progressTintColor setFill];
    
    //以扇形方式绘制整个大圆形
    if(self.progress>0.0f)
    {
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, DEGREES_2_RADIANS(270), radians, NO);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }
    
    if(self.progress>0.0f && self.progress<=1.0f)
    {
        //绘制起始圆
        CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth/2, 0, pathWidth, pathWidth));
        CGContextFillPath(context);
        
        //绘制冲锋圆
        CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth/2, endPoint.y - pathWidth/2, pathWidth, pathWidth));
        CGContextFillPath(context);
    }
    
    //绘制内圈(擦除中间区域)
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = [self insideWidth];
	CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
	CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius*2, innerRadius*2));
	CGContextFillPath(context);
}

-(void)updateProgressNow
{
    if(float_equal(self.objectPercent, self.progress) || float_equal(self.objectPercent, 0.0f)
       || (float_smaller(self.objectPercent, self.progress+self.updateStep/100) && self.clockwise==EClockwise)
       || (float_larger(self.objectPercent, self.progress-self.updateStep/100) && self.clockwise==ECounter_clockwise)
       || (self.clockwise==EUnset))
    {
        NSInteger nextPercent = self.objectPercent*100;
        [self doNotifyUpdateIfNeed:nextPercent];
        
        self.clockwise = EUnset;
        [self.updateTimer setFireDate:[NSDate distantFuture]];
        [self setNeedsDisplay];
    }
    else if(self.clockwise==EClockwise)
    {
        NSInteger current = self.progress*100;
        NSInteger nextPercent = self.progress*100 + self.updateStep;
        if(nextPercent>current)
            [self doNotifyUpdateIfNeed:nextPercent];
        
        self.progress += self.updateStep/100;
        [self setNeedsDisplay];
    }
    else if(self.clockwise==ECounter_clockwise)
    {
        NSInteger current = self.progress*100;
        NSInteger nextPercent = self.progress*100 - self.updateStep;
        if(nextPercent<current)
            [self doNotifyUpdateIfNeed:nextPercent];
        
        self.progress -= self.updateStep/100;
        [self setNeedsDisplay];
    }
}

-(void)resetNow
{
    self.clockwise = EUnset;
    self.progress = 0.0f;
    self.objectPercent = 0.0f;
    self.lastNotifyUpdate = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgressNow) object:nil];
    [self.updateTimer setFireDate:[NSDate distantFuture]];
    [self setNeedsDisplay];
}

-(void)invalidateTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgressNow) object:nil];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

-(void)updateProgress:(CGFloat)progress anmiated:(BOOL)aAnimated
{
#ifdef DACIRCULARPROGRESS_DEBUG
    if(progress<0.0f && _delegate!=nil)
    {
        SNDebugLog(@"^^^^^^ updateProgress %f ^^^^^^", progress);
    }
    else if(progress==0.0f && _delegate!=nil)
    {
         SNDebugLog(@"^^^^^^ updateProgress %f ^^^^^^", progress);
    }
    else if(progress>0.0f && progress<1.0f && _delegate!=nil)
    {
         SNDebugLog(@"^^^^^^ updateProgress %f ^^^^^^", progress);
    }
    else if(progress==1.0f && _delegate!=nil)
    {
         SNDebugLog(@"^^^^^^ updateProgress %f ^^^^^^", progress);
    }
    else if(progress>1.0f && _delegate!=nil)
    {
         SNDebugLog(@"^^^^^^ updateProgress %f ^^^^^^", progress);
    }
    
    if(progress<self.objectPercent && _delegate!=nil)
    {
         SNDebugLog(@"!!!!!! 倒挂了!!!!!! updateProgress %f ^^^^^^", progress);
    }
#endif
    
    //四舍五入，保留小数点后三位小数
    //有点怀疑有时进度抖动与此问题有关
    progress=((CGFloat)((NSInteger)((progress+0.0000)*1000)))/1000;

    if(progress<0.0f || progress>1.0f || float_equal(progress, self.objectPercent))
        return;
    if(self.increaseOnly && progress<self.objectPercent)
        return;
    
    if(aAnimated)
    {
        //如果需要动态计算速度的话
        if(aAnimated && self.dySpeed)
        {
            CGFloat distance = fabs(progress - self.progress);
            CGFloat speed = distance / UPDATE_TIME_EACH;
            if(speed>UPDATE_STEP) //太慢了，忽略
                self.updateStep = speed;
        }
        
        if(float_larger(progress, self.objectPercent))
            self.clockwise = EClockwise;
        else
            self.clockwise = ECounter_clockwise;
        
        self.objectPercent = progress;
        [self.updateTimer setFireDate:[NSDate date]];
        [self setNeedsDisplay];
    }
    else
    {
        self.clockwise = EUnset;
        self.progress = progress;
        self.objectPercent = progress;
        [self.updateTimer setFireDate:[NSDate date]];
        [self setNeedsDisplay];
    }
    
    //更新现在的状态
    [self doNotifyUpdateIfNeed:self.progress*100];
}

-(BOOL)doNotifyUpdateIfNeed:(NSInteger)aUpdateTo;
{
    if(self.increaseOnly && aUpdateTo<self.lastNotifyUpdate)
        return NO;
    
    self.lastNotifyUpdate = aUpdateTo;
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(notifyAnimationUpdateTo:)])
        [_delegate notifyAnimationUpdateTo:aUpdateTo];
    return YES;
}
@end
