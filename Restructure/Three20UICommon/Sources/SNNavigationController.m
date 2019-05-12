//
//  SNNavigationController.m
//
//  Created by guoyalun on 8/7/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "SNNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "SNCommonNewsController.h"
#import "SHH5NewsWebViewController.h"

#define UINavigationBarHeight       (49.0f)
#define kUINavigationScale          (0.98f)

#define kSimulateIOS7PushAnimation   (1)
#define kPushBackAnimationDistance     (-80.0f)
#define kShadowWidth                   (43.0f)


#define  kNavSystemBarHeight       (20.f)


static const CGFloat kAnimationDuration = 0.25f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.4f;

static CGPoint startTouch;//千帆直播

typedef enum {
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
} PanDirection;

@interface SNNavigationController ()<UIGestureRecognizerDelegate>{
    NSMutableArray  *_gestures;
    UIView          *_blackMask;
//    UIView          *_currentControllerStatusbarView;
    UIImageView     *_shadowMask;
    CGPoint          _panOrigin;
    BOOL             _animationInProgress;
    CGFloat          _percentageOffsetFromLeft;
    UIPanGestureRecognizer* panGesture;
    BOOL _isPoping;//动画正在pop
    BOOL _isPushing;//动画正在push
//    BOOL _hideStatusBarWhenPop;
    SNNavigationControllerCompletionBlock _completionHandle;
}

//@property (nonatomic, strong) UIView * preControllerStatusBarView;

- (void) addPanGestureToView:(UIView*)view;
- (void) rollBackViewController;

- (void) transformAtPercentage:(CGFloat)percentage ;
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction;
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset;
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation ;
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation SNNavigationController

- (id) initWithRootViewController:(UIViewController*)rootViewController {
    if (self = [super init]) {
        self.viewControllers = [NSMutableArray arrayWithObject:rootViewController];
        _gestures = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) dealloc {
    self.viewControllers = nil;
    [_gestures release];
    _gestures  = nil;
    [_blackMask release];
    _blackMask = nil;
    [_shadowMask release];
    _shadowMask = nil;
    self.animationImageView = nil;
    [_completionHandle release];
    _completionHandle = nil;
//    self.preControllerStatusBarView = nil;
    [super dealloc];
}

//Only works for iOS7 and greater.
- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self.currentViewController subChildViewControllerForStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
//    if (_hideStatusBarWhenPop) {
//        return _hideStatusBarWhenPop;
//    }
    
    BOOL hidden = NO;
    
    UIViewController *vc = self.viewControllers.lastObject;
    if(vc && [vc respondsToSelector:@selector(prefersStatusBarHidden)])
    {
        hidden = [vc prefersStatusBarHidden];
    }
    
    return hidden;
}

#pragma mark - Load View
- (void) loadView {
    [super loadView];
//    CGRect viewRect = [self viewBoundsWithOrientation:self.interfaceOrientation];
    CGRect bounds = [UIScreen mainScreen].bounds;
    bounds.size.height -= (20.f -  kNavSystemBarHeight);
    CGRect viewRect = bounds;

    if (self.viewControllers.count == 1) {
        UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
        //[rootViewController willMoveToParentViewController:self];
        [self addChildViewController:rootViewController];
        
        UIView * rootView = rootViewController.view;
        rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        rootView.frame = viewRect;
        [self.view addSubview:rootView];
        [rootViewController didMoveToParentViewController:self];

    } else if (self.viewControllers.count > 1) {
        for (UIViewController *vc in self.viewControllers) {
            UIView * currentView = vc.view;
            currentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            currentView.frame = viewRect;
            [self.view addSubview:currentView];
            if (vc != self.rootViewController) {
                [self addPanGestureToView:currentView];
            } else {
                UIViewController *rootViewController = self.rootViewController;
                if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
                    [self.delegate navigationController:self willShowViewController:rootViewController animated:YES];
                }
                /*
                UIView *tabbarView = (UIView *)[self.tabBarController performSelector:@selector(tabbarView)];
                if (tabbarView) {
                    CGRect rect = [rootViewController.view convertRect:tabbarView.frame fromView:tabbarView.superview];
                    [tabbarView removeFromSuperview];
                    tabbarView.frame = rect;
                    [rootViewController.view addSubview:tabbarView];
                }
                */
            }
        }
    }

    _blackMask = [[UIView alloc] initWithFrame:viewRect];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_blackMask atIndex:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAllTouch:)];
    tap.delegate = self;
    [_blackMask addGestureRecognizer:tap];
    [tap release];

