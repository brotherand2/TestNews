//
//  SNSplashViewController.h
//  sohunews
//
//  Created by Dan on 8/13/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNViewController.h"
#import "SNActionMenuController.h"
#import "SNStopWatch.h"
#import "SNAppConfig.h"
#import "SNWebImageView.h"

typedef NS_ENUM(NSInteger, SNSplashViewRefer) {
    SNSplashViewReferAppLaunching                   = 0,
    SNSplashViewReferRollingNewsHorizontalSliding   = 1 << 0,
    SNSplashViewReferUserCenter                     = 1 << 1,
    SNSplashViewReferWillEnterForeground            = 1 << 2
};

@protocol SNSplashViewDelegate;
@interface SNSplashViewController : SNViewController <UIGestureRecognizerDelegate, SNActionMenuControllerDelegate> {
    BOOL isFlashing;
    BOOL enteredApp;
    BOOL subscribeBtnChecked;
    BOOL draggingLeft;
    BOOL isSplashDecelorating;
}

@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIImageView *shadowMask;
@property (nonatomic, strong) UIWindow *fullscreenWindow;
@property (nonatomic, strong) UIView *screenshotArea;
@property (nonatomic, strong) SNWebImageView *photoView;
@property (nonatomic, strong) UIView *contentCanvas;
@property (nonatomic, readonly, assign) BOOL isSplashDecelorating;
@property (nonatomic, assign) BOOL isFirstShow;
@property (nonatomic, assign) SNSplashViewRefer splashViewRefer;
@property (nonatomic, strong) UIViewController *windowModalViewController;
@property (nonatomic, weak) id<SNSplashViewDelegate> delegate;

- (id)initWithRefer:(SNSplashViewRefer)splashViewRefer delegate:(id<SNSplashViewDelegate>)delegate;
- (BOOL)isSplashViewVisible;
- (void)showSplashView;
- (void)enterApp;
- (void)showSplashViewWhenActive;
- (void)updateSettingsWithConfig:(SNAppConfig *)config;

@end

@protocol SNSplashViewDelegate <NSObject>
- (void)splashViewDidShow;
- (void)splashViewWillExit;
- (void)splashViewDidExit;

@end
