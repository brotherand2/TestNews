//
//  UIColor+StoryColor.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/10.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "UIColor+StoryColor.h"

@implementation UIColor(StoryColor)

+ (UIColor *)storyColorFromString:(const NSString *)string
{
    //convert to lowercase
    NSString *colorString = [NSString stringWithFormat:@"%@",string];
    colorString = [colorString lowercaseString];
    
    //create new instance
    return [[self alloc] initWithString:colorString] ;
}

+ (UIColor *)colorFromKey:(const NSString *)forKey
{
    //convert to lowercase
    NSString *path = [[NSBundle mainBundle]pathForResource:@"storyDefault" ofType:@"plist"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        
        path = [[NSBundle mainBundle]pathForResource:@"storyNight" ofType:@"plist"];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString * string = [dic objectForKey:forKey];
    NSString *colorString = [NSString stringWithFormat:@"%@",string];
    colorString = [colorString lowercaseString];
    
    //create new instance
    return [[self alloc] initWithString:colorString] ;
}

- (UIColor *)initWithString:(NSString *)string
{
    //convert to lowercase
    string = [string lowercaseString];
    
    //try hex
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    switch ([string length])
    {
        case 0:
        {
            string = @"00000000";
            break;
        }
        case 3:
        {
            NSString *red = [string substringWithRange:NSMakeRange(0, 1)];
            NSString *green = [string substringWithRange:NSMakeRange(1, 1)];
            NSString *blue = [string substringWithRange:NSMakeRange(2, 1)];
            string = [NSString stringWithFormat:@"%1$@%1$@%2$@%2$@%3$@%3$@ff", red, green, blue];
            break;
        }
        case 6:
        {
            string = [string stringByAppendingString:@"ff"];
            break;
        }
        case 8:
        {
            //do nothing
            break;
        }
        default:
        {
            
#ifdef DEBUG
            
            //unsupported format
            NSLog(@"Unsupported color string format: %@", string);
#endif
            return nil;
        }
    }
    uint32_t rgba;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanHexInt:&rgba];
    return [self initWithRGBAValue:rgba];
}

- (UIColor *)initWithRGBAValue:(uint32_t)rgba
{
    CGFloat red = ((rgba & 0xFF000000) >> 24) / 255.0f;
    CGFloat green = ((rgba & 0x00FF0000) >> 16) / 255.0f;
    CGFloat blue = ((rgba & 0x0000FF00) >> 8) / 255.0f;
    CGFloat alpha = (rgba & 0x000000FF) / 255.0f;
    return [self initWithRed:red green:green blue:blue alpha:alpha];
}
@end
