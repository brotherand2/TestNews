//
//  SNThemeManager.h
//  sohunews
//
//  Created by qi pei on 5/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNThemeDefines.h"

@interface SNThemeManager : NSObject
{
    NSString *currentTheme;
    NSDictionary *currentThemeDictionary;
    NSCache *imageCachedDictionary;
}

@property(nonatomic, strong) NSDictionary *currentThemeDictionary;
@property(nonatomic, copy) NSString *currentTheme;
@property(nonatomic, copy) NSString *themeDirFullPath;
@property(nonatomic, assign) BOOL isRetina;
@property(nonatomic, strong) NSCache *imageCachedDictionary; // 当前已加载的图片

+ (SNThemeManager*)sharedThemeManager;
-(UIColor *)currentThemeColorForKey:(NSString*)key;
- (NSString*)currentThemeValueForKey:(NSString*)key;
- (NSString*)themeFileName:(NSString*)fileName;
- (NSString *)themeFileNameEx:(NSString *)fileName;
- (NSString*)currentTheme;

- (void)launchCurrentTheme:(NSString *)aTheme;
- (void)clearAllCachedImages; // 清空图片缓存
- (void)dumpAllCachedImages;  // 查看当前缓存的图片信息
- (BOOL)isNightTheme;
- (UIColor *)themeWithColor:(UIColor *) color nightColor:(UIColor *) nightColor;

@end

@interface UIImage (themeImage)
// 返回适合当前主题、当前分辨率的UIImage; 如果没有匹配主题，则返回默认主题;
+ (UIImage *)themeImageNamed:(NSString *)name;
// 覆盖
+ (UIImage *)altImageNamed:(NSString *)name;
@end

@interface UIButton (themeButton)
- (void)altSetTitleColor:(UIColor *)color forState:(UIControlState)state;
@end



#define themeImageAlphaValue() ([[SNThemeManager sharedThemeManager] isNightTheme] ? 0.5f : 1.0f)






