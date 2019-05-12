//
//  SNLiveStatisticRowCell.m
//  sohunews
//
//  Created by wang yanchen on 13-4-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveStatisticRowCell.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveRoomConsts.h"

@implementation SNLiveStatisticRowCell
@synthesize rowDataArray = _rowDataArray;
@synthesize isTitleColumn = _isTitleColumn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
     //(_rowDataArray);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void)setRowDataArray:(NSArray *)rowDataArray {
    if (_rowDataArray != rowDataArray) {
         //(_rowDataArray);
        _rowDataArray = rowDataArray;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill bg color
//    CGContextSaveGState(context);
//    UIColor *bgColor = [UIColor colorFromString:kLiveStatisticRowColor];
//    CGContextSetFillColorWithColor(context, bgColor.CGColor);
//    CGContextFillRect(context, rect);
//    CGContextRestoreGState(context);
    
    NSInteger colunmNum = MAX(self.rowDataArray.count, 1);
    CGFloat titleSpace = self.width / colunmNum;
    CGRect drawRect = CGRectMake(0, 0, titleSpace, self.height);
    UITextAlignment alignment = self.isTitleColumn ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    CGFloat textSideMargin = self.isTitleColumn ? 7 : 0;
    CGFloat fontSize = self.isTitleColumn ? (25 / 2) : (22 / 2);
    UIFont *font = self.isTitleColumn ? [UIFont systemFontOfSize:(25 / 2)] : [UIFont digitAndLetterFontOfSize:(22 / 2)];
    
    // draw text
    CGContextSaveGState(context);
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticTextColor]] set];
    for (NSString *colTitle in self.rowDataArray) {
        CGRect realDrawRect = CGRectMake(textSideMargin + drawRect.origin.x,
                                         (drawRect.size.height - fontSize) / 2,
                                         drawRect.size.width - 2 * textSideMargin,
                                         fontSize + 1);
        [colTitle drawInRect:realDrawRect
                    withFont:font
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