#if kSimulateIOS7PushAnimation
    _shadowMask = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(viewRect)-kShadowWidth, 0, kShadowWidth, CGRectGetHeight(viewRect))];
    _shadowMask.backgroundColor = [UIColor clearColor];
    
    // v5.2.0 会造成首页进搜索 搜索结果进二代协议 卡顿 on iPhone 6 plus ??? !!! (这张图本来也看不出效果...)
    //UIImage *image = [UIImage imageNamed:@"popshadow.png"];
    //_shadowMask.backgroundColor = [UIColor colorWithPatternImage:image];
    
    [_blackMask addSubview:_shadowMask];
#endif
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
}

/**
 push一个不带黑色半透明浮层的controller，目前用于书架上书籍打开
 */
- (void)pushViewNoMaskController:(UIViewController *)viewController animated:(BOOL)animated
{
    [SNNotificationManager  postNotificationName:kPushViewControllerNotification object:nil];
    
    if (animated) {
        [self pushViewController:viewController];
    } else {
        viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _blackMask.alpha = 0.0;
        
        [[self currentViewController] viewWillDisappear:NO];
        
        ///[viewController willMoveToParentViewController:self];
        [self addChildViewController:viewController];
        [self.view bringSubviewToFront:_blackMask];
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        [[self currentViewController] viewDidDisappear:NO];
        
        if (self.viewControllers.count == 1) {
            UIViewController *rootViewController = (UIViewController *)[self.viewControllers objectAtIndex:0];
            if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
                [self.delegate navigationController:self willShowViewController:rootViewController animated:YES];
            }
        }
        viewController.view.frame = self.view.bounds;
//        _blackMask.alpha = kMaxBlackMaskAlpha;
        [self.viewControllers addObject:viewController];
        [self resetScrollToTop];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [SNNotificationManager  postNotificationName:kPushViewControllerNotification object:nil];

    if (animated) {
        [self pushViewController:viewController];
    } else {
        viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _blackMask.alpha = 0.0;
        
        [[self currentViewController] viewWillDisappear:NO];
        
        ///[viewController willMoveToParentViewController:self];
        [self addChildViewController:viewController];
        [self.view bringSubviewToFront:_blackMask];
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        [[self currentViewController] viewDidDisappear:NO];
        
        if (self.viewControllers.count == 1) {
            UIViewController *rootViewController = (UIViewController *)[self.viewControllers objectAtIndex:0];
            if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
                [self.delegate navigationController:self willShowViewController:rootViewController animated:YES];
            }
            /*
            UIView *tabbarView = (UIView *)[self.tabBarController performSelector:@selector(tabbarView)];
            if (tabbarView) {
                CGRect rect = [rootViewController.view convertRect:tabbarView.frame fromView:tabbarView.superview];
                [tabbarView removeFromSuperview];
                tabbarView.frame = rect;
                [rootViewController.view addSubview:tabbarView];
            }
            */
        }
        viewController.view.frame = self.view.bounds;
        _blackMask.alpha = kMaxBlackMaskAlpha;
        [self.viewControllers addObject:viewController];
        [self resetScrollToTop];
        ///[viewController didMoveToParentViewController:self];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(SNNavigationControllerCompletionBlock)handler{
    _completionHandle = [handler copy];
    [handler release];
    
    return [self popViewControllerAnimated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *currentVC = [self currentViewController];
    UIViewController *previousVC = [self previousViewController];
    
    if (animated) {
        [self popViewController];
    } else {
        _isPoping = YES;
        if (self.viewControllers.count < 2) {
            _isPoping = NO;
            return nil;
        }
        if (_completionHandle) {
            _completionHandle();
        }
        TT_RELEASE_SAFELY(_completionHandle);
        
        if ([previousVC respondsToSelector:NSSelectorFromString(@"popFromControllerClass:")]) {
            [previousVC performSelector:NSSelectorFromString(@"popFromControllerClass:") withObject:currentVC.class];
        }

        [previousVC viewWillAppear:NO];
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
        [currentVC willMoveToParentViewController:nil];
        [currentVC.view removeFromSuperview];
        [self.view bringSubviewToFront:[self previousViewController].view];
        [currentVC removeFromParentViewController];
        [self.viewControllers removeObject:currentVC];
        [SNNotificationManager  postNotificationName:kPopViewControllerNotification object:nil];
        _animationInProgress = NO;
        [previousVC viewDidAppear:NO];

        if ([self.viewControllers count] >1) {
            [self addPanGestureToView:previousVC.view];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [self.delegate navigationController:self didShowViewController:previousVC animated:YES];
        }
        
        [self resetScrollToTop];
        _isPoping = NO;
    }

    return nil;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _animationInProgress = YES;
    
    if (self.viewControllers.count < 2) {
        return nil;
    }
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
    for (NSInteger i = index+1 ; i < self.viewControllers.count-1 ; i++) {
        UIViewController *vc = (UIViewController *)[self.viewControllers objectAtIndex:i];
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [arr addObject:vc];
    }
    [self.viewControllers removeObjectsInArray:arr];
    [SNNotificationManager  postNotificationName:kPopViewControllerNotification object:nil];
    [self popViewControllerAnimated:animated];
    
    return nil;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(SNNavigationControllerCompletionBlock)handler {
    _completionHandle = [handler copy];
    [handler release];
    return [self popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[self rootViewController] animated:animated];
}

#pragma mark - PushViewController With Completion Block
- (void) pushViewController:(UIViewController *)viewController completion:(SNNavigationControllerCompletionBlock)handler {
    if (_isPushing || _isPoping) {
        return;
    }
    _isPushing = YES;
    _animationInProgress = YES;
    viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _blackMask.alpha = 0.0;
    [self addChildViewController:viewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    if (self.viewControllers.count == 1) {
        UIViewController *rootViewController = (UIViewController *)[self.viewControllers objectAtIndex:0];
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [self.delegate navigationController:self willShowViewController:rootViewController animated:YES];
        }        
    }
    
    __block UIViewController *_oldCurrentViewController = [[self currentViewController] retain];
    [self.viewControllers addObject:viewController];
    
    [_oldCurrentViewController viewWillDisappear:NO];
    //YES代表动画执行开始，NO代表结束
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kSpreadAnimationStartKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //transiation animation
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kUseSpreadAnimationKey"]) {//SNS 狐友tab
        //push anmimation
        [UIView setAnimationsEnabled:YES];
        [UIView setAnimationDuration:kAnimationDuration];
        [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
#if kSimulateIOS7PushAnimation
            _oldCurrentViewController.view.frame = CGRectMake(kPushBackAnimationDistance, 0, CGRectGetWidth(_oldCurrentViewController.view.frame), CGRectGetHeight(_oldCurrentViewController.view.frame));
#else
            CGAffineTransform transf = CGAffineTransformIdentity;
            _oldCurrentViewController.view.transform = CGAffineTransformScale(transf, kUINavigationScale, kUINavigationScale);
#endif
            viewController.view.frame = self.view.bounds;
#if kSimulateIOS7PushAnimation
            _shadowMask.frame = CGRectMake(CGRectGetMinX(viewController.view.frame)-kShadowWidth, 0, kShadowWidth, CGRectGetHeight(viewController.view.frame));
#endif
            _blackMask.alpha = kMaxBlackMaskAlpha;
        }   completion:^(BOOL finished) {
            [_oldCurrentViewController viewDidDisappear:NO];
            
            if (self.onlyAnimation) {
                self.onlyAnimation = NO;
                [_oldCurrentViewController willMoveToParentViewController:nil];
                [_oldCurrentViewController.view removeFromSuperview];
                [_oldCurrentViewController removeFromParentViewController];
                [self.viewControllers removeObject:_oldCurrentViewController];
                [SNNotificationManager  postNotificationName:kPopViewControllerNotification object:nil];
            }
            
            viewController.view.frame = self.view.bounds;
            _animationInProgress = NO;
            [self addPanGestureToView:[self currentViewController].view];
            handler();
            [self resetScrollToTop];
            _isPushing = NO;
            TT_RELEASE_SAFELY(_oldCurrentViewController);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kSpreadAnimationStartKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
        }];
    }
    else {//中间展开动画打开        
        viewController.view.frame = self.view.bounds;
        
        CGFloat pointYInScreen = [[NSUserDefaults standardUserDefaults] doubleForKey:@"kRememberCellOriginYInScreen"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kRememberCellOriginYInScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect imageViewRect = CGRectMake(0, pointYInScreen - 10.0, screenWidth, 80.0);
        if (pointYInScreen == 0) {
            imageViewRect = CGRectMake(0, 270.0, screenWidth, 80.0);
        }
        UIImageView *frontImageView = [[[UIImageView alloc] initWithFrame:imageViewRect] autorelease];
        frontImageView.image = [self getScreenImageInView:viewController.view];
        viewController.view.hidden = YES;
        frontImageView.alpha = 0.95;
        frontImageView.clipsToBounds = YES;
        frontImageView.contentMode = UIViewContentModeCenter;
        
        [[UIApplication sharedApplication].keyWindow addSubview:frontImageView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kRecordNetWorkStatusKey"]) {
                [[UIApplication sharedApplication].keyWindow addSubview:self.animationImageView];
            }
            self.animationImageView.center = [UIApplication sharedApplication].keyWindow.center;
        });
        _oldCurrentViewController.view.userInteractionEnabled = NO;
        
        UIViewController *rootViewController = nil;
        if (self.viewControllers.count > 0) {
            rootViewController = (UIViewController *)[self.viewControllers objectAtIndex:0];
            rootViewController.view.userInteractionEnabled = NO;
        }
        
        [UIView setAnimationsEnabled:YES];
        [UIView setAnimationDuration:0.3];
        [UIView animateWithDuration:0.3 animations:^{
            frontImageView.alpha = 1.0;
            frontImageView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        } completion:^(BOOL finished1) {
            viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [frontImageView removeFromSuperview];
            [self.animationImageView removeFromSuperview];
            [self.animationImageView stopAnimating];
            viewController.view.hidden = NO;
            [_oldCurrentViewController viewDidDisappear:NO];
            _oldCurrentViewController.view.userInteractionEnabled = YES;
            rootViewController.view.userInteractionEnabled = YES;
            
            if (self.onlyAnimation) {
                self.onlyAnimation = NO;
                [_oldCurrentViewController willMoveToParentViewController:nil];
                [_oldCurrentViewController.view removeFromSuperview];
                [_oldCurrentViewController removeFromParentViewController];
                [self.viewControllers removeObject:_oldCurrentViewController];
                [SNNotificationManager  postNotificationName:kPopViewControllerNotification object:nil];
            }
            
            viewController.view.frame = self.view.bounds;
            _animationInProgress = NO;
            [self addPanGestureToView:[self currentViewController].view];
            handler();
            [self resetScrollToTop];
            _isPushing = NO;
            TT_RELEASE_SAFELY(_oldCurrentViewController);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kSpreadAnimationStartKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //避免动画随机性不消失
            [self.animationImageView removeFromSuperview];
            [self.animationImageView stopAnimating];
            rootViewController.view.userInteractionEnabled = YES;
        });
    }
    
    int deep = 0;
    
    for (NSInteger i = _viewControllers.count - 1; i >= 0; i--) {
        UIViewController *c = _viewControllers[i];
        
        deep++;
        
        if (deep > 3) {
            if ([c respondsToSelector:NSSelectorFromString(@"releaseMemory")]) {
                [c performSelector:NSSelectorFromString(@"releaseMemory")];
            }
        }
    }
}

