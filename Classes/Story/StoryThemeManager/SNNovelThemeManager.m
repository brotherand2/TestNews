//
//  SNNovelThemeManager.m
//  sohunews
//
//  Created by H on 2016/10/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNovelThemeManager.h"
#import "SNStoryContanst.h"

@implementation SNNovelThemeManager

+ (SNNovelThemeManager *)manager {
    static SNNovelThemeManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SNNovelThemeManager alloc] init];
        
    });
    return _manager;
}

- (void)setNovelThemeAlternate {
    _isNightTheme = !_isNightTheme;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *selectedColorTheme = [userDefault objectForKey:@"selectedColorTheme"];
    if (_isNightTheme) {
        [userDefault setObject:@"4" forKey:@"storyColorTheme"];
    } else {
        [userDefault setObject:selectedColorTheme forKey:@"storyColorTheme"];
    }
    [userDefault synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNovelThemeDidChangeNotification object:nil];
}

- (void)setNovelDefaultTheme {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (_isNightTheme || ![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"0"]) {
        _isNightTheme = NO;
        [userDefault setObject:@"0" forKey:@"storyColorTheme"];
        [userDefault setObject:@"0" forKey:@"selectedColorTheme"];
        [userDefault synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNovelThemeDidChangeNotification object:nil];
    }
}

-(void)setNovelPictureTheme
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"1"]) {
        _isNightTheme = NO;
        
        [userDefault setObject:@"1" forKey:@"storyColorTheme"];
        [userDefault setObject:@"1" forKey:@"selectedColorTheme"];
        [userDefault synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNovelThemeDidChangeNotification object:nil];
    }
}

-(void)setNovelWaterRedTheme
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"2"]) {
        _isNightTheme = NO;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:@"2" forKey:@"storyColorTheme"];
        [userDefault setObject:@"2" forKey:@"selectedColorTheme"];
        [userDefault synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNovelThemeDidChangeNotification object:nil];
    }
}

-(void)setNovelCyanTheme
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"3"]) {
        _isNightTheme = NO;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:@"3" forKey:@"storyColorTheme"];
        [userDefault setObject:@"3" forKey:@"selectedColorTheme"];
        [userDefault synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNovelThemeDidChangeNotification object:nil];
    }
}

- (void)setNovelNightTheme {
    if (!_isNightTheme) {
        _isNightTheme = YES;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:@"4" forKey:@"storyColorTheme"];
        [userDefault synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNovelThemeDidChangeNotification object:nil];
    }
}
@end
