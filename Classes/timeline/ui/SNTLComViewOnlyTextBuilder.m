//
//  SNTLComViewOnlyTextBuilder.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewOnlyTextBuilder.h"
#import "UIColor+ColorUtils.h"

@implementation SNTLComViewOnlyTextBuilder
@synthesize title = _title;
@synthesize abstract = _abstract;
@synthesize fromString = _fromString;
@synthesize typeString = _typeString;

- (void)dealloc {
    TT_RELEASE_SAFELY(_title);
    TT_RELEASE_SAFELY(_abstract);
    TT_RELEASE_SAFELY(_fromString);
    TT_RELEASE_SAFELY(_typeString);
    [super dealloc];
}

- (CGSize)suggestViewSize {
    CGFloat viewHeight = 0;
    CGFloat textWidth = _suggestViewWidth - 2 * kTLViewSideMargin;
    CGSize textSize = [self.title sizeWithFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
                             constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                 lineBreakMode:UILineBreakModeTailTruncation];
    viewHeight = (textSize.height > 2 * kTLViewTitleFontSize) ? kTLViewViewMaxHeight : kTLViewViewMinHeight;
    
    return CGSizeMake(_suggestViewWidth, viewHeight);
}

- (void)renderInRect:(CGRect)rect withContext:(CGContextRef)context {
    [super renderInRect:rect withContext:context];
    
    CGFloat startX = CGRectGetMinX(rect);
    CGFloat startY = CGRectGetMinY(rect);
    
    NSString *titleTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewTitleTextColor];
    CGFloat textHeight = (rect.size.height == kTLViewViewMaxHeight) ? kTLViewTitleFontSize * 2 + 5 : kTLViewTitleFontSize + 1;
    CGRect titleRect = CGRectMake(startX + kTLViewSideMargin,
                                  startY + kTLViewTitleTopMargin,
                                  rect.size.width - 2 * kTLViewSideMargin,
                                  textHeight);
    [[UIColor colorFromString:titleTextColorStr] set];
    [self.title drawInRect:titleRect
                  withFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
             lineBreakMode:UILineBreakModeTailTruncation];
    
    NSString *fromTextToDraw = nil;
    if (self.useType == kSNTLComViewUseForShareOuter && self.abstract.length > 0) {
        fromTextToDraw = self.abstract;
    } else if (self.useType == kSNTLComViewUseForShareCircle) {
        if (self.fromString.length > 0) {
            fromTextToDraw = [self.fromString stringByAppendingFormat:@"  %@", self.typeString.length > 0 ? self.typeString : @""];
        }
        else {
            fromTextToDraw = self.typeString;
        }
    }
    
    if (fromTextToDraw.length > 0) {
        NSString *fromTextColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor];
        [[UIColor colorFromString:fromTextColorString] set];

        //ios7 使用drawRect绘制限制宽高的文本
        CGRect textRect = CGRectMake(startX + kTLViewSideMargin,
                                     startY + rect.size.height - kTLViewFromBottomMargin - kTLViewFromFontSize,
                                     rect.size.width - 2 * kTLViewSideMargin,
                                     [UIFont systemFontOfSize:kTLViewFromFontSize].lineHeight);
        [fromTextToDraw textDrawInRect:textRect
                              withFont:[UIFont systemFontOfSize:kTLViewFromFontSize]
                     lineBreakMode:UILineBreakModeTailTruncation
                         alignment:NSTextAlignmentLeft
                         textColor:[UIColor colorFromString:fromTextColorString]];
    }
}

@end
