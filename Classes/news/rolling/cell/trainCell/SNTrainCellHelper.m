//
//  SNTrainCellHelper.m
//  sohunews
//
//  Created by Huang Zhen on 2017/10/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNTrainCellHelper.h"
#import "UIFont+Theme.h"
#import "SNAppConfigManager.h"

@implementation SNTrainCellHelper

+ (CGFloat)trainCardWidth {
    CGFloat appscreenWidth = kAppScreenWidth;
    if (appscreenWidth == 320) {
        return 404/2.f;
    }else if (appscreenWidth == 375){
        return 473/2.f;
    }else if (appscreenWidth == 414){
        return 783/3.f;
    }
    return 473/2.f;
}

+ (CGFloat)getLabelHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont*)font
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.height;
}

//焦点图标题
+ (UIFont *)fullscreenFocusTitleFont {
    UIFont *titleFont = nil;
//    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
//        switch (fontsize) {
//            case 2:
////                titleFont = [UIFont systemFontOfSize:64/3.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:64/3.f];
//                break;
//            case 3:
//                titleFont = [UIFont systemFontOfSize:64/3.f];
                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:64/3.f];
//                break;
//            case 4:
////                titleFont = [UIFont systemFontOfSize:70/3.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:70/3.f];
//                break;
//            case 5:
////                titleFont = [UIFont systemFontOfSize:78/3.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:78/3.f];
//                break;
//
//            default:
//                break;
//        }
        
    }
    else{
//        switch (fontsize) {
//            case 2:
////                titleFont = [UIFont systemFontOfSize:40/2.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:40/2.f];
//                break;
//            case 3:
//                titleFont = [UIFont systemFontOfSize:40/2.f];
                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:40/2.f];
//                break;
//            case 4:
////                titleFont = [UIFont systemFontOfSize:44/2.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:44/2.f];
//                break;
//            case 5:
////                titleFont = [UIFont systemFontOfSize:50/2.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:50/2.f];
//                break;
//
//            default:
//                break;
//        }
    }
    return titleFont;
}

//编辑推荐标题
+ (UIFont *)fullscreenEditNewsTitleFont {
    UIFont *titleFont = nil;
//    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
//        switch (fontsize) {
//            case 2:
//                titleFont = [UIFont systemFontOfSize:44/3.f];
//                break;
//            case 3:
                titleFont = [UIFont systemFontOfSize:48/3.f];
//                break;
//            case 4:
//                titleFont = [UIFont systemFontOfSize:54/3.f];
//                break;
//            case 5:
//                titleFont = [UIFont systemFontOfSize:62/3.f];
//                break;
//
//            default:
//                break;
//        }
        
    }
    else{
//        switch (fontsize) {
//            case 2:
//                titleFont = [UIFont systemFontOfSize:28/2.f];
//                break;
//            case 3:
                titleFont = [UIFont systemFontOfSize:30/2.f];
//                break;
//            case 4:
//                titleFont = [UIFont systemFontOfSize:34/2.f];
//                break;
//            case 5:
//                titleFont = [UIFont systemFontOfSize:40/2.f];
//                break;
//
//            default:
//                break;
//        }
    }
    return titleFont;
}

//横划卡片标题
+ (UIFont *)trainCardNewsTitleFont {
    UIFont *titleFont = nil;
//    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
//        switch (fontsize) {
//            case 2:
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:44/3.f];
//                //                titleFont = [UIFont systemFontOfSize:44/3.f];
//                break;
//            case 3:
                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:48/3.f];
                //                titleFont = [UIFont systemFontOfSize:48/3.f];
//                break;
//            case 4:
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:54/3.f];
//                //                titleFont = [UIFont systemFontOfSize:54/3.f];
//                break;
//            case 5:
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:62/3.f];
//                //                titleFont = [UIFont systemFontOfSize:62/3.f];
//                break;
//
//            default:
//                break;
//        }
        
    }
    else{
//        switch (fontsize) {
//            case 2:
//                //                titleFont = [UIFont systemFontOfSize:28/2.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:28/2.f];
//                break;
//            case 3:
                //                titleFont = [UIFont systemFontOfSize:30/2.f];
                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:30/2.f];
//                break;
//            case 4:
//                //                titleFont = [UIFont systemFontOfSize:34/2.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:34/2.f];
//                break;
//            case 5:
//                //                titleFont = [UIFont systemFontOfSize:40/2.f];
//                titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:40/2.f];
//                break;
//
//            default:
//                break;
//        }
    }
    return titleFont;
}

+ (UIColor *)bulletsColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsRegionImage];
        if (colorStr.length <= 0) {
            colorStr = @"#656565";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsRegionImage];
        if (colorStr.length <= 0) {
            colorStr = @"#656565";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (CGFloat)bulletsAlpha {
    NSString *alphaStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsRegionImageTransparency];
    if (alphaStr.length > 0) {
        return [alphaStr floatValue];
    }
    return 1;
}

