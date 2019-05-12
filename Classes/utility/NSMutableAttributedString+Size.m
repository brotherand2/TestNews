//
//  NSMutableAttributedString+Size.m
//  sohunewsipad
//
//  Created by sampan li on 12-10-24.
//  Copyright (c) 2012年 sohu. All rights reserved.
//

#import "NSMutableAttributedString+Size.h"

@implementation NSAttributedString (Size)
- (int)getHeightWithWidth:(int) width maxHeight:(float)height
{
    int total_height = 0;
    
    // self有可能是乱码。 加一个异常，以免崩溃
    @try
    {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
        CGRect drawingRect = CGRectMake(0, 0, width, height);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, drawingRect);
        CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
        CGPathRelease(path);
        
        NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
        CGPoint origins[[linesArray count]];
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        int line_y = (int) origins[[linesArray count] -1].y;
        
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        
        if ([linesArray count]==0) {
            CFRelease(textFrame);
            CFRelease(framesetter);
            return 0;
        }
        
        CTLineRef line = (CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        total_height = height - line_y + (int) descent +1;
        
        CFRelease(textFrame);
        CFRelease(framesetter);
        
        return total_height;

    }
    @catch (NSException *exception) {
        return 0;
    }
}

-(NSInteger)getMaxLineCountWithWidth:(int) width
{
    NSInteger lineCount;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    CGRect drawingRect = CGRectMake(0, 0, width, 999);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    lineCount = linesArray.count;
    
    CFRelease(textFrame);
    CFRelease(framesetter);
    
    return lineCount;
}

-(int)getHeightWithWidth:(int)width maxLineCount:(NSInteger)num font:(UIFont *) textFont
{
    if (num<=0) {
        return 0;
    }
    int total_height = 0;
    
    // v5.2.0 self在这里会先释放 ? 先retain试一下
    [self retain];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    CGRect drawingRect = CGRectMake(0, 0, width, 999);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);

    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    if([linesArray count]>0){
        CGPoint origins[[linesArray count]];
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        NSInteger index = ([linesArray count] > num) ? num-1 : [linesArray count]-1;
        int line_y = (int) origins[index].y;
        
        /*   //字体不一样时， descent的值也不同
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CTLineRef line = (CTLineRef) ((index < linesArray.count) ? [linesArray objectAtIndex:index] : [linesArray lastObject]);
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        */
        
        CGFloat descender = fabs(textFont.descender);
        float lineSpace = textFont.lineHeight - textFont.pointSize;
        total_height = 999 - line_y + descender + lineSpace;

    }
    CFRelease(textFrame);
    CFRelease(framesetter);

    [self release];
    
    return total_height;
}

- (NSInteger)getReplaceEndStringWithWidth:(CGRect) textRect fontSize:(int) fontSize
{
    return [self getReplaceEndStringWithWidth:textRect fontSize:fontSize lineCnt:2];
}

- (NSInteger)getSingleReplaceEndStringWithWidth:(CGRect) textRect fontSize:(int) fontSize{
    return [self getReplaceEndStringWithWidth:textRect fontSize:fontSize lineCnt:1];
}

- (NSInteger)getReplaceEndStringWithWidth:(CGRect) textRect fontSize:(int) fontSize lineCnt:(NSInteger)lineCnt
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    CGRect drawingRect = CGRectMake(0, 0, textRect.size.width, 999);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFArrayRef linesArray = CTFrameGetLines(textFrame);
    
    NSInteger endIndex = 0;
    if (linesArray && CFArrayGetCount(linesArray) >lineCnt) {
        CTLineRef line = CFArrayGetValueAtIndex(linesArray, lineCnt - 1);
        endIndex = CTLineGetStringIndexForPosition(line, CGPointMake(textRect.size.width - fontSize*1.5, textRect.size.height - fontSize*0.5));
    }
    CFRelease(textFrame);
    CFRelease(framesetter);
    
    return endIndex;
}

@end