- (UIImageView *)animationImageView {
    NSString *currentTheme = [[NSUserDefaults standardUserDefaults] objectForKey:@"kThemeSelectedKey"];
    NSString *imagePrefix = @"sohu_loading";
    if ([currentTheme isEqualToString:@"night"]) {
        imagePrefix = @"night_sohu_loading";
    }
    if (!_animationImageView) {
        UIImage *animationImage = [UIImage imageNamed:@"sohu_loading_1.png"];
        _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, animationImage.size.width, animationImage.size.height)];
    }
    NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 1; i < 39; i ++) {//共38帧
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%ld.png", imagePrefix, i]];
        if (image) [muArray addObject:image];
    }
    _animationImageView.animationImages = [NSArray arrayWithArray:muArray];
    _animationImageView.animationDuration = 0.5;
    _animationImageView.animationRepeatCount = 0;
    [_animationImageView startAnimating];
    
    return _animationImageView;
}

- (void) pushViewController:(UIViewController *)viewController {
    [SNNotificationManager  postNotificationName:kStopAudioNotification object:self];
    [SNNotificationManager  postNotificationName:kPushViewControllerNotification object:nil];
    [self pushViewController:viewController completion:^{}];
}

#pragma mark - PopViewController With Completion Block
- (void)popViewControllerWithCompletion:(SNNavigationControllerCompletionBlock)handler {
    if (self.viewControllers.count < 2) {
        _isPoping = NO;
        return;
    }
    
    _animationInProgress = YES;

    [SNNotificationManager  postNotificationName:kStopAudioNotification object:self];
    __block UIViewController *currentVC = [[self currentViewController] retain];
    __block UIViewController *previousVC = [[self previousViewController] retain];
    
//    /// 处理当前controller 的 statusbar 是隐藏状态时，上下页面的 statusbar 的处理
//    if (previousVC.prefersStatusBarHidden && ![currentVC isKindOfClass:[SNGalleryBrowserController class]]) {
//        [currentVC.view addSubview:self.currentControllerStatusBarShotView];
//        _hideStatusBarWhenPop = YES;
//        [self setNeedsStatusBarAppearanceUpdate];;
//    }
//    if (self.currentViewController.prefersStatusBarHidden
//        && !previousVC.prefersStatusBarHidden
//        && previousVC == self.rootViewController) {
//        [previousVC.view addSubview:self.preControllerStatusBarView];
//    }
    
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
#if kSimulateIOS7PushAnimation
        _shadowMask.frame = CGRectMake(CGRectGetMinX(currentVC.view.frame)-kShadowWidth, 0, kShadowWidth, CGRectGetHeight(currentVC.view.frame));
#endif
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        //lijian 2015.03.18 把这句话放在了动画结束后，否则影响回退时的效果，会卡顿
        [previousVC viewWillAppear:NO];
        if ([previousVC respondsToSelector:NSSelectorFromString(@"popFromControllerClass:")]) {
            [previousVC performSelector:NSSelectorFromString(@"popFromControllerClass:") withObject:currentVC.class];
        }
        
        [currentVC willMoveToParentViewController:nil];
        [currentVC.view removeFromSuperview];
        [self.view bringSubviewToFront:[self previousViewController].view];
        [currentVC removeFromParentViewController];
        if (![_viewControllers containsObject:currentVC]) {
            NSLog(@"当前pop的vc层级有问题，可能currentVC在另一个地方已经被pop了，或者当前真正想pop的不是currentVC而是previousVC");
        }
        [self.viewControllers removeObject:currentVC];
        [SNNotificationManager  postNotificationName:kPopViewControllerNotification object:nil];
        _animationInProgress = NO;
        
//        _hideStatusBarWhenPop = NO;
//        [self.currentControllerStatusBarShotView removeFromSuperview];
//        _currentControllerStatusbarView = nil;
//        [self.preControllerStatusBarView removeFromSuperview];
//        [self setNeedsStatusBarAppearanceUpdate];

        [previousVC viewDidAppear:NO];
    
        previousVC.view.frame = self.view.bounds;
        if ([self.viewControllers count] >1) {
            [self addPanGestureToView:previousVC.view];
        }
        handler();
        [self resetScrollToTop];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [self.delegate navigationController:self didShowViewController:previousVC animated:YES];
        }
        
        TT_RELEASE_SAFELY(currentVC);
        TT_RELEASE_SAFELY(previousVC);
    }];
    
}

