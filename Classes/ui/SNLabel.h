//
//  SNLabel.h
//  sohunews
//
//  Created by guoyalun on 6/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "NSMutableAttributedString+Size.h"
#import "UIFontAdditions.h"

@protocol SNLabelDelegate;

@interface SNLabel : UIView
{
    NSString            *_text;
    UIColor             *_textColor;
    UIColor             *_linkColor;
    UIColor             *_highlightedColor;
    UIFont              *_font;
    CGFloat              _lineHeight;
    CGFloat              _textHeight;
    NSTextAlignment      _textAlignment;
    NSLineBreakMode      _breakMode;
    id<SNLabelDelegate>  __weak _delegate;
    NSMutableAttributedString  *_attributedString;
    //tapEnable值为NO,点击Label非link区域是不回调，如果为YES，点击Label非link区域会回调,默认值为YES
    BOOL                 tapEnable;
}

@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) UIColor  *textColor;
@property (nonatomic,strong) UIColor  *linkColor;
@property (nonatomic,strong) UIColor  *highlightedColor;
@property (nonatomic,strong) UIFont   *font;
@property (nonatomic,assign) CGFloat   lineHeight;
@property (nonatomic,assign) CGFloat   textHeight;
@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,assign) NSLineBreakMode  breakMode;
@property (nonatomic,weak) id<SNLabelDelegate>  delegate;
@property (nonatomic,assign) BOOL                 tapEnable;
@property (nonatomic,assign) BOOL disableLinkDetect; // 如果不想自动检测link 可以设置为YES 默认为NO

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text;

- (void)addCustomLink:(NSString*)linkUrl inRange:(NSRange)range;
- (void)removeAllCustomLinks;

- (void)addHighlightText:(NSString *)text inRange:(NSRange)range;
- (void)removeAllHighlightInfo;

//- (void)addEmoticons:(NSDictionary *)imageRangeDic;
//- (void)removeAllEmoticonInfo;

- (void)addFont:(UIFont *)font inRange:(NSRange)range;
- (void)removeAllFontInfo;

+ (CGSize)sizeForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size;
+ (CGSize)sizeForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight;

+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size;
+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size;
+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size lineHeight:(CGFloat)lineHeight;
+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size lineHeight:(CGFloat)lineHeight ignoreLinks:(BOOL)ignoreLinks;
+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size lineHeight:(CGFloat)lineHeight maxLineCount:(NSInteger)count;
+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)mode;
+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)mode ignoreLinks:(BOOL)ignoreLinks;
+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)mode maxLineCount:(NSInteger)count ignoreLinks:(BOOL)ignoreLinks;
+ (CGFloat)heightForAttributeString:(NSAttributedString *)attrString maxWidth:(CGFloat)width;

@end


@protocol SNLabelDelegate <NSObject>

@optional
- (void)tapOnNotLink:(SNLabel *)lb;
- (void)tapOnLink:(NSString *)link;
@end
