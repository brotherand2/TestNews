//
//  SNToast.m
//  sohunews
//
//  Created by jialei on 14-10-18.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNToast.h"
#import "SNToastView.h"

#define kToastBlockMaskViewTag      (2014)
#define kToastPointY                 20

static SNToast *__instance = nil;

@interface SNToast() {
    SNToastLayoutType _layoutType;
}

@property (nonatomic, strong)__block NSMutableArray *viewArray;

@end

@implementation SNToast

+ (SNToast *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __instance = [[SNToast alloc] init];
    });
    return __instance;
}

#pragma mark - Singleton
- (id)init {
    if (__instance) {
        return __instance;
    }
    if(self = [super init]) {
        _viewArray = [NSMutableArray array];
        _layoutType = SNToastLayoutTypeBelowStatusBar;
    }
    
    return self;
}

- (UIView*)rootView {
//    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    UIView *topView = [TTNavigator navigator].window;
//    while (topController.presentedViewController) {
//        topController = topController.presentedViewController;
//    }
    UIWindow *_screenWindow = [UIApplication sharedApplication].keyWindow;
    UIView *msgSuperView = _screenWindow;
    if ([_screenWindow subviews].count > 0
        && [[_screenWindow subviews] objectAtIndex:0]) {
        msgSuperView = [[_screenWindow subviews] objectAtIndex:0];
    }
    
    return msgSuperView;
}

#pragma position
- (void)setPosition:(SNToastLayoutType)currentPosition {
    _layoutType = currentPosition;
}


- (NSArray *)imageNameKeys
{
    return @[@"icotoast_warning_v5@2x.png", @"icotoast_success_v5@2x.png", @"icotoast_message_v5@2x.png",
             @"icotoast_dropdown_v5@2x.png", @"icotoast_voice_v5@2x.png", @"icotoast_login_v5@2x.png", @"icotoast_like_v5@2x.png"];
}

#pragma showFunction
- (void)showToastToFullScreenViewWithTitle:(NSString *)title
                                     toUrl:(NSString *)url
                                      mode:(SNToastUIMode)toastMode {
    
    UIWindow *_wsVideoPlayerFullScreenWindow = [UIApplication sharedApplication].keyWindow;
    UIView *msgSuperView = _wsVideoPlayerFullScreenWindow;
    if ([_wsVideoPlayerFullScreenWindow subviews].count > 0
        && [[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0]) {
        msgSuperView = [[_wsVideoPlayerFullScreenWindow subviews] objectAtIndex:0];
    }
    
//    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, kSNToastHeight);
    BOOL isTargetViewLandscape = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([msgSuperView respondsToSelector:@selector(isFullScreen)]) {
        isTargetViewLandscape = [msgSuperView performSelector:@selector(isFullScreen)];
    }
#pragma clang diagnostic pop
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, kSNToastHeight);
    
    if (!isTargetViewLandscape) {
        frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
    }
    
    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:nil
                             mode:toastMode
                        superView:msgSuperView
                            frame:frame
                            toProfile:NO callBack:nil];
}

- (void)showToastWithTitle:(NSString *)title
                     toUrl:(NSString *)url
                  userInfo:(NSDictionary *)userInfo
                      mode:(SNToastUIMode)toastMode {
    UIView* targetView = [self rootView];
    if (targetView==nil) {
        return;
    }
    
    CGRect frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
//    CGRect frame = CGRectMake(0, 0, kAppScreenWidth, kSNToastHeight);
    
    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:userInfo
                             mode:toastMode
                        superView:targetView
                            frame:frame
                            toProfile:NO callBack:nil];
}
- (void)showToastToProfileViewWithTitle:(NSString *)title
                              toProfile:(BOOL)toProfile
                               userInfo:(NSDictionary *)userInfo
                                   mode:(SNToastUIMode)toastMode
                               callBack:(void(^)(void))callBack
{
    UIView* targetView = [self rootView];
    if (targetView==nil) {
        return;
    }
    
    CGRect frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
    [self addToastToViewWithTitle:title
                            toUrl:toProfile? @"if toProfile,url can't be nil" : nil
                         userInfo:userInfo
                             mode:toastMode
                        superView:targetView
                            frame:frame
                            toProfile:toProfile callBack:callBack];
}

/**
 *  自定义button title
 */
- (void)showToastToProfileViewWithTitle:(NSString *)title
                              toProfile:(BOOL)toProfile
                               userInfo:(NSDictionary *)userInfo
                                   mode:(SNToastUIMode)toastMode
                           customButton:(NSString *)buttonTitle
                               callBack:(void(^)(void))callBack
{
    UIView* targetView = [self rootView];
    if (targetView==nil) {
        return;
    }
    
    CGRect frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
    [self addToastToViewWithTitle:title
                            toUrl:toProfile? @"if toProfile,url can't be nil" : nil
                         userInfo:userInfo
                             mode:toastMode
                        superView:targetView
                            frame:frame
                        toProfile:toProfile
                   customBtnTitle:buttonTitle
                         callBack:callBack];
}