- (void)popViewController {

    if (_isPoping || _isPushing) {
        return;
    }
    _isPoping = YES;
    [self popViewControllerWithCompletion:^{
        _isPoping = NO;
        if (_completionHandle) {
            _completionHandle();
        }
        TT_RELEASE_SAFELY(_completionHandle);
    }];
}

- (void) rollBackViewController {
    _animationInProgress = YES;
    
    UIViewController *vc = [self currentViewController];
    CGRect rect = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);

    [UIView animateWithDuration:0.2f delay:kAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
        vc.view.frame = rect;

#if kSimulateIOS7PushAnimation
        _shadowMask.frame = CGRectMake(CGRectGetMinX(vc.view.frame)-kShadowWidth, 0, kShadowWidth, CGRectGetHeight(vc.view.frame));
#else
        UIViewController * nvc = [self previousViewController];
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, kUINavigationScale, kUINavigationScale);
#endif
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
        } else {
#if !kSimulateIOS7PushAnimation
            nvc.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, kUINavigationScale, kUINavigationScale);
#endif
            vc.view.frame = rect;
            _blackMask.alpha = kMaxBlackMaskAlpha;
            _animationInProgress = NO;
        }
//        _hideStatusBarWhenPop = NO;
//        [self.currentControllerStatusBarShotView removeFromSuperview];
//        _currentControllerStatusbarView = nil;
//        [self.preControllerStatusBarView removeFromSuperview];
//        [self setNeedsStatusBarAppearanceUpdate];

        self.currentViewController.view.userInteractionEnabled = YES;
    }];
}
//- (UIView *)currentControllerStatusBarShotView {
//    if (!_currentControllerStatusbarView) {
//        _currentControllerStatusbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSystemBarHeight)];
//        UIView *snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
//        [_currentControllerStatusbarView addSubview:snapshotView];
//        [_currentControllerStatusbarView setClipsToBounds:YES];
//    }
//    return _currentControllerStatusbarView;
//}

