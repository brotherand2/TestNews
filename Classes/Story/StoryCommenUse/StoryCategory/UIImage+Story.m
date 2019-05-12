//
//  UIImage+Story.m
//  StorySoHu
//
//  Created by chuanwenwang on 16/10/27.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "UIImage+Story.h"

@implementation UIImage (Story)

+(UIImage *)imageStoryNamed:(NSString *)name
{
    if (!name || name.length <= 0) {
        return nil;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        
       name = [NSString stringWithFormat:@"night_%@",name];
    }
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}
@end
