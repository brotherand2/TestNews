//
//  UIColor+StoryColor.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/10.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(StoryColor)

+ (UIColor *)storyColorFromString:(const NSString *)string;
+ (UIColor *)colorFromKey:(const NSString *)forKey;
@end
