//
//  SNStatementView.m
//  sohunews
//
//  Created by guoyalun on 1/29/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNStatementView.h"

@implementation SNStatementView
@synthesize statment = _statment;

- (void)drawRect:(CGRect)rect
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.statment);
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    CGPathAddRect(leftColumnPath, NULL ,CGRectMake(0 , 0 ,self.bounds.size.width , self.bounds.size.height));
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, _statment.length), leftColumnPath , NULL);
    
    //翻转坐标系统（文本原来是倒的要翻转下）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    CGContextTranslateCTM(context , 0 ,self.bounds.size.height);
    CGContextScaleCTM(context, 1.0 ,-1.0);
    //画出文本
    CTFrameDraw(leftFrame,context);
    //释放
    CGPathRelease(leftColumnPath);
    CFRelease(leftFrame);
    CFRelease(framesetter);
    UIGraphicsPushContext(context);
}


- (void)setStatment:(NSMutableAttributedString *)statment
{
    if (_statment != statment) {
        _statment = statment;
        [self setNeedsDisplay];
    }
}

- (void)dealloc
{
     _statment = nil;
}

@end
