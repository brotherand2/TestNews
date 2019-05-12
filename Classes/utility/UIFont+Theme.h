//
//  UIFont+Theme.h
//  sohunews
//
//  Created by lhp on 3/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIFontSizeTypeA,
    UIFontSizeTypeB,
    UIFontSizeTypeC,
    UIFontSizeTypeD,
    UIFontSizeTypeE,
    UIFontSizeTypeF,
    UIFontSizeTypeG,
    UIFontSizeTypeH,
    UIFontSizeTypeM,
    UIFontSizeTypeL,
    UIFontSizeTypeN,
} UIFontSizeType;

@interface UIFont (Theme)

+ (UIFont *)systemFontOfSizeType:(UIFontSizeType) type;
+ (float)fontSizeWithType:(UIFontSizeType) type;

@end
