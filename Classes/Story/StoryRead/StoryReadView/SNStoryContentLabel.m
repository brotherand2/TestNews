//
//  SNStoryContentLabel.m
//  StorySoHu
//
//  Created by chuanwenwang on 16/10/12.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryContentLabel.h"
#import <CoreText/CoreText.h>
#import "SNStoryPage.h"
#import "UIColor+StoryColor.h"

@implementation SNStoryContentLabel

-(void)drawTextInRect:(CGRect)rect
{
    
    NSString *contentStr = self.content;
    UIFont *font_ = [UIFont systemFontOfSize:18];
    
    if (self.cur_font) {
        font_ = self.cur_font;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [SNStoryPage getLineSpace];
    paragraphStyle.paragraphSpacing = [SNStoryPage getparagraphSpace];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    UIColor * color = [UIColor colorFromKey:@"kThemeText2Color"];
    
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_,NSForegroundColorAttributeName:color};
    
    NSMutableAttributedString *totalString = [[NSMutableAttributedString  alloc] initWithString:contentStr];
    
    [totalString setAttributes:dic range:NSMakeRange(0, totalString.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) totalString);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0 ,rect.size.width, rect.size.height), NULL);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    if (!ctFrame)
    {
        CFRelease(path);
        CFRelease(frameSetter);
        return;
    }else
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGAffineTransform transform = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
        CGContextConcatCTM(context, transform);
        CTFrameDraw(ctFrame, context);
        
        CFRelease(path);
        CFRelease(ctFrame);
        CFRelease(frameSetter);
        
        [super drawTextInRect:rect];
    }
    
}

- (void)updateNovelTheme {
    [self setNeedsDisplay];
}


@end
