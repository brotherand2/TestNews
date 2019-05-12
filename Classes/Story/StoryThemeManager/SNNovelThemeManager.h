//
//  SNNovelThemeManager.h
//  sohunews
//
//  Created by H on 2016/10/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#define kSNThemeBgColor             (@"#1f1f1f")
#define kSNThemeBgColorNight        (@"#242424")
#define kSNThemeTextColor           (@"#292104")
#define kSNThemeTextColorNight      (@"#929292")
#define StoryTheme                  @"storyColorTheme"//0:日间模式 1:夜间模式 2:图片模式 3:青色模式 4:水红色模式
#import <Foundation/Foundation.h>

@interface SNNovelThemeManager : NSObject

@property (nonatomic, assign, readonly) BOOL isNightTheme;

+ (SNNovelThemeManager *)manager;


/**
 日夜模式交替
 */
- (void)setNovelThemeAlternate;

/**
 设置夜间模式
 */
- (void)setNovelNightTheme;

/**
 设置日间模式
 */
- (void)setNovelDefaultTheme;

/**
 设置图片模式模式
 */
- (void)setNovelPictureTheme;

/**
 设置青色模式
 */
- (void)setNovelCyanTheme;

/**
 设置日水红模式
 */
- (void)setNovelWaterRedTheme;

@end
