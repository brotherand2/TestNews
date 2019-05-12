//
//  SNTrainCellHelper.h
//  sohunews
//
//  Created by Huang Zhen on 2017/10/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTrainCellHelper : NSObject

//卡片宽度
+ (CGFloat)trainCardWidth;

//获取文字高度
+ (CGFloat)getLabelHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont*)font;

//全屏焦点图新闻标题字体
+ (UIFont *)fullscreenFocusTitleFont;

//全屏焦点图编辑精选新闻标题字体
+ (UIFont *)fullscreenEditNewsTitleFont;

//横滑卡片标题
+ (UIFont *)trainCardNewsTitleFont;

//编辑精选新闻标题前面的圆点颜色
+ (UIColor *)bulletsColor;

//圆点透明度
+ (CGFloat)bulletsAlpha;

//编辑精选新闻区域与焦点图区域的分割线颜色
+ (UIColor *)segmentLineColor;

//分割线alpha
+ (CGFloat)segmentLineAlpha;

//焦点图新闻标题字色
+ (UIColor *)newsTitleColor;

//编辑精选新闻标题字色
+ (UIColor *)editNewsTitleColor;

//火车卡片新闻标题字色
+ (UIColor *)cardNewsTitleColor;

//编辑精选新闻区域背景色
+ (UIColor *)focusBackgroundColor;

//焦点图下方半透明遮罩颜色
+ (UIColor *)focusGradientBackgroundColor;

//焦点图下方半透明遮罩透明度
+ (CGFloat)focusGradientBackgroundAlpha;

//焦点图搜狐编辑部标签背景色
+ (UIColor *)sohuEditLabelBackgroundColor;

//焦点图搜狐编辑部标签字色
+ (UIColor *)sohuEditLabelTextColor;

//焦点图搜狐编辑部标签透明度
+ (CGFloat)sohuEditLabelAlpha;

//焦点图评论字色
+ (UIColor *)commentWordsColor;

//焦点图及火车卡片广告标签背景色
+ (UIColor *)adTextBackgroundColor;

//火车卡片cell上方搜狐编辑部标题字色
+ (UIColor *)trainCellEditorLabelTitleColor;

//白色模板下方分割线透明度
+ (CGFloat)whiteThemeBottomLineAlpha;

//火车卡片视频标签的偏移量，随字体大小变化
+ (CGFloat)videoImgOffsetInTitle;

//横滑卡片搜狐编辑部字体
+ (UIFont *)trainCardCellEditLabelFont;

//全屏焦点图下方两条新闻已经阅读的字色
+ (UIColor *)newsWordClickedColour;

@end
