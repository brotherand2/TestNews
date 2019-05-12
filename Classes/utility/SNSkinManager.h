//
//  SNSkinManager.h
//  sohunews
//
//  Created by Xiang Wei Jia on 2/12/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum eSkinManagerColors
{
    // 文字颜色
    SkinText1 = 0,
    SkinText1Touch,
    SkinText2,
    SkinText3,
    SkinText3Touch,
    SkinText4,
    SkinText4Touch,
    SkinText5,
    SkinText6,
    
    // 背景色颜色
    SkinBg1,
    SkinBg2,
    SkinBg3,
    SkinBg4,
    
    // 彩色
    SkinRed,
    SkinRedTouch,
    SkinBlue,
    SkinYellow,
    SkinGreen,
    
    // icon
    SkinIconCanTouch,
    SkinIconCannotTouch,
    
}SkinManagerColors;

typedef enum eSkinManagerFontSize
{
    SkinFontA = 0,
    SkinFontB,
    SkinFontC,
    SkinFontD,
    SkinFontE,
    SkinFontF,
    SkinFontG,
    SkinFont13,   // 未改版字体,13号字
    
}SkinManagerFontSize;

typedef enum eSkinType
{
    SkinDay = 0,  // 白天
    SkinNight  // 夜间模式
}SkinType;

typedef enum eSkinAlpha
{
    SkinAlpha5 = 0,  // 0.5
    SkinAlpha7,    // 0.7
}SkinAlpha;

@interface SNSkinManager : NSObject

+(SNSkinManager *) skinInstance;

+(float) fontSize:(SkinManagerFontSize)size;
+(UIFont*) font:(SkinManagerFontSize)size;
+(UIFont*) fontBold:(SkinManagerFontSize)size;
+(UIColor *) color:(SkinManagerColors)color;

+(SkinType) skinType;
+(void) setSkinType:(SkinType)type;

+(float) skinAlpha:(SkinAlpha)alpha;

- (void)updateCurrentTheme;

@end
