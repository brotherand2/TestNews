//
//  SNSkinMaskView.m
//  sohunews
//
//  Created by Gao Yongyue on 14-4-23.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSkinMaskWindow.h"
#import "SNSkinMaskRootViewController.h"

@implementation SNSkinMaskWindow

+ (instancetype)sharedInstance
{
    return nil;
    static SNSkinMaskWindow *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNSkinMaskWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return sharedInstance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = NO;
        [self updateTheme];
        [self becameAppActive];
        
        SNSkinMaskRootViewController *rootViewController = [[SNSkinMaskRootViewController alloc] init];
        [self setRootViewController:rootViewController];
    }
    return self;
}

- (void)show
{
    self.hidden = NO;
}

- (void)hide
{
    self.hidden = YES;
}

- (void)resignAppActive
{
    self.windowLevel = UIWindowLevelStatusBar + 1;
}

- (void)becameAppActive
{
    self.windowLevel = UIWindowLevelAlert + 102; //为了盖住UIMenuController才加到这个大的（经过测试，UIWindowLevelAlert+100应该是正等于UIMenuController的level（除了UIWebView））
}

- (void)updateStatusBarAppearanceWithLightContentMode:(BOOL)lightContentMode;
{
    ((SNSkinMaskRootViewController *)self.rootViewController).lightContentMode = lightContentMode;
}

- (void)hideStatusbar
{
    ((SNSkinMaskRootViewController *)self.rootViewController).hideStatusbar = YES;
}

- (void)showStatusbar
{
    ((SNSkinMaskRootViewController *)self.rootViewController).hideStatusbar = NO;
}

- (void)updateTheme
{
//    [UIView animateWithDuration:.3f animations:^{
//        if ([[SNThemeManager sharedThemeManager].currentTheme isEqualToString:kThemeNight])
//        {
//            self.backgroundColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:.7f];
//        }
//        else
//        {
//            self.backgroundColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:.0f];
//        }
//    }];
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

- (void)makeKeyWindow {
    sohunewsAppDelegate * appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeKeyAndVisible];
}

@end
