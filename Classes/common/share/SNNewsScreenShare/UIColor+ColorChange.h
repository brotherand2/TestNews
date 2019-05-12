//
//  UIColor+ColorChange.h
//  sohunews
//
//  Created by wang shun on 2017/7/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//用于截屏分享 画板 颜色条
@interface UIColor (ColorChange)

// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+ (UIColor *) colorWithHexString: (NSString *)color;

@end
