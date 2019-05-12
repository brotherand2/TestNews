//
//  NSCellViewHelper.m
//  sohunews
//
//  Created by sampan li on 13-1-17.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "NSCellLayout.h"
#import "NSMutableAttributedString+Size.h"

@implementation NSCellLayout

+(float)titleTextWidthHasPic:(BOOL)ifHasPic ifHasTypeIcon:(BOOL)ifHasTypeIcon targetWidth:(float)width
{
    float textWidth=0;
    if(ifHasPic) {
        textWidth = width - 2*CONTENT_LEFT - CELL_IMAGE_WIDTH -CELL_IMAGE_TITLE_DISTANCE;
    }
    else {
        textWidth = width - 2*CONTENT_LEFT;
        if (ifHasTypeIcon) {
            //textWidth -= 56/2.0 + 3;
        }
    }
    return textWidth;
}

+(float)abstractTextWidthHasPic:(BOOL)ifHasPic targetWidth:(float)width
{
    float textWidth = 0;
    CGFloat xPos = CONTENT_LEFT;
    if (ifHasPic) {
        textWidth = width - 2*xPos - CELL_IMAGE_WIDTH -CELL_IMAGE_TITLE_DISTANCE;
    }
    else{
        textWidth =width-2*xPos;
    }
    
    return textWidth;
}

//高度
+(float)defaultNewsCellHeight
{
    return 220/2;
}

+(float)defaultGroupPhotoCellHeight
{
    return 280/2;
}

+(float)defaultExpressNewsHeight
{
    return 190/2;
}

///////////////////////////////
+(float)getAbstractHeight:(NSAttributedString*)attributeStr  textWidth:(float)width
{
    if (attributeStr==nil) {
        return 0;
    }
    UIFont *abstractFont = [UIFont systemFontOfSize:ROLLINGNEWS_ABSTRACT_FONT];
    float abstractHeight = [attributeStr getHeightWithWidth:width
                                               maxLineCount:2
                                                       font:abstractFont];
    return abstractHeight;
}

+(float)getTitleHeight:(NSString*)title font:(UIFont*)font textWidth:(float)width  isMultiLine:(BOOL)isMultiLine
{
    if (title.length==0) {
        return 0;
    }

    float height=0;
    if (isMultiLine) {
        float maxHeight = kThemeFontSizeD*2+5;
        CGSize titleSize = [title sizeWithFont:font
                             constrainedToSize:CGSizeMake(width, maxHeight)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
        height = titleSize.height;
    }
    else{
        CGSize titleSize = [title sizeWithFont:font
                             constrainedToSize:CGSizeMake(width, 0)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
        height = titleSize.height;
    }
    return height;
    
}
+(float)heightWithTitle: (NSString*)title titleWidth:(float)titleWidth abstract:(NSString*)atstract abstractWidth:(float)abstractWidth ifMultiTitle:(BOOL)ifMutiTitle
{
    UIFont *titleFont = [UIFont systemFontOfSize:kThemeFontSizeD];
    float yPos=0;
    if (title.length>0) {
        //TODO:这里别忘了要限制一行
        float titleHeight = [self getTitleHeight:title font:titleFont textWidth:titleWidth isMultiLine:ifMutiTitle];
        yPos+=CONTENT_TOP;
        yPos += titleHeight;
    }
    
    float abstractHeight=0;
    if (atstract.length>0) {
        NSAttributedString *attributeStr = [self getAttributedString:atstract];
        float textWidth =abstractWidth;
        abstractHeight = [self getAbstractHeight:attributeStr textWidth: textWidth];
        yPos+=ABSTRACT_TOP;
        yPos+=abstractHeight;
    }
    
    yPos+=COMMENT_TOP;
    yPos+=ICON_HEIGHT;
    yPos+=COMMENT_BOTTOM;
    return yPos;
    
}

+(NSMutableAttributedString*)getAttributedString:(NSString*)abstractText
{
    if (abstractText==nil)
        return nil;
    
    //字体
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:abstractText];
    NSInteger textLength = abstractText.length;
    UIFont *textFont =[UIFont systemFontOfSize:ROLLINGNEWS_ABSTRACT_FONT];
    CTFontRef font = [textFont createCTFont];
    [attributeString addAttribute:(NSString *)kCTFontAttributeName
                            value:(id)font
                            range:NSMakeRange(0, textLength)];
    if (font) {
        CFRelease(font);
    }
    
    //设置样式
    CTLineBreakMode _lineBreakMode = kCTLineBreakByWordWrapping;
    CTTextAlignment _textAlignment = NSTextAlignmentLeft;
    CGFloat paragraphBefore = 0;
    CGFloat paragraphAfter = 0;
    CGFloat _lineSpacing = ABSTRACT_LINESPACE;
    CGFloat lineHeight = ROLLINGNEWS_ABSTRACT_FONT;
    CFIndex theNumberOfSettings = 9;
    CTParagraphStyleSetting theSettings[9] =
    {
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
        { kCTParagraphStyleSpecifierParagraphSpacingBefore,sizeof(CGFloat),&paragraphBefore},
        { kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paragraphAfter},
        { kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(CGFloat),&lineHeight},
        { kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(CGFloat),&lineHeight},
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &_lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &_lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &_lineSpacing }
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
    [attributeString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                            value:(id)paragraphStyle
                            range:NSMakeRange(0, textLength)];
    
    CFRelease(paragraphStyle);
    
    return [attributeString autorelease];
}

@end
