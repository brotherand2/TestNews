//
//  NSMutableAttributedString+Size.h
//  sohunewsipad
//
//  Created by sampan li on 12-10-24.
//  Copyright (c) 2012年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>


/**************************字体不一样时， descent的值也不同**************************************
 
 
 基础原点(Origin)：基线上最左侧的点。
 
 行间距(Leading)：行与行之间的间距。
 
 上行高度(Ascent)和下行高度(Decent)：一个字形最高点和最低点到基线的距离，前者为正数，而后者为负数。当同一行内有不同字体的文字时，就取最大值作为相应的值
 
 
            lineHeight = ascender + fabsf(descender) (descender 为负数)
 
      -----------------------------------------------------------------------------------------------
                                            ↑                                                   ↑
 
                                          Ascent
 
                                            ↓                                               lineHeight
        Origin  --------------------------------------------------------------------
                                            ↑
                                        descender
                                            ↓                                                   ↓
      -----------------------------------------------------------------------------------------------
        Leading
      ----------------------------------------------------------------------------------------------
 
 
 ********************************************************************************************/



@interface NSAttributedString (Size)

- (int)getHeightWithWidth:(int)width maxHeight:(float)height;
- (int)getHeightWithWidth:(int)width maxLineCount:(NSInteger)num font:(UIFont *) textFont;
- (NSInteger)getMaxLineCountWithWidth:(int) width;
- (NSInteger)getReplaceEndStringWithWidth:(CGRect) textRect fontSize:(int) fontSize;
- (NSInteger)getSingleReplaceEndStringWithWidth:(CGRect) textRect fontSize:(int) fontSize;
- (NSInteger)getReplaceEndStringWithWidth:(CGRect) textRect fontSize:(int) fontSize lineCnt:(NSInteger)lineCnt
;
@end
