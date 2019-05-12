//
//  SNCenterToastView.h
//  sohunews
//
//  Created by Scarlett on 16/8/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSNCenterToastHeight          (200.0 / 2)
//#define kSNCenterToastShowInterval    3.0
//#define kSNCenterToastMutiShowInterval    1.0

//typedef void(^SNCenterToastViewHideFinished)(id view);
typedef void(^SNCenterToastViewUrlButtonClicked)(void);
typedef void(^SNCenterToastViewCancelButtonClicked)(void);

@interface SNCenterToastView : UIView

@property (nonatomic, strong) NSString *iconImageName;
@property (nonatomic, strong) NSString *toastText;
@property (nonatomic, strong) NSString *toastUrl;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, assign) SNCenterToastMode toastMode;
//@property (nonatomic, copy)SNCenterToastViewHideFinished finishedBlock;
@property (nonatomic, copy)SNCenterToastViewUrlButtonClicked urlButtonClickedBlock;
@property (nonatomic, copy)SNCenterToastViewCancelButtonClicked cancelButtonClickedBlock;
@property (nonatomic, assign) BOOL toProfile;//是否跳转到profile页面
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, strong) UIView *targetView;

//- (void)show:(BOOL)animated;
//- (void)hide:(BOOL)animated;
//- (void)setUpToastActionButtonWithTitle:(NSString *)title;

- (void)showCenterToastWithMode:(SNCenterToastMode)mode;

- (void)hideLoadingToast;

- (void)showToastWithMode:(SNCenterToastMode)mode;
- (void)hideToast;

@end