+ (UIColor *)segmentLineColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsSplitLineColor];
        if (colorStr.length <= 0) {
            colorStr = @"#656565";
        }
        return [UIColor colorFromString:colorStr];
        
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSplitLineColor];
        if (colorStr.length <= 0) {
            colorStr = @"#656565";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (CGFloat)segmentLineAlpha {
    NSString *alphaStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getSplitLineTransparency];
    if (alphaStr.length > 0) {
        return [alphaStr floatValue];
    }
    return 1;
}

+ (UIColor *)newsTitleColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        return [UIColor colorFromString:@"#969696"];
    }else{
        return [UIColor colorFromString:@"#FFFFFF"];
    }
}

+ (UIColor *)editNewsTitleColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsWorldColour];
        if (colorStr.length <= 0) {
            colorStr = @"#808080";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsWorldColour];
        if (colorStr.length <= 0) {
            colorStr = @"#FFFFFF";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (UIColor *)cardNewsTitleColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        return [UIColor colorFromString:@"#808080"];
    }else{
        return [UIColor colorFromString:@"#FFFFFF"];
    }
}

+ (UIColor *)focusBackgroundColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsBgColour];
        if (colorStr.length <= 0) {
            colorStr = @"#242424";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsBgColour];
        if (colorStr.length <= 0) {
            colorStr = @"#343434";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (UIColor *)focusGradientBackgroundColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsGradientBgColour];
        if (colorStr.length <= 0) {
            colorStr = @"#242424";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsGradientBgColour];
        if (colorStr.length <= 0) {
            colorStr = @"#343434";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (CGFloat)focusGradientBackgroundAlpha {
    NSString *alphaStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsGradientBgTransparency];
    if (alphaStr.length > 0) {
        return [alphaStr floatValue];
    }
    return 0;
}

+ (UIColor *)sohuEditLabelBackgroundColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsSourceWordBgColour];
        if (colorStr.length <= 0) {
            colorStr = @"#862718";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSourceWordBgColour];
        if (colorStr.length <= 0) {
            colorStr = @"#e42000";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (UIColor *)sohuEditLabelTextColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsSourceWordColour];
        if (colorStr.length <= 0) {
            colorStr = @"#969696";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSourceWordColour];
        if (colorStr.length <= 0) {
            colorStr = @"#FFFFFF";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (CGFloat)sohuEditLabelAlpha {
    NSString *alphaStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getSourceWordBgColourTransparency];
    if (alphaStr.length > 0) {
        return [alphaStr floatValue];
    }
    return 0.6;
}

+ (UIColor *)commentWordsColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsCommentWordColour];
        if (colorStr.length <= 0) {
            colorStr = @"#969696";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsCommentWordColour];
        if (colorStr.length <= 0) {
            colorStr = @"#FFFFFF";
        }
        return [UIColor colorFromString:colorStr];
    }
}

+ (UIColor *)adTextBackgroundColor {
    UIColor *originColor = [UIColor colorFromString:@"#666666"];
    return [UIColor colorWithRed:originColor.red green:originColor.green blue:originColor.blue alpha:0.6];
}

+ (UIColor *)trainCellEditorLabelTitleColor {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        return [UIColor colorFromString:@"#808080"];
    }else{
        return [UIColor colorFromString:@"#ffffff"];
    }
}

+ (CGFloat)whiteThemeBottomLineAlpha {
    NSString *alphaStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getBottomSplitLineTransparency];
    if (alphaStr.length > 0) {
        return [alphaStr floatValue];
    }
    return 0;
}

+ (CGFloat)videoImgOffsetInTitle {
    CGFloat offset = -4;
    return offset;
//    int fontsize = [SNUtility getNewsFontSizeIndex];
//    if ([[SNDevice sharedInstance] isPlus]) {
//        switch (fontsize) {
//            case 2:
//                break;
//            case 3:
//                break;
//            case 4:
//                offset = -3;
//                break;
//            case 5:
//                offset = -2;
//                break;
//            default:
//                break;
//        }
//
//    }
//    else{
//        switch (fontsize) {
//            case 2:
//                break;
//            case 3:
//                break;
//            case 4:
//                offset = -3;
//                break;
//            case 5:
//                offset = -2;
//                break;
//            default:
//                break;
//        }
//    }
//    return offset;
}

+ (UIFont *)trainCardCellEditLabelFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:28/2.f];
}

+ (UIColor *)newsWordClickedColour {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    UIColor * color = nil;
    if (isNightTheme) {
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNight_NewsWordClickedColour];
        if (colorStr.length <= 0) {
            colorStr = @"#5c5c5c";
        }
        return [UIColor colorFromString:colorStr];
    }else{
        NSString *colorStr = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsWordClickedColour];
        if (colorStr.length <= 0) {
            colorStr = @"#929292";
        }
        return [UIColor colorFromString:colorStr];
    }
}

@end
