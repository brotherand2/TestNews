//
//  SNLiveStatusColumnHeadView.m
//  sohunews
//
//  Created by wang yanchen on 13-4-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveStatisticColumnHeadView.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveRoomConsts.h"

#define kTitleFont                  (27 / 2)

@implementation SNLiveStatisticColumnHeadView
@synthesize colunmDataArray = _colunmDataArray;
@synthesize isTitleColumn = _isTitleColumn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticColumnColor]];
    }
    return self;
}

- (void)dealloc {
     //(_colunmDataArray);
}

- (void)setColunmDataArray:(NSArray *)colunmDataArray {
    if (_colunmDataArray != colunmDataArray) {
         //(_colunmDataArray);
        _colunmDataArray = colunmDataArray;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSInteger colunmNum = MAX(self.colunmDataArray.count, 1);
    CGFloat titleSpace = self.width / colunmNum;
    CGRect drawRect = CGRectMake(0, 0, titleSpace, self.height);
    UITextAlignment alignment = self.isTitleColumn ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    CGFloat textSideMargin = self.isTitleColumn ? 7 : 0;
    
    // draw text
    CGContextSaveGState(context);
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticTextColor]] set];
    for (NSString *colTitle in self.colunmDataArray) {
        CGRect realDrawRect = CGRectMake(textSideMargin + drawRect.origin.x,
                                         (drawRect.size.height - kTitleFont) / 2,
                                         drawRect.size.width - 2 * textSideMargin,
                                         kTitleFont + 1);
        [colTitle drawInRect:realDrawRect
                    withFont:[UIFont systemFontOfSize:kTitleFont]
               lineBreakMode:NSLineBreakByTruncatingTail
                   alignment:alignment];
        
        drawRect.origin.x += drawRect.size.width;
    }
    CGContextRestoreGState(context);
    
    // draw lines
    CGFloat lineWidth = [[UIScreen mainScreen] scale] == 2 ? 0.5 : 1.0;
    UIColor *lineColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticLineColor]];
    CGFloat lineStartX = 0;
    CGContextSaveGState(context);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, lineStartX, 0);
    CGPathAddLineToPoint(path, NULL, lineStartX, self.height);
    lineStartX += titleSpace;
    
    for (int i = 0; i < colunmNum; ++i) {
        CGPathMoveToPoint(path, NULL, lineStartX, 0);
        CGPathAddLineToPoint(path, NULL, lineStartX, self.height);
        lineStartX += titleSpace;
    }
    
    // bottom line
    CGPathMoveToPoint(path, NULL, 0, self.height - lineWidth);
    CGPathAddLineToPoint(path, NULL, self.width, self.height - lineWidth);
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    CFRelease(path);
}

@end