//- (void)updateStatusBarShotView:(UIView *)statusBarView {
//    if (statusBarView) {
//        self.preControllerStatusBarView = statusBarView;
//    }else{
//        [self.preControllerStatusBarView removeFromSuperview];
//        self.preControllerStatusBarView = nil;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Simulate presentModalViewController
- (void)presentModalViewController:(UIViewController *)modalViewController needAnimated:(BOOL)animated {
    [self pushViewController:modalViewController animated:NO];
    
    if (animated) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:kAnimationDuration];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[modalViewController.view layer] addAnimation:animation forKey:@"simulatePresentModalAnimationWithPush"];
    }
}

- (void)dismissModalViewControllerWithAnimated:(BOOL)animated {
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        UIViewController *currentVC = [self currentViewController];
        currentVC.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
        _shadowMask.frame = CGRectZero;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self popViewControllerAnimated:NO];
    }];
}

//- (void)dismissSMSModalViewControllerWithAnimated:(BOOL)animated {
//    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        UIViewController *currentVC = [self currentViewController];
//        currentVC.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
//        _shadowMask.frame = CGRectZero;
//        _blackMask.alpha = 0.0;
//        [self popViewControllerAnimated:NO];
//    } completion:^(BOOL finished) {
//    }];
//}

#pragma mark - ChildViewController
- (UIViewController *)currentViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>0) {
        result = [self.viewControllers lastObject];
    }
    return result;
}

