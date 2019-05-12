//
//  UIView+Utility.m
//  sohunews
//
//  Created by lhp on 9/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "UIView+Utility.h"

@implementation UIView(Utility)

- (void) moveAnimationWithCenter:(CGPoint) center stopSelector:(SEL)selector animationDelegate:(id)delegate {
    
    [UIView beginAnimations:@"moveAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    if (selector) {
        [UIView setAnimationDidStopSelector:selector];
    }
    if (delegate) {
        [UIView setAnimationDelegate:delegate];
    }
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.center = center;
    [UIView commitAnimations];
    
}


+ (void)drawVoteSeperateDashLine:(CGRect)bounds margin:(float)margin {
    if (margin<0) {
        margin=0;
    }
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 1.0);
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
    CGContextSetStrokeColorWithColor(context, grayColor.CGColor);
    CGFloat lengths[] = {1, 1};
    CGContextSetLineDash(context, 0, lengths, 1);
    CGContextMoveToPoint(context, margin, bounds.size.height-0.5);
    CGContextAddLineToPoint(context, bounds.size.width-margin, bounds.size.height-0.5);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}

+ (void)drawVoteSeperateSolidLine:(CGRect)bounds margin:(float)margin {
    if (margin<0) {
        margin=0;
    }
    
    float lineW = [UIScreen mainScreen].scale==2.0f?0.5f:1.0f;
    //用2像素的白色描边遮挡1像素的灰色描边,达到画1像素灰线下面2像素白线的目的
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
	CGContextSetFillColorWithColor(context, grayColor.CGColor);
    float yPos = bounds.size.height-lineW*2;
    CGRect rect = CGRectMake(margin, yPos, bounds.size.width-margin*2, lineW);
    CGContextFillRect(context, rect);
    
    UIColor *whiteColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor2]];
    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    yPos = bounds.size.height-lineW;
    rect = CGRectMake(margin, yPos, bounds.size.width-margin*2, lineW);
    CGContextFillRect(context, rect);
}

+ (void)drawCellSeperateLine:(CGRect)bounds margin:(float)margin {
    if (margin<0) {
        margin=0;
    }
    
    float lineW = [UIScreen mainScreen].scale >= 2.0f?0.5f:1.0f;
    //用2像素的白色描边遮挡1像素的灰色描边,达到画1像素灰线下面2像素白线的目的
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color];
	CGContextSetFillColorWithColor(context, grayColor.CGColor);
    float yPos = bounds.size.height-lineW*2;
    CGRect rect = CGRectMake(bounds.origin.x + margin, yPos, bounds.size.width-margin*2, lineW);
    CGContextFillRect(context, rect);
    
//    UIColor *whiteColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color];
//    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
//    yPos = bounds.size.height-lineW;
//    rect = CGRectMake(bounds.origin.x + margin, yPos, bounds.size.width-margin*2, lineW);
//    CGContextFillRect(context, rect);
}

+ (void)drawCellSeperateLine:(CGRect)bounds context:(CGContextRef) context
{
    float lineW = [UIScreen mainScreen].scale==2.0f?0.5f:1.0f;
    //用2像素的白色描边遮挡1像素的灰色描边,达到画1像素灰线下面2像素白线的目的
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
	CGContextSetFillColorWithColor(context, grayColor.CGColor);
    float yPos = bounds.origin.y + bounds.size.height-lineW*2;
    CGRect rect = CGRectMake(bounds.origin.x, yPos, bounds.size.width, lineW);
    CGContextFillRect(context, rect);
    
    UIColor *whiteColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor2]];
    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    yPos = bounds.origin.y + bounds.size.height-lineW;
    rect = CGRectMake(bounds.origin.x, yPos, bounds.size.width, lineW);
    CGContextFillRect(context, rect);
}

+ (void)drawCellSeperateLine:(CGRect)bounds {
    [UIView drawCellSeperateLine:bounds margin:10];
}

+ (void)drawTextWithString:(NSMutableAttributedString *) textString textRect:(CGRect) textRect viewHeight:(float) viewHeight context:(CGContextRef) context
{
    CGRect drawRect = textRect;
    drawRect.origin.y = viewHeight - textRect.origin.y - textRect.size.height;
    [self drawTextWithString:textString textRect:drawRect context:context];
}

+ (void)drawTextWithString:(NSMutableAttributedString *) textString textRect:(CGRect) textRect  context:(CGContextRef) context
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, context);
    
    if (framesetter) {
        CFRelease(framesetter);
    }
    if (frame) {
        CFRelease(frame);
    }
    if (path) {
        CFRelease(path);
    }
}

@end
