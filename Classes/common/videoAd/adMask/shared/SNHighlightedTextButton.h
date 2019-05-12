//
//  SNHighlightedTextButton.h
//  sohunews
//
//  Created by handy wang on 5/12/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNHighlightedTextButton : UIButton

/**
 *  设置Button完整文本并指名需要高亮的文本
 *
 *  @param text            需要显示的所有文本
 *  @param highlightedText 需要在所有文本中高亮的文本
 */
- (void)setText:(NSString *)text highlightedText:(NSString *)highlightedText;

/**
 *  Button完整文本的字体
 *
 *  @param font 字体
 */
- (void)setTextFont:(UIFont *)font;

/**
 *  设置Button完整文本的颜色
 *
 *  @param textColor 颜色
 */
- (void)setTextColor:(UIColor *)textColor;

/**
 *  设置Button完整文本的对齐方式
 *
 *  @param textAlignment 对齐方式
 */
- (void)setTextAlignment:(NSTextAlignment)textAlignment;

@end