#pragma mark - ParentViewController
- (UIViewController *)previousViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    return result;
}

#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    if ([self.currentViewController needPanGesture]) {
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
        panGesture.cancelsTouchesInView = YES;
        panGesture.delegate = self;
        [view addGestureRecognizer:panGesture];
        [_gestures addObject:panGesture];
        [panGesture release];
    }
}

# pragma mark - Avoid Unwanted Vertical Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)panGestureRecognizer {
    if ([panGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    if (![self.currentViewController panGestureEnable]) {
        return NO;
    }
    if (panGestureRecognizer != panGesture || panGestureRecognizer.numberOfTouches > 1) {
        return NO;
    }
    CGPoint translation = [(UIPanGestureRecognizer *)panGestureRecognizer translationInView:self.view];
    BOOL result = fabs(translation.x) > fabs(translation.y) ;
    if (result) {
        
        /*
        UIViewController * vc = [self currentViewController];
        UIViewController *backViewController = [vc backToViewController];
        if (backViewController) {
            NSInteger index = [self.viewControllers indexOfObject:backViewController];
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
            for (int i = index+1 ; i < self.viewControllers.count-1; i++) {
                UIViewController *viewController = (UIViewController *)[self.viewControllers objectAtIndex:i];
                [viewController.view removeFromSuperview];
                [viewController removeFromParentViewController];
                [arr addObject:viewController];
            }
            [self.viewControllers removeObjectsInArray:arr];
        } 
        */
    }
    return result;
}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (touch.view == _blackMask || touch.view == _shadowMask) {
            return YES;
        }
        return NO;
    }
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    if (gestureRecognizer != panGesture || gestureRecognizer.numberOfTouches > 1) {
        return NO;
    }
    
    UIView *topView = [TTNavigator navigator].topViewController.view.subviews.lastObject;
    if ([topView isKindOfClass:NSClassFromString(@"SNUserRedPacketView")]) {
        if([touch.view isKindOfClass:[UIView class]])
            return NO;
    }
    
    UIViewController * vc = [self currentViewController];
    if ([vc respondsToSelector:NSSelectorFromString(@"currentController")]) {
        vc = [vc performSelector:NSSelectorFromString(@"currentController")];
    }
    // present modal 出来的controller  依然需要支持手势返回 暂且注释掉 by jojo
//    if (vc.modalViewController||vc.presentingViewController) {
//        return NO;
//    }
    
    if (![self.currentViewController shouldRecognizeGesture:gestureRecognizer withTouch:touch]) {
        return NO;
    }
    
    if (![self.currentViewController shouldRecognizerPanGesture:panGesture]) {
        return NO;
    }

    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return YES;
    }
    return [self.currentViewController recognizeSimultaneouslyWithGestureRecognizer];
}

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGestureRecognizer {
    if (![self.currentViewController isSupportPushBack]) {return;};
    if(_animationInProgress) return;
    if (panGesture != panGestureRecognizer) {
        return;
    }
    if (panGestureRecognizer.numberOfTouches > 1) {
        panGestureRecognizer.enabled = NO;
        panGestureRecognizer.enabled = YES;
        return;
    }
 
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.isPaningGusture = YES;
    } else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.isPaningGusture = NO;
    } else if(panGestureRecognizer.state == UIGestureRecognizerStateCancelled){
        self.isPaningGusture = NO;
    }
    
    /// 处理当前controller 的 statusbar 是隐藏状态时，上下页面的 statusbar 的处理
