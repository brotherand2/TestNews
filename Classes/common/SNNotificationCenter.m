//
//  SNNotificationCenter.m
//  sohunews
//
//  Created by Dan on 7/6/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNNotificationCenter.h"
#import "Toast+UIView.h"
#import "SNConsts.h"
#import "sohunewsAppDelegate.h"
#import "WSMVVideoPlayerView.h"
#import "SNToast.h"


@implementation SNNotificationCenter

+ (void)showMessage:(NSString *)text {
    if ([NSThread isMainThread]) {
        [self showActivityTitle:nil detail:text hideAfter:kMessageLiveTime];
    } else {
        [self performSelectorOnMainThread:@selector(showMessage:) withObject:text waitUntilDone:NO];
    }
}

+ (void)showMessageTitle:(NSString *)title detail:(NSString *)detail {
    [self showActivityTitle:title detail:detail hideAfter:kMessageLiveTime];
}

+ (void)showMessage:(NSString *)text hideAfter:(NSInteger)interval {
    [self showActivityTitle:nil detail:text hideAfter:interval];
}

+ (void)showMessageTitle:(NSString *)title detail:(NSString *)detail hideAfter:(NSInteger)interval {
    [self showActivityTitle:title detail:detail hideAfter:interval];
}

+ (void)showLoading:(NSString *)text {
//    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate.window makeActivityToast:text position:[NSValue valueWithCGPoint:CGPointMake(160, appDelegate.window.size.height - 70)]];
    //[[SNCenterToast shareInstance] showCenterToastWithTitle:text toUrl:nil mode:SNCenterToastModeOnlyText];
}

+ (void)showLoadingAndBlockOtherActions:(NSString *)text {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self showLoading:text];
    
    UIView *view = [appDelegate.window viewWithTag:kLoadingBlockMaskViewTag];
    [view removeFromSuperview];
    
    CGRect frame = CGRectMake(0, 0, appDelegate.window.width, appDelegate.window.height);
    UIView *mask = [[UIView alloc] initWithFrame:frame];
    mask.userInteractionEnabled = YES;
    [appDelegate.window addSubview:mask];
    mask.tag = kLoadingBlockMaskViewTag;
}

+ (void)hideLoadingAndBlock {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *view = [appDelegate.window viewWithTag:kLoadingBlockMaskViewTag];
    [view removeFromSuperview];
    [self hideLoading];
    [appDelegate.window hideActivityToast];
    
}

+ (void)hideLoading {
//    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
//    UIView *view = [appDelegate.window viewWithTag:kLoadingBlockMaskViewTag];
//    [view removeFromSuperview];
//    [appDelegate.window hideActivityToast];
    [[SNToast shareInstance] hideToast];
}

+ (void)showExclamationTitle:(NSString *)title detail:(NSString *)detail {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
}

+ (void)showExclamation:(NSString *)text {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAticleVideoIsFullScreenKey]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil userInfo:nil mode:SNCenterToastModeError];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

+ (void)showMessageAboveKeyboard:(NSString *)text {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *userView =[[UIApplication sharedApplication] keyboardView];
    
    CGFloat y = userView ? userView.top - 25 : ([UIScreen mainScreen].applicationFrame.size.height - 292);
    
    [appDelegate.window makeToast:text image:nil duration:1 position:[NSValue valueWithCGPoint:CGPointMake(160, y)]];
}

+ (void)showMessageAtBottom:(NSString *)text hideAfter:(NSInteger)interval {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.window makeToast:text image:nil duration:interval position:@"bottom"];
}

+ (void)showMessage:(NSString *)text atPos:(CGPoint)pt hideAfter:(NSInteger)interval {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeToast:text image:nil duration:interval position:[NSValue valueWithCGPoint:pt]];
}

+ (void)showMessage:(NSString *)text atPos:(CGPoint)pt arrowXPosition:(CGFloat)xPos hideAfter:(NSInteger)interval {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeToast:text image:nil duration:interval position:[NSValue valueWithCGPoint:pt] arrowXPosition:xPos];
}

