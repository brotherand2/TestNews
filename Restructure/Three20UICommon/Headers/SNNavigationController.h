//
//  SNNavigationController.h
//
//  Created by guoyalun on 8/7/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNNavigationControllerDelegate;

typedef void (^SNNavigationControllerCompletionBlock)(void);

@interface SNNavigationController : UIViewController

@property (nonatomic, assign) BOOL onlyAnimation;//判断是否push, 为YES时只显示动画，替换掉之前view
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, assign) id<SNNavigationControllerDelegate> delegate;
@property (nonatomic, assign) BOOL banPanGesture;//千帆直播用
@property (nonatomic, assign) BOOL isPaningGusture;//是否正在收拾滑动
@property (nonatomic, retain) UIImageView *animationImageView;

- (UIViewController *)currentViewController;
- (UIViewController *)previousViewController;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewNoMaskController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(SNNavigationControllerCompletionBlock)handler;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (void)banPanGesture:(BOOL)isBan;//千帆直播用
- (void)slpaning:(CGPoint)touchPoint state:(UIGestureRecognizerState)state;//千帆直播调用，实现pangesture的target
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
/**
 增加pop方法，主要增加了完成回调的block

 @param viewController 要pop到的指定控制器
 @param animated 是否动画
 @param handler 完成的回调
 @return NSArray
 */
- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated
                      completion:(SNNavigationControllerCompletionBlock)handler;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController completion:(SNNavigationControllerCompletionBlock)handler;
- (void)popViewController;
- (void)popViewControllerWithCompletion:(SNNavigationControllerCompletionBlock)handler;

- (void)updateStatusBarShotView:(UIView *)statusBarView;

#pragma mark - Simulate presentModalViewController
- (void)presentModalViewController:(UIViewController *)modalViewController
                      needAnimated:(BOOL)animated;
- (void)dismissModalViewControllerWithAnimated:(BOOL)animated;
- (BOOL)canContainControllers;
- (UIViewController*)topSubcontroller;
- (UIViewController *)rootViewController;
@end

@interface UIViewController (SNNavigationController)
@property (nonatomic, retain) SNNavigationController *flipboardNavigationController;
- (UIViewController *)backToViewController;
- (BOOL)needPanGesture;
- (BOOL)panGestureEnable;
- (BOOL)recognizeSimultaneouslyWithGestureRecognizer;
- (BOOL)isSupportPushBack;
- (BOOL)shouldRecognizerPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)enableScrollToTop;
- (BOOL)shouldRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer
                     withTouch:(UITouch *)touch;
- (UIViewController *)subChildViewControllerForStatusBarStyle;
@end

@protocol SNNavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(SNNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(SNNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface UIView (scrollTop)
- (void)disableScrollToTopMeAndSubViews;
@end