- (void)showToastWithTitle:(NSString *)title
                     toUrl:(NSString *)url
                      mode:(SNToastUIMode)toastMode {
//    UIView* targetView = [self rootView];
    UIWindow *targetView = [UIApplication sharedApplication].keyWindow;
    
    if (targetView==nil) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    BOOL isTargetViewLandscape = NO;
    if ([targetView respondsToSelector:@selector(isFullScreen)]) {
        isTargetViewLandscape = [targetView performSelector:@selector(isFullScreen)];
    }
#pragma clang diagnostic pop

    CGRect frame = CGRectZero;
    
    if (_layoutType == SNToastLayoutTypeTop) {
//        frame = CGRectMake(0, 0, kToastWidth, kToastHeight);
        frame = CGRectMake(0, 0, kAppScreenWidth, kSNToastHeight);
    }
    else {
//        frame = CGRectMake(0, kToastPointY, kToastWidth, kToastHeight);
        frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
    }
    
    if (isTargetViewLandscape) {
        frame.origin.y = 0;
        frame.size.width = kAppScreenHeight;
    }

    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:nil
                             mode:toastMode
                        superView:targetView
                            frame:frame
                            toProfile:NO callBack:nil];
}

- (void)showToastToFullScreenViewWithTitle:(NSString *)title
                                     toUrl:(NSString *)url
                                  userInfo:(NSDictionary *)userInfo
                                      mode:(SNToastUIMode)toastMode {
    UIWindow *_fullScreenWindow = [UIApplication sharedApplication].keyWindow;
    UIView *msgSuperView = _fullScreenWindow;
    if ([_fullScreenWindow subviews].count > 0
        && [[_fullScreenWindow subviews] objectAtIndex:0]) {
        msgSuperView = [[_fullScreenWindow subviews] objectAtIndex:0];
    }
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, kSNToastHeight);
    
    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:userInfo
                             mode:toastMode
                        superView:msgSuperView
                            frame:frame
                            toProfile:NO callBack:nil];
}

- (void)showToastToSuperViewWithTitle:(NSString *)title
                                toUrl:(NSString *)url
                                 mode:(SNToastUIMode)toastMode {
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIView* targetView = topController.view;
//    UIView* targetView = [self rootView];
    
    if (targetView==nil) {
        return;
    }
    
    CGRect frame = CGRectZero;
    if (_layoutType == SNToastLayoutTypeTop) {
        frame = CGRectMake(0, 0, kAppScreenWidth, kSNToastHeight);
    }
    else {
        frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
//        frame = CGRectMake(0, 0, kAppScreenWidth, kSNToastHeight);
    }
    
    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:nil
                             mode:toastMode
                        superView:targetView
                            frame:frame toProfile:NO callBack:nil];
}

- (void)showBlockUIToastWithTitle:(NSString *)title
                            toUrl:(NSString *)url
                             mode:(SNToastUIMode)toastMode {
    UIView* targetView = [self rootView];
    if (targetView==nil) {
        return;
    }
//    UIView* targetView = [self rootView];
    
    CGRect frame = CGRectMake(0, kToastPointY, kAppScreenWidth, kSNToastHeight);
//    CGRect frame = CGRectMake(0, 0, kAppScreenWidth, kSNToastHeight);
    
    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:nil
                             mode:toastMode
                        superView:targetView
                            frame:frame toProfile:NO
                         callBack:nil];
    
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *view = [appDelegate.window viewWithTag:kToastBlockMaskViewTag];
    [view removeFromSuperview];
    
    CGRect maskFrame = CGRectMake(0, 0, appDelegate.window.width, appDelegate.window.height);
    UIView *mask = [[UIView alloc] initWithFrame:maskFrame];
    mask.userInteractionEnabled = YES;
    [appDelegate.window addSubview:mask];
    mask.tag = kToastBlockMaskViewTag;
}

- (void)showToastToTargetView:(UIView *)targetView
                        title:(NSString *)title
                        toUrl:(NSString *)url
                     userInfo:(NSDictionary *)userInfo
                         mode:(SNToastUIMode)toastMode {
    if (targetView==nil) {
        return;
    }
    
    CGRect frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kSNToastHeight);
    
    [self addToastToViewWithTitle:title
                            toUrl:url
                         userInfo:userInfo
                             mode:toastMode
                        superView:targetView
                            frame:frame toProfile:NO
                            callBack:nil];
}