+ (void)hideMessage {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window closeToast];
}

#pragma mark - VideoTab VideoPlayer fullscreen message
+ (void)showMessageForFullScreenWSVideoPlayer:(NSString *)text {
    if ([NSThread isMainThread]) {
        UIWindow *_wsVideoPlayerFullScreenWindow = [UIApplication sharedApplication].keyWindow;
        UIView *msgSuperView = _wsVideoPlayerFullScreenWindow;
        if ([_wsVideoPlayerFullScreenWindow subviews].count > 0
            && [[[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0] isKindOfClass:[WSMVVideoPlayerView class]]) {
            msgSuperView = [[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0];
        }
        
        [msgSuperView makeToast:text image:nil
                                         duration:2
                                         position:[NSValue valueWithCGPoint:CGPointMake(_wsVideoPlayerFullScreenWindow.height/2.0f, _wsVideoPlayerFullScreenWindow.width - 70)]];
    }
    else {
        [self performSelectorOnMainThread:@selector(showMessageForFullScreenWSVideoPlayer:) withObject:text waitUntilDone:NO];
    }
}

+ (void)hideMessageImmediatelyForFullScreenWSVideoPlayer {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideMessageImmediatelyForFullScreenWSVideoPlayer];
        });
        return;
    }
    
    UIWindow *_wsVideoPlayerFullScreenWindow = [UIApplication sharedApplication].keyWindow;
    UIView *msgSuperView = _wsVideoPlayerFullScreenWindow;
    if ([_wsVideoPlayerFullScreenWindow subviews].count > 0
        && [[[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0] isKindOfClass:[WSMVVideoPlayerView class]]) {
        msgSuperView = [[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0];
    }
    
    [msgSuperView hideToastAnimation];
}

#pragma mark - Message with action
#pragma mark - FullScreen
+ (void)showMessageForFullScreenWSVideoPlayer:(NSString *)text action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo hideAfter:(NSInteger)interval {
    if (text.length <= 0) {
        return;
    }
    if (interval <= 0) {
        interval = kMessageLiveTime;
    }
    
    if ([NSThread isMainThread]) {
        [self showActivityForFullScreenWSMVVideoPlayerWithDetail:text action:actionURL userInfo:userInfo hideAfter:interval];
    }
    else {
        NSMutableDictionary *tempUserInfo = [NSMutableDictionary dictionary];
        if (userInfo.count > 0) {
            [tempUserInfo setValuesForKeysWithDictionary:userInfo];
        }
        if (text.length > 0) {
            [tempUserInfo setValue:text forKey:kToast_Text];
        }
        if (actionURL.length > 0) {
            [tempUserInfo setValue:actionURL forKey:kToast_ActionURL];
        }
        [tempUserInfo setObject:@(interval) forKey:kToast_HideAfter];
        [self performSelectorOnMainThread:@selector(showMessageForFullScreenWSVideoPlayerWithAction:) withObject:tempUserInfo waitUntilDone:NO];
    }
}

+ (void)showMessageForFullScreenWSVideoPlayerWithAction:(NSMutableDictionary *)userInfo {
    NSString *text = [userInfo stringValueForKey:kToast_Text defaultValue:nil];
    NSString *actionURL = [userInfo stringValueForKey:kToast_ActionURL defaultValue:nil];
    int hideAfter = [[userInfo objectForKey:kToast_HideAfter defalutObj:nil] intValue];
    if (hideAfter <= 0) {
        hideAfter = kMessageLiveTime;
    }
    
    if (text.length <= 0) {
        return;
    }
    [self showActivityForFullScreenWSMVVideoPlayerWithDetail:text action:actionURL userInfo:userInfo hideAfter:hideAfter];
}

+ (void)showActivityForFullScreenWSMVVideoPlayerWithDetail:(NSString *)detail action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo
                                                 hideAfter:(NSInteger)interval {
    UIWindow *_wsVideoPlayerFullScreenWindow = [UIApplication sharedApplication].keyWindow;
    UIView *msgSuperView = _wsVideoPlayerFullScreenWindow;
    if ([_wsVideoPlayerFullScreenWindow subviews].count > 0
        && [[[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0] isKindOfClass:[WSMVVideoPlayerView class]]) {
        msgSuperView = [[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0];
    }
    [msgSuperView makeToast:detail
                                       action:actionURL
                                     userInfo:userInfo
                                forFullScreen:YES
                                     duration:interval
                                     position:[NSValue valueWithCGPoint:CGPointMake(_wsVideoPlayerFullScreenWindow.height/2.0f, _wsVideoPlayerFullScreenWindow.width - 70)]];
}

#pragma mark - Non-FullScreen
+ (void)showMessage:(NSString *)text action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo hideAfter:(NSInteger)interval {
    if (text.length <= 0) {
        return;
    }
    
    if (interval <= 0) {
        interval = kMessageLiveTime;
    }
    
	if ([NSThread isMainThread]) {
        [self showActivityWithDetail:text action:actionURL userInfo:userInfo hideAfter:interval];
    } else {
        NSMutableDictionary *tempUserInfo = [NSMutableDictionary dictionary];
        if (userInfo.count > 0) {
            [tempUserInfo setValuesForKeysWithDictionary:userInfo];
        }
        if (text.length > 0) {
            [tempUserInfo setValue:text forKey:kToast_Text];
        }
        if (actionURL.length > 0) {
            [tempUserInfo setValue:actionURL forKey:kToast_ActionURL];
        }
        [tempUserInfo setObject:@(interval) forKey:kToast_HideAfter];
        [self performSelectorOnMainThread:@selector(showMessageWithAction:) withObject:tempUserInfo  waitUntilDone:NO];
    }
}

+ (void)showMessageWithAction:(NSMutableDictionary *)userInfo {
    NSString *text = [userInfo stringValueForKey:kToast_Text defaultValue:nil];
    NSString *actionURL = [userInfo stringValueForKey:kToast_ActionURL defaultValue:nil];
    int hideAfter = [[userInfo objectForKey:kToast_HideAfter defalutObj:nil] intValue];
    if (hideAfter <= 0) {
        hideAfter = kMessageLiveTime;
    }
    
    if (text.length <= 0) {
        return;
    }
    [self showActivityWithDetail:text action:actionURL userInfo:userInfo hideAfter:hideAfter];
}

+ (void)showActivityWithDetail:(NSString *)detail action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo hideAfter:(NSInteger)interval {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeToast:detail action:actionURL userInfo:userInfo forFullScreen:NO
                        duration:interval position:[NSValue valueWithCGPoint:CGPointMake(160, appDelegate.window.size.height - 70)]];
}

#pragma mark -
+ (void)showNoWifiTitle:(NSString *)title detail:(NSString *)detail hideAfter:(NSInteger)interval {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeToast:detail image:nil
                         duration:interval
                         position:[NSValue valueWithCGPoint:CGPointMake(160, appDelegate.window.size.height - 70)]];
}

+ (void)showActivityTitle:(NSString *)title detail:(NSString *)detail hideAfter:(NSInteger)interval {
    SNSplashViewController *splashViewController = [SNUtility getApplicationDelegate].splashViewController;
    if ([splashViewController isSplashViewVisible]) {
        [splashViewController.fullscreenWindow makeToast:detail
                                                   image:nil
                                                duration:interval
                                                position:[NSValue valueWithCGPoint:CGPointMake(160, splashViewController.fullscreenWindow.size.height - 70)]];

    }else {
        sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window makeToast:detail
                                image:nil
                             duration:interval
                             position:[NSValue valueWithCGPoint:CGPointMake(160, appDelegate.window.size.height - 70)]];
    }
}

@end
