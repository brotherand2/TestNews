//
//  TextConfig.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "TextConfig.h"
#import <CoreText/CoreText.h>

static AttributeConfig *editorAttributeConfig = nil;
static AttributeConfig *readerAttributeConfig = nil;
static AttributeConfig *readerTitleAttributeConfig = nil;

@implementation TextConfig

+ (AttributeConfig *)editorAttributeConfig {
    @synchronized (self) {
        if (editorAttributeConfig == nil) {
            editorAttributeConfig = [[AttributeConfig alloc] init];
            editorAttributeConfig.attributes = [self defaultAttributes];
        }
    }
    return editorAttributeConfig;
}

+ (AttributeConfig *)readerAttributeConfig {
    @synchronized (self) {
        if (readerAttributeConfig == nil) {
            readerAttributeConfig = [[AttributeConfig alloc] init];
            readerAttributeConfig.attributes = [self defaultReaderAttributes];
        }
    }
    return readerAttributeConfig;
}

+ (AttributeConfig *)readerTitleAttributeConfig {
    @synchronized (self) {
        if (readerTitleAttributeConfig == nil) {
            readerTitleAttributeConfig = [[AttributeConfig alloc] init];
            readerTitleAttributeConfig.attributes = [self defaultReaderTitleAttributes];
        }
    }
    return readerTitleAttributeConfig;
}

+ (NSDictionary *)defaultAttributes {
    UIFont *font = [UIFont systemFontOfSize:16];
    NSString *fontName = [font fontName];
    CGFloat fontSize= 16.0f;
    UIColor *color = SNUICOLOR(kPhotoListDetailColor);
    UIColor *strokeColor = [UIColor whiteColor];
    CGFloat strokeWidth = 0.0;
    CGFloat paragraphSpacing = 0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat lineSpacing = 5.0;
    CGFloat minimumLineHeight = 21.0f;
    CGFloat leading = font.lineHeight - font.ascender + font.descender;
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName,
                                             fontSize, NULL);
    
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minimumLineHeight},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &leading},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, ARRSIZE(settings));
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)color.CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           (id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                           (id)[NSNumber numberWithFloat:strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                           (__bridge id) paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
                           nil];
    
    CFRelease(fontRef);
    CFRelease(paragraphStyle);
    return attrs;
}

//Modify by yangzongming
+ (NSDictionary *)defaultReaderAttributes {
    return [self defaultAttributes];
}

+ (NSDictionary *)defaultReaderTitleAttributes {
    return [self defaultAttributes];
}

@end
