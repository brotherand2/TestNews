//
//  SNStoryContanst.h
//  sohunews
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "UIColor+StoryColor.h"

#define View_Width          [[UIScreen mainScreen]bounds].size.width
#define View_Height         [[UIScreen mainScreen]bounds].size.height
#define BottomBarHeight     45

#define STORY_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define STORY_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

//导航栏高
#define StoryHeaderHeight               44
//导航栏＋状态栏
#define StoryHeaderTotalHeight          (StoryHeaderHeight + StoryBarHeight)
//状态栏高
#define StoryBarHeight                  (STORY_SYSTEM_VERSION_LESS_THAN(@"7.0") ? 0.f : 20.f)
#define StoryBarStatusHeight            [UIApplication sharedApplication].statusBarFrame.size.height//状态栏高度

//定义5种阅读背景色
#define StoryReadBackgroundColor1                       @"#ffffff"
#define StoryReadBackgroundColor2                       @"#fcf8f2"
#define StoryReadBackgroundColor3                       @"#feecf2"
#define StoryReadBackgroundColor4                       @"#d8f6dc"
#define StoryReadBackgroundColor5                       @"#242424"

#define StoryColorTheme                                 @"storyColorTheme"//阅读背景色
#define StoryselectedColor                              @"selectedColorTheme"//选择背景色
#define HasReadChapterIndex                             @"hasReadChapterIndex"//已读过的章节
#define HasReadChapterId                                @"hasReadChapterId"//已读过的章节id
#define HasReadPageNum                                  @"hasReadPageNum"//已读过的章节的哪一页

//定义背景色和字色
#define ThemeBg1Color                                   @"kThemeBg1Color"
#define ThemeBg3Color                                   @"kThemeBg3Color"
#define ThemeBg4Color                                   @"kThemeBg4Color"
#define ThemeRed1Color                                  @"kThemeRed1Color"
#define ThemeText1Color                                 @"kThemeText1Color"
#define ThemeText2Color                                 @"kThemeText2Color"
#define ThemeText3Color                                 @"kThemeText3Color"
#define ThemeText7Color                                 @"kThemeText7Color"

#define kNovelThemeDidChangeNotification                @"kNovelThemeDidChangeNotification"
#define WXPurchaseChapterContentNotification            @"WXPurchaseChapterContent"//小说章节购买
