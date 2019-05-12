//
//  SNCheckAnimationMoveLayer.m
//  WebViewZoomDemo
//
//  Created by Scarlett on 16/8/23.
//  Copyright © 2016年 Scalett. All rights reserved.
//

#import "SNCheckAnimationMoveLayer.h"

@implementation SNCheckAnimationMoveLayer
@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat kRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2 - kLineWidth / 2;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    // 0
    CGFloat originStart = M_PI * 3;
    CGFloat originEnd = M_PI * 3;
    CGFloat currentOrigin = originStart - (originStart - originEnd) * self.progress;
    
    // D
    CGFloat destStart = M_PI * 3;
    CGFloat destEnd = 0;
    CGFloat currentDest = destStart - (destStart - destEnd) * self.progress;
    
    [path addArcWithCenter:center radius:kRadius startAngle:currentOrigin endAngle:currentDest clockwise:NO];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, kLineWidth);
    UIColor *color = SNUICOLOR(kThemeCheckLineColor);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextStrokePath(ctx);
}
@end