//    UIViewController *previousVC = [self previousViewController];
//    if (previousVC.prefersStatusBarHidden) {
//        [self.currentViewController.view addSubview:self.currentControllerStatusBarShotView];
//        _hideStatusBarWhenPop = YES;
//        [self setNeedsStatusBarAppearanceUpdate];;
//    }
//    if (self.currentViewController.prefersStatusBarHidden
//        && !previousVC.prefersStatusBarHidden
//        && previousVC == self.rootViewController) {
//        [previousVC.view addSubview:self.preControllerStatusBarView];
//    }
    
    self.currentViewController.view.userInteractionEnabled = NO;
    [SNNotificationManager  postNotificationName:kUIMenuControllerHideMenuNotification object:nil];
    
    CGPoint currentPoint = [panGestureRecognizer translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGestureRecognizer velocityInView:self.view];
    CGPoint traslation = [panGestureRecognizer translationInView:self.view];

    if (vel.x > 0) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    CGFloat offset = 0;
    
    UIViewController * vc = [self currentViewController];
    offset = CGRectGetWidth(vc.view.frame) - x;
    
    _percentageOffsetFromLeft = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    CGRect modifiedRect = [self getSlidingRectWithPercentageOffset:_percentageOffsetFromLeft orientation:self.interfaceOrientation];
    //@qz 调试代码
//    CGFloat oldHeight = vc.view.frame.size.height;
//    CGFloat oldY = vc.view.frame.origin.y;
//    CGFloat newHeight = modifiedRect.size.height;
//    CGFloat newY = modifiedRect.origin.y;
//    NSLog(@"%f --- %f ---- %f ---- %f",oldHeight,newHeight,oldY,newY);
//
//    if (oldHeight != newHeight) {
//        NSLog(@"%@",self.viewControllers);
//    }
    
    vc.view.frame = modifiedRect;
    [self transformAtPercentage:_percentageOffsetFromLeft];
    
    if (panGestureRecognizer.enabled == NO) {
        [self rollBackViewController];
        //self.currentViewController.view.userInteractionEnabled = YES;
        return;
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        // If velocity is greater than 100 the Execute the Completion base on pan direction
        //self.currentViewController.view.userInteractionEnabled = YES;
        if(fabs(vel.x) > 100 && fabs(vel.x) > fabs(vel.y) && traslation.x > 50) {
            [self completeSlidingAnimationWithDirection:panDirection];
        }else {
            [self completeSlidingAnimationWithOffset:offset];
        }
    }
}

//千帆直播用
- (BOOL)banPanGesture {
    return panGesture.enabled;
}

- (void)setBanPanGesture:(BOOL)ban {
    panGesture.enabled = ban;
}

//千帆直播调用，实现pangesture的target
- (void)slpaning:(CGPoint)touchPoint state:(UIGestureRecognizerState)state
{
    CGFloat offset = touchPoint.x - startTouch.x;
    CGFloat vwidth = [self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        startTouch = touchPoint;
        
    }else if (state == UIGestureRecognizerStateChanged){
        
        UIViewController * vc = [self currentViewController];
        
        CGFloat p = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
        
        vc.view.frame = [self getSlidingRectWithPercentageOffset:1-p orientation:self.interfaceOrientation];
        
        [self transformAtPercentage:1-p];
        
    }else{
        [self completeSlidingAnimationWithOffset:vwidth - offset];
    }
}

- (void)cancelAllTouch:(id)sender
{
    panGesture.enabled = NO;
    panGesture.enabled = YES;
}

