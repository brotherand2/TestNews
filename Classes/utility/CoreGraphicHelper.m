//
//  CoreGraphicHelper.m
//  sohunews
//
//  Created by sampan li on 13-1-17.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "CoreGraphicHelper.h"
@implementation CoreGraphicHelper
+ (CGPathRef)roundedPath:(CGRect)rect cornerRadius:(float)radius
{
	
    UIRectCorner corners = UIRectCornerAllCorners;;
    
    UIBezierPath *thePath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(radius, radius)];
    return thePath.CGPath;
}

+ (void)drawRoundedMask:(CGRect)rect color:(UIColor*)color
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGPathRef path;
    path = [self roundedPath:rect cornerRadius:2.0];
    
    CGContextAddPath(ctx, path);
    
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    
    CGContextRestoreGState(ctx);
}

@end