- (void)hideToast {
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *view = [appDelegate.window viewWithTag:kToastBlockMaskViewTag];
    [view removeFromSuperview];
    
    if (self.viewArray.count > 0) {
        SNToastView *showToast = (SNToastView *)self.viewArray[0];
        [showToast hide:NO];
    }
    [self.viewArray removeAllObjects];
}

#pragma mark - private Method
- (void)addToastToViewWithTitle:(NSString *)title
                          toUrl:(NSString *)url
                       userInfo:(NSDictionary *)userInfo
                           mode:(SNToastUIMode)toastMode
                      superView:(UIView *)targetView
                          frame:(CGRect)frame
                      toProfile:(BOOL)toProfile
                       callBack:(SNToastViewUrlButtonClicked)callBack

{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self) wself = self;
        SNToastView *toastView = [[SNToastView alloc] initWithFrame:frame];
        toastView.toastText = title;
        toastView.iconImageName = self.imageNameKeys[toastMode];
        toastView.endInterval = kSNToastShowInterval;
        toastView.toastUrl = url;
        toastView.userInfo = userInfo;
        toastView.toProfile = toProfile;
        toastView.urlButtonClickedblock = callBack;
        [toastView setUpToastActionButtonWithTitle:nil];
        toastView.finishedBlock = ^(id view) {
            sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
            UIView *maskView = [appDelegate.window viewWithTag:kToastBlockMaskViewTag];
            [maskView removeFromSuperview];
            
            if ([view isKindOfClass:[SNToastView class]]) {
                [wself.viewArray removeObject:view];
            }
            if (wself.viewArray.count > 0) {
                SNToastView *currentToast = (SNToastView *)wself.viewArray[0];
                [currentToast show:YES];
            }
        };
        
        
        [targetView addSubview:toastView];
        [targetView bringSubviewToFront:toastView];
        
        //如果队列中只有一个toast，直接显示
        if (self.viewArray.count == 0) {
            [toastView show:YES];
        }
        else if (self.viewArray.count > 0) {
            NSInteger count = self.viewArray.count;
            SNToastView *preToast = (SNToastView *)self.viewArray[count - 1];
            if ([preToast.toastText isEqualToString:toastView.toastText]) {
                return;
            }
            
            preToast.endInterval = kSNToastMutiShowInterval;
        }
        //当前toast加入队列
        if (self.viewArray) {
            [self.viewArray addObject:toastView];
        }
    });
}

/**
 *  自定义跳转按钮title的toast
 *
 */
- (void)addToastToViewWithTitle:(NSString *)title
                          toUrl:(NSString *)url
                       userInfo:(NSDictionary *)userInfo
                           mode:(SNToastUIMode)toastMode
                      superView:(UIView *)targetView
                          frame:(CGRect)frame
                      toProfile:(BOOL)toProfile
                 customBtnTitle:(NSString *)btnTitle
                       callBack:(SNToastViewUrlButtonClicked)callBack

{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self) wself = self;
        SNToastView *toastView = [[SNToastView alloc] initWithFrame:frame];
        toastView.toastText = title;
        toastView.iconImageName = self.imageNameKeys[toastMode];
        toastView.endInterval = kSNToastShowInterval;
        toastView.toastUrl = url;
        toastView.userInfo = userInfo;
        toastView.toProfile = toProfile;
        toastView.urlButtonClickedblock = callBack;
        [toastView setUpToastActionButtonWithTitle:btnTitle];
        toastView.finishedBlock = ^(id view) {
            sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
            UIView *maskView = [appDelegate.window viewWithTag:kToastBlockMaskViewTag];
            [maskView removeFromSuperview];
            
            if ([view isKindOfClass:[SNToastView class]]) {
                [wself.viewArray removeObject:view];
            }
            if (wself.viewArray.count > 0) {
                SNToastView *currentToast = (SNToastView *)wself.viewArray[0];
                [currentToast show:YES];
            }
        };
        
        
        [targetView addSubview:toastView];
        [targetView bringSubviewToFront:toastView];
        
        //如果队列中只有一个toast，直接显示
        if (self.viewArray.count == 0) {
            [toastView show:YES];
        }
        else if (self.viewArray.count > 0) {
            NSInteger count = self.viewArray.count;
            SNToastView *preToast = (SNToastView *)self.viewArray[count - 1];
            if ([preToast.toastText isEqualToString:toastView.toastText]) {
                return;
            }
            
            preToast.endInterval = kSNToastMutiShowInterval;
        }
        //当前toast加入队列
        if (self.viewArray) {
            [self.viewArray addObject:toastView];
        }
    });
}


@end
