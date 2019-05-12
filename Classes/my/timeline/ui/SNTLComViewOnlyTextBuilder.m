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
     //(_title);
     //(_abstract);
     //(_fromString);
     //(_typeString);
}

- (CGSize)suggestViewSize {
    CGFloat viewHeight = 0;
    CGFloat textWidth = _suggestViewWidth - 2 * kTLViewSideMargin;
    CGSize textSize = [self.title sizeWithFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
                             constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
    viewHeight = (textSize.height > 2 * kTLViewTitleFontSize) ? kTLViewViewMaxHeight : kTLViewViewMinHeight;
    
    return CGSizeMake(_suggestViewWidth, viewHeight);
}

- (void)renderInRect:(CGRect)rect withContext:(CGContextRef)context {
    [super renderInRect:rect withContext:context];
    
    CGFloat startX = CGRectGetMinX(rect);
    CGFloat startY = CGRectGetMinY(rect);
    
    CGFloat textHeight = (rect.size.height == kTLViewViewMaxHeight) ? kTLViewTitleFontSize * 2 + 5 : kTLViewTitleFontSize + 1;
    CGRect titleRect = CGRectMake(startX + kTLViewSideMargin,
                                  startY + kTLViewTitleTopMargin,
                                  rect.size.width - 2 * kTLViewSideMargin,
                                  textHeight);
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewTitleTextColor]] set];
    [self.title drawInRect:titleRect
                  withFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
             lineBreakMode:NSLineBreakByTruncatingTail];
    
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
        [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor]] set];

        //ios7 使用drawRect绘制限制宽高的文本
        CGRect textRect = CGRectMake(startX + kTLViewSideMargin,
                                     startY + rect.size.height - kTLViewFromBottomMargin - kTLViewFromFontSize,
                                     rect.size.width - 2 * kTLViewSideMargin,
                                     [UIFont systemFontOfSize:kTLViewFromFontSize].lineHeight);
        [fromTextToDraw textDrawInRect:textRect
                              withFont:[UIFont systemFontOfSize:kTLViewFromFontSize]
                     lineBreakMode:NSLineBreakByTruncatingTail
                         alignment:NSTextAlignmentLeft
                         textColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor]]];
    }
}

@end
