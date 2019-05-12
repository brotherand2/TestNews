//
//  UIFont+Theme.m
//  sohunews
//
//  Created by lhp on 3/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "UIFont+Theme.h"

@implementation UIFont (Theme)

+ (float)getIphone6PlusWithType:(UIFontSizeType) type {
    float fontSize = 30.0f/3;
    switch (type) {
        case UIFontSizeTypeA:
            fontSize = 30.0f/3;
            break;
        case UIFontSizeTypeB:
            fontSize = 35.0f/3;
            break;
        case UIFontSizeTypeC:
            fontSize = 48.0f/3;
            break;
        case UIFontSizeTypeD:
            fontSize = 50.0f/3;
            break;
        case UIFontSizeTypeE:
            fontSize = 55.0f/3;
            break;
        case UIFontSizeTypeF:
            fontSize = 72.0f/3;
            break;
        case UIFontSizeTypeG:
            fontSize = 42.0f/3;
            break;
        case UIFontSizeTypeH:
            fontSize = 58.0f/3;
            break;
        case UIFontSizeTypeM:
            fontSize = 64.0f/3;
            break;
        case UIFontSizeTypeL:
            fontSize = 102.0f/3;
            break;
        case UIFontSizeTypeN:
            fontSize = 72.0f/3;
            break;
        default:
            break;
    }
    return fontSize;
}

+ (float)getIphoneWithType:(UIFontSizeType) type {
    float fontSize = 18.0f/2;
    switch (type) {
        case UIFontSizeTypeA:
            fontSize = 18.0f/2;
            break;
        case UIFontSizeTypeB:
            fontSize = 22.0f/2;
            break;
        case UIFontSizeTypeC:
            fontSize = 26.0f/2;
            break;
        case UIFontSizeTypeD:
            fontSize = 32.0f/2;
            break;
        case UIFontSizeTypeE:
            fontSize = 36.0f/2;
            break;
        case UIFontSizeTypeF:
            fontSize = 44.0f/2;
            break;
        case UIFontSizeTypeG:
            fontSize = 28.0f/2;
            break;
        case UIFontSizeTypeH:
            fontSize = 40.0f/2;
            break;
        case UIFontSizeTypeL:
            fontSize = 68.0f/2;
            break;
        case UIFontSizeTypeN:
            fontSize = 46.0f/2;
            break;
        default:
            break;
    }
    return fontSize;
}

+ (UIFont *)systemFontOfSizeType:(UIFontSizeType) type {
    float fontSize = [self fontSizeWithType:type];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    return font;
}

+ (float)fontSizeWithType:(UIFontSizeType) type {
    float fontSize = 18/2;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            fontSize = [self getIphone6PlusWithType:type];
            break;
        default:
            fontSize = [self getIphoneWithType:type];
            break;
    }
    return fontSize;
}

@end
