//
//  CAKeyframeAnimation+AHEasing.m
//
//  Copyright (c) 2011, Auerhaus Development, LLC
//
//  This program is free software. It comes without any warranty, to
//  the extent permitted by applicable law. You can redistribute it
//  and/or modify it under the terms of the Do What The Fuck You Want
//  To Public License, Version 2, as published by Sam Hocevar. See
//  http://sam.zoy.org/wtfpl/COPYING for more details.
//

#import "CAKeyframeAnimation+AHEasing.h"

#if !defined(AHEasingDefaultKeyframeCount)

// The larger this number, the smoother the animation
#define AHEasingDefaultKeyframeCount 60

#endif

@implementation CAKeyframeAnimation (AHEasing)

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue keyframeCount:(size_t)keyframeCount
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
	
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (keyframeCount - 1);
	for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt)
	{
		CGFloat value = fromValue + function(t) * (toValue - fromValue);
		[values addObject:[NSNumber numberWithFloat:value]];
	}
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
	[animation setValues:values];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    return [self animationWithKeyPath:path function:function fromValue:fromValue toValue:toValue keyframeCount:AHEasingDefaultKeyframeCount];
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint keyframeCount:(size_t)keyframeCount
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
	
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (keyframeCount - 1);
	for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt)
	{
		CGFloat x = fromPoint.x + function(t) * (toPoint.x - fromPoint.x);
		CGFloat y = fromPoint.y + function(t) * (toPoint.y - fromPoint.y);
		[values addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
	}
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
	[animation setValues:values];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    return [self animationWithKeyPath:path function:function fromPoint:fromPoint toPoint:toPoint keyframeCount:AHEasingDefaultKeyframeCount];
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint stackTopPoint:(CGPoint)stackTopPoint keyframeCount:(size_t)keyframeCount
{    
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
    
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (keyframeCount - 1);
	for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt)
	{
		CGFloat x = fromPoint.x + function(t) * (toPoint.x - fromPoint.x);
		CGFloat y = fromPoint.y + function(t) * (toPoint.y - fromPoint.y);
        
        if (x > stackTopPoint.x) {
            x = stackTopPoint.x;
        }
        
        if (y > stackTopPoint.y) {
            y = stackTopPoint.y;
        }
//        if (stackTopPoint.y == 547) {
//            SNDebugLog(@"x, y = %g, %g", x, y);
//        }
		[values addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
	}
	
    
    
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
	[animation setValues:values];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint stackTopPoint:(CGPoint)stackTopPoint
{
    return [self animationWithKeyPath:path function:function fromPoint:fromPoint toPoint:toPoint stackTopPoint:stackTopPoint keyframeCount:AHEasingDefaultKeyframeCount];
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromSize:(CGSize)fromSize toSize:(CGSize)toSize keyframeCount:(size_t)keyframeCount
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
	
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (keyframeCount - 1);
	for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt)
	{
		CGFloat w = fromSize.width + function(t) * (toSize.width - fromSize.width);
		CGFloat h = fromSize.height + function(t) * (toSize.height - fromSize.height);
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, w, h)]];
	}
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
	[animation setValues:values];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromSize:(CGSize)fromSize toSize:(CGSize)toSize
{
    return [self animationWithKeyPath:path function:function fromSize:fromSize toSize:toSize keyframeCount:AHEasingDefaultKeyframeCount];
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromSize:(CGSize)fromSize overlapPoints:(NSArray *)overlapPoints pathPoints:(NSArray *)pathPoints beginCenter:(CGFloat)beginCenter keyframeCount:(size_t)keyframeCount
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
    
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (keyframeCount - 1);
	for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt)
	{
        NSValue *overlapValue = [NSValue valueWithCGPoint:CGPointMake(0, beginCenter)];
        
        if (overlapPoints.count > 0) {
            overlapValue = [overlapPoints objectAtIndex:frame];
        }
        
        NSValue *pathValue = [pathPoints objectAtIndex:frame];
        CGFloat deltaHeight = [overlapValue CGPointValue].y - [pathValue CGPointValue].y;

        CGFloat w = fromSize.width;
        CGFloat h = deltaHeight;
       
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, w, h)]];
	}
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
	[animation setValues:values];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromSize:(CGSize)fromSize overlapPoints:(NSArray *)overlapPoints pathPoints:(NSArray *)pathPoints beginCenter:(CGFloat)beginCenter
{
    return [self animationWithKeyPath:path function:function fromSize:fromSize overlapPoints:overlapPoints pathPoints:pathPoints beginCenter:beginCenter keyframeCount:AHEasingDefaultKeyframeCount];
}

#pragma mark - Angle

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle keyframeCount:(size_t)keyframeCount
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:keyframeCount];
	
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (keyframeCount - 1);
	for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt)
	{
		CGFloat _frameAngle = fromAngle + function(t) * (toAngle - fromAngle);
		[values addObject:[NSNumber numberWithFloat:_frameAngle]];
	}
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
	[animation setValues:values];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)path function:(AHEasingFunction)function fromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle
{
    return [self animationWithKeyPath:path function:function fromAngle:fromAngle toAngle:toAngle keyframeCount:AHEasingDefaultKeyframeCount];
}

@end
