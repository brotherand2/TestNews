//
//  WSMVUtility.m
//  WeSee
//
//  Created by handy wang on 9/12/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVUtility.h"

@implementation WSMVUtility

+(void)drawCellSeperateLine:(CGRect)bounds {
    [WSMVUtility drawCellSeperateLine:bounds margin:10];
}

+(void)drawCellSeperateLine:(CGRect)bounds margin:(float)margin {
    if (margin<0) {
        margin=0;
    }
    
    float lineW = [UIScreen mainScreen].scale==2.0f?0.5f:1.0f;
    //用2像素的白色描边遮挡1像素的灰色描边,达到画1像素灰线下面2像素白线的目的
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
	CGContextSetFillColorWithColor(context, grayColor.CGColor);
    float yPos = bounds.size.height-lineW*2;
    CGRect rect = CGRectMake(margin, yPos, bounds.size.width-margin*2, lineW);
    CGContextFillRect(context, rect);
    
    UIColor *whiteColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1];
    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    yPos = bounds.size.height-lineW;
    rect = CGRectMake(margin, yPos, bounds.size.width-margin*2, lineW);
    CGContextFillRect(context, rect);
}

@end