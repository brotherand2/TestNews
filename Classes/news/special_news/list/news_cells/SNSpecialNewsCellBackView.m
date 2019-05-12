//
//  SNSpecialNewsCellBackView.m
//  sohunews
//
//  Created by jialei on 14-9-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSpecialNewsCellBackView.h"
#import "UIColor+ColorUtils.h"
#import "NSCellLayout.h"
#import "NSAttributedString+Attributes.h"
#import "NSMutableAttributedString+Size.h"

#define iconTopPadding                              (20/2)
#define horizontalPadding                           (20/2)

@implementation SNSpecialNewsCellBackView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawTitleAndAbstract];
}

- (void)drawTitleAndAbstract {
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    BOOL hasImage = snItem.imageURL.length >0 ? YES : NO;
    BOOL isMultiTitle = NO;
    
    UIFont *titleFont = [UIFont systemFontOfSize:kThemeFontSizeD];
    UIFont *abstractFont = [UIFont systemFontOfSize:ROLLINGNEWS_ABSTRACT_FONT];
    NSString *title = snItem.text?snItem.text:@"";
    NSString *subtitle = snItem.subtitle ? snItem.subtitle : @"";
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableAttributedString *abstractString = [[NSMutableAttributedString alloc] initWithString:subtitle];
    [titleString setNewsTitelParagraphStyleWithFont:titleFont lineBreakMode:kCTLineBreakByWordWrapping];
    [abstractString setNewsTitelParagraphStyleWithFont:abstractFont lineBreakMode:kCTLineBreakByTruncatingTail];
    int titleWidth = [NSCellLayout titleTextWidthHasPic:hasImage ifHasTypeIcon:NO targetWidth:TTApplicationFrame().size.width];
    int titleHeight = [titleString getHeightWithWidth:titleWidth maxLineCount:2 font:titleFont];
    NSInteger maxLineCount = [titleString getMaxLineCountWithWidth:titleWidth];
    if (maxLineCount > 2) {
        NSInteger index = [titleString getReplaceEndStringWithWidth:CGRectMake(0, 0, titleWidth, 40) fontSize:kThemeFontSizeD];
        if (index > 0) {
            [titleString replaceCharactersInRange:NSMakeRange(index, titleString.string.length - index ) withString:@"..."];
        }
    }
    
    int imageWidth = hasImage ? CELL_IMAGE_WIDTH : 0;
    titleWidth = TTApplicationFrame().size.width - 2 * CONTENT_LEFT - imageWidth - 6;
    
    //字体颜色
    NSString *titleColorString = nil;
    NSString *abstractColorString = nil;
    if ([kSNSpecialNewsIsRead_YES isEqualToString:snItem.news.isRead]) {
        titleColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellTitleReadColor];
        abstractColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellDetailTextReadColor];
    } else {
        titleColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellTitleUnreadColor];
        abstractColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellDetailTextUnreadColor];
    }
    [titleString setTextColor:SNUICOLOR(titleColorString)];
    [abstractString setTextColor:SNUICOLOR(abstractColorString)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height);
    CGContextConcatCTM(context, flip);
    
    CGRect titleRect = CGRectMake(CONTENT_LEFT + CELL_IMAGE_WIDTH + 6,
                                  9, titleWidth, titleHeight);
    [UIView drawTextWithString:titleString
                      textRect:titleRect
                    viewHeight:self.height
                       context:context];
    
    CGContextRestoreGState(context);
}

@end
