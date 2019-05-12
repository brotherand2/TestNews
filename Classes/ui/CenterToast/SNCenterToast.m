//
//  SNCenterToast.m
//  WebViewZoomDemo
//
//  Created by Scarlett on 16/8/23.
//  Copyright © 2016年 Scalett. All rights reserved.
//

#define SNMainThreadAssert() NSAssert([NSThread isMainThread], @"SNCenterToast needs to be accessed on the main thread.");

#import "SNCenterToast.h"
#import "SNCenterToastView.h"

@interface SNCenterToast (){
    SNCenterToastView *_loadingToastView;
}

@property (nonatomic,strong) SNCenterToastView* titleToastView;

@end

@implementation SNCenterToast

+ (SNCenterToast *)shareInstance {
    static SNCenterToast *toast = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toast = [[SNCenterToast alloc] init];
    });
    return toast;
}

- (void)showWithTitle:(NSString *)title{
    [self.titleToastView hideToast];
    self.titleToastView = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SNCenterToastView *toastView = [[SNCenterToastView alloc] init];
        toastView.verticalOffset = _verticalOffset;
        toastView.toastText = title;
        
//        toastView.toastUrl = toUrl;
//        toastView.userInfo = userinfo;
//        toastView.toProfile = toProfile;
//        toastView.urlButtonClickedBlock = callBack;
//        toastView.isFullScreen = isFullScreen;
//        toastView.targetView = targetView;
        
        [toastView showToastWithMode:SNCenterToastModeOnlyText];
        
        if (self.titleToastView != nil) {
            self.titleToastView = nil;
        }
        self.titleToastView = toastView;
        
        _verticalOffset = 0;
    });
}

- (void)hideToast{
    [self.titleToastView hideToast];
    self.titleToastView = nil;
}


- (void)showCenterToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNCenterToastMode)toastMode {
    [self addCenterToastToViewWithTitle:title toUrl:url userIfo:nil mode:toastMode toProfile:NO isFullScreen:NO targetView:nil callBack:nil];
}

- (void)showCenterToastWithTitle:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo mode:(SNCenterToastMode)toastMode {
    [self addCenterToastToViewWithTitle:title toUrl:url userIfo:userInfo mode:toastMode toProfile:NO isFullScreen:NO targetView:nil callBack:nil];
}

- (void)showCenterToastToFullScreenViewWithTitle:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo mode:(SNCenterToastMode)toastMode {
    [self addCenterToastToViewWithTitle:title toUrl:url userIfo:userInfo mode:toastMode toProfile:NO isFullScreen:YES targetView:nil callBack:nil];
}

- (void)showCenterToastToSuperViewWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNCenterToastMode)toastMode {
}

- (void)showBlockUIToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNCenterToastMode)toastMode {
}

- (void)showCenterToastToTargetView:(UIView *)targetView title:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo mode:(SNCenterToastMode)toastMode {
    [self addCenterToastToViewWithTitle:title toUrl:url userIfo:userInfo mode:toastMode toProfile:NO isFullScreen:NO targetView:targetView callBack:nil];
}

- (void)showCenterToastToProfileViewWithTitle:(NSString *)title toProfile:(BOOL)toProfile userInfo:(NSDictionary *)userInfo mode:(SNCenterToastMode)toastMode callBack:(void(^)(void))callBack {
    [self addCenterToastToViewWithTitle:title toUrl:nil userIfo:userInfo mode:toastMode toProfile:toProfile isFullScreen:NO targetView:nil callBack:callBack];
}

- (void)showCenterToastToProfileViewWithTitle:(NSString *)title toProfile:(BOOL)toProfile userInfo:(NSDictionary *)userInfo mode:(SNCenterToastMode)toastMode customButton:(NSString *)buttonTitle callBack:(void(^)(void))callBack {
}

- (void)addCenterToastToViewWithTitle:(NSString *)title toUrl:(NSString *)toUrl userIfo:(NSDictionary *)userinfo mode:(SNCenterToastMode)mode toProfile:(BOOL)toProfile isFullScreen:(BOOL)isFullScreen targetView:(UIView *)targetView callBack:(SNCenterToastViewUrlButtonClicked )callBack {
    if (mode == SNCenterToastModeError || mode == SNCenterToastModeWarning) {
        mode = SNCenterToastModeOnlyText;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SNCenterToastView *toastView = [[SNCenterToastView alloc] init];
        toastView.verticalOffset = _verticalOffset;
        toastView.toastText = title;
        toastView.toastUrl = toUrl;
        toastView.userInfo = userinfo;
        toastView.toProfile = toProfile;
        toastView.urlButtonClickedBlock = callBack;
        toastView.isFullScreen = isFullScreen;
        toastView.targetView = targetView;
        
        [toastView showCenterToastWithMode:mode];
        
        _verticalOffset = 0;
    });
}

- (void)showCenterLoadingToastWithTitle:(NSString *)title cancelButtonEvent:(void(^)(void))event
{
    SNMainThreadAssert()
    if (!_loadingToastView) {
        _loadingToastView = [[SNCenterToastView alloc] init];
        _loadingToastView.verticalOffset = _verticalOffset;
        _loadingToastView.toastUrl = nil;
        _loadingToastView.userInfo = nil;
        _loadingToastView.toProfile = NO;
        _loadingToastView.cancelButtonClickedBlock = event;
        _loadingToastView.isFullScreen = NO;
        _loadingToastView.targetView = nil;
        [_loadingToastView showCenterToastWithMode:SNCenterToastModeLoading];
        _verticalOffset = 0;
    }
    _loadingToastView.toastText = title;
}

- (void)hideCenterLoadingToast {
    SNMainThreadAssert()
    if (_loadingToastView) {
        [_loadingToastView hideLoadingToast];
        _loadingToastView = nil;
    }
}

@end