#pragma mark - Set the required transformation based on percentage
- (void) transformAtPercentage:(CGFloat)percentage {
#if kSimulateIOS7PushAnimation
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    [self previousViewController].view.frame = CGRectMake(kPushBackAnimationDistance*percentage, 0, CGRectGetWidth([self previousViewController].view.frame), CGRectGetHeight([self previousViewController].view.frame));
    _blackMask.alpha = newAlphaValue;
    _shadowMask.frame = CGRectMake(_blackMask.frame.size.width*(1-percentage)-kShadowWidth, 0, kShadowWidth, CGRectGetHeight(_shadowMask.frame));
#else
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    [self previousViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
#endif
}

#pragma mark - This will complete the animation base on pan direction
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        
        if ([NSStringFromClass([self.viewControllers.lastObject class]) isEqualToString:@"SNCommonNewsController"])
        {
            //@qz 2017.3.25 滑动手势返回的埋点 我只加了正文页 SNCommonNewsController
            [SNNewsReport reportADotGif:@"_act=cc&fun=104"];
            
            SNCommonNewsController *viewController = (SNCommonNewsController *)self.viewControllers.lastObject;
            SHH5NewsWebViewController *h5ViewController = (SHH5NewsWebViewController *)viewController.currentController;
            if ([h5ViewController respondsToSelector:@selector(backViewController)]) {
                [h5ViewController backViewController];
            }
        } if ([NSStringFromClass([self.viewControllers.lastObject class]) isEqualToString:@"SHH5NewsWebViewController"]) {
            [SNNewsReport reportADotGif:@"_act=cc&fun=104"];
            
            SHH5NewsWebViewController *viewController = (SHH5NewsWebViewController *)self.viewControllers.lastObject;
            if ([viewController respondsToSelector:@selector(backViewController)]) {
                [viewController backViewController];
            }
        } else {
            [self popViewController];
        }
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - This will complete the animation base on offset
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset{
   
    if(offset<[self viewBoundsWithOrientation:self.interfaceOrientation].size.width/2) {
         [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - Get the origin and size of the visible viewcontrollers(child)
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation {
    CGRect viewRect = [self viewBoundsWithOrientation:orientation];
    CGRect rectToReturn = CGRectZero;
    rectToReturn.size = viewRect.size;
    rectToReturn.origin = CGPointMake(MAX(0,(1-percentage)*viewRect.size.width), 0.0);
    return rectToReturn;
}

#pragma mark - Get the size of view in the main screen
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation{
	CGRect bounds = [UIScreen mainScreen].bounds;
    if([[UIApplication sharedApplication]isStatusBarHidden]){
        return bounds;
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width +  kNavSystemBarHeight - 20.f;
        return bounds;
	}else{
        //bounds.size.height -= (20.f -  kNavSystemBarHeight);//这句是什么意思?
        //@qz 2017.10.25 手势右滑返回的时候 正文页toolbar下移的bug
        if([[UIDevice currentDevice] platformTypeForSohuNews] != UIDeviceiPhoneX){
            bounds.size.height -= ([UIApplication sharedApplication].statusBarFrame.size.height-20);
        }
        
        //NSLog(@"====%f",[UIApplication sharedApplication].statusBarFrame.size.height);
        return bounds;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topSubcontroller {
    return [self.viewControllers lastObject];
}

- (UIViewController *)rootViewController
{
    if ([self.viewControllers count] > 0) {
        return [self.viewControllers objectAtIndex:0];
    }
    return nil;
}

- (void)resetScrollToTop
{
    for (int index = 0; index < self.viewControllers.count -1; index++) {
        UIViewController *vc = (UIViewController *)[self.viewControllers objectAtIndex:index];
        [vc.view disableScrollToTopMeAndSubViews];
    }
    [self.currentViewController enableScrollToTop];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.view && self.view.superview == nil) {
        if ([self.parentViewController isKindOfClass:[UITabBarController class]]) {
            [self.parentViewController.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:NSClassFromString([NSString stringWithFormat:@"U%@ns%@iew", @"ITra", @"itionV"])]) {
                    [(UIView *)obj addSubview:self.view];
                    *stop = YES;
                }
            }];
        }
        else {
            [self.parentViewController.view addSubview:self.view];
        }
    }
}

//截取当前可视屏幕
- (UIImage *)getScreenImageInView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//wangshun 2017.5.5 许乾隆 千帆视频需要支持 (直播送星星)
#pragma mark -需要支持的方法！！！

- (UIViewController *)topViewController
{
    return [self.viewControllers lastObject];
}

- (UIViewController *)visibleViewController
{
    return [self.viewControllers lastObject];
}

- (BOOL)isNavigationBarHidden
{
    return YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    ///do nothing
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    ///
}


@end



#pragma mark - UIViewController Category
//For Global Access of flipViewController
@implementation UIViewController (SNNavigationController)
@dynamic flipboardNavigationController;

- (SNNavigationController *)flipboardNavigationController
{
    
    if([self.parentViewController isKindOfClass:[SNNavigationController class]]){
        return (SNNavigationController*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[SNNavigationController class]]){
        return (SNNavigationController*)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
    
}

- (UIViewController *)backToViewController
{
    return nil;
}

- (BOOL)needPanGesture
{
    return YES;
}

- (BOOL)panGestureEnable
{
    return YES;
}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    return NO;
}

- (BOOL)isSupportPushBack {
    return YES;
}

- (BOOL)shouldRecognizerPanGesture:(UIPanGestureRecognizer*)panGestureRecognizer {
    return YES;
}

- (BOOL)shouldRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer withTouch:(UITouch *)touch {
    return YES;
}

//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return nil;
}

- (void)enableScrollToTop
{
    
}

@end

@implementation UIView (scrollTop)

- (void)disableScrollToTopMeAndSubViews
{
    if ([self respondsToSelector:@selector(setScrollsToTop:)]) {
        [(UIScrollView *)self setScrollsToTop:NO];
    }
    
    for (UIView *view1 in self.subviews) {
        [view1 disableScrollToTopMeAndSubViews];
    }
}

@end

