//
//  UIColor+ColorUtils.h
//
//  Version 1.0.1
//
//  Created by Nick Lockwood on 19/11/2011.
//  Copyright (c) 2011 Charcoal Design. All rights reserved.
//
//  Get the latest version of ColorUtils from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#colorutils
//  https://github.com/nicklockwood/ColorUtils
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <UIKit/UIKit.h>

#define SNUICOLOR(key)    [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:key]]
#define SNUICOLORREF(key) [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:key]].CGColor

@interface UIColor (ColorUtils)

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

+ (UIColor *)colorFromString:(const NSString *)string;
+ (UIColor *)colorWithRGBValue:(int32_t)rgb;
+ (UIColor *)colorWithRGBAValue:(uint32_t)rgba;
+ (UIColor *)initWithString:(NSString *)string;
+ (UIColor *)initWithRGBValue:(int32_t)rgb;
+ (UIColor *)initWithRGBAValue:(uint32_t)rgba;
+ (UIColor *)mixColor1:(UIColor *)color1
                color2:(UIColor *)color2
                 ratio:(CGFloat)ratio;
- (int32_t)RGBValue;
- (uint32_t)RGBAValue;
- (NSString *)stringValue;

- (BOOL)isMonochromeOrRGB;
- (BOOL)isEquivalent:(id)object;
- (BOOL)isEquivalentToColor:(UIColor *)color;

- (void)getColorComponents:(CGFloat *)rgba;

@end
