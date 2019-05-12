//
//  SNStoryToast.m
//  sohunews
//
//  Created by chuanwenwang on 2016/11/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryToast.h"
#import "SNStoryToastView.h"
#import "SNStoryContanst.h"
#import "SNStoryUtility.h"
#import "UIViewAdditions+Story.h"

#define kToastBlockMaskViewTag      (2014)
#define kToastPointY                 20

static SNStoryToast *__instance = nil;

@interface SNStoryToast() {
    
}

@property (nonatomic, strong)__block NSMutableArray *viewArray;

@end

@implementation SNStoryToast

+ (SNStoryToast *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __instance = [[SNStoryToast alloc] init];
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
    }
    
    return self;
}

- (UIView*)rootView {

    UIWindow *_screenWindow = [UIApplication sharedApplication].keyWindow;
    UIView *msgSuperView = _screenWindow;
    if ([_screenWindow subviews].count > 0
        && [[_screenWindow subviews] objectAtIndex:0]) {
        msgSuperView = [[_screenWindow subviews] objectAtIndex:0];
    }
    
    return msgSuperView;
}


- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo showTime:(float)showTime rect:(CGRect)rect{
    UIView* targetView = [self rootView];
    if (targetView==nil) {
        return;
    }
    
    [self addToastToViewWithTitle:title toUrl:url userInfo:userInfo superView:targetView frame:rect toProfile:NO callBack:nil showTime:showTime];
}

- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url showTime:(float)showTime rect:(CGRect)rect{
    
    UIWindow *targetView = [UIApplication sharedApplication].keyWindow;
    
    if (targetView==nil) {
        return;
    }

    [self addToastToViewWithTitle:title toUrl:url userInfo:nil superView:targetView frame:rect toProfile:NO callBack:nil showTime:showTime];
    
}

- (void)showToastToSuperViewWithTitle:(NSString *)title toUrl:(NSString *)url showTime:(float)showTime rect:(CGRect)rect{
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIView* targetView = topController.view;
    
    if (targetView==nil) {
        return;
    }
    
    [self addToastToViewWithTitle:title toUrl:url userInfo:nil superView:targetView frame:rect toProfile:NO callBack:nil showTime:showTime];
}

- (void)showToastToTargetView:(UIView *)targetView title:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo showTime:(float)showTime rect:(CGRect)rect{
    
    if (targetView==nil) {
        return;
    }
    
    [self addToastToViewWithTitle:title toUrl:url userInfo:userInfo superView:targetView frame:rect toProfile:NO callBack:nil showTime:showTime];
}

- (void)hideToast {
    
    UIView *view = [[SNStoryUtility getAppDelegate].window viewWithTag:kToastBlockMaskViewTag];
    [view removeFromSuperview];
    
    if (self.viewArray.count > 0) {
        SNStoryToastView *showToast = (SNStoryToastView *)self.viewArray[0];
        [showToast hide:NO];
    }
    [self.viewArray removeAllObjects];
}

#pragma mark - private Method
- (void)addToastToViewWithTitle:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo superView:(UIView *)targetView frame:(CGRect)frame toProfile:(BOOL)toProfile callBack:(StoryToastViewUrlButtonClicked)callBack showTime:(float)showTime;

{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self) wself = self;
        SNStoryToastView *toastView = [[SNStoryToastView alloc] initWithFrame:frame];
        toastView.toastText = title;
        toastView.endInterval = showTime;
        toastView.toastUrl = url;
        toastView.userInfo = userInfo;
        toastView.toProfile = toProfile;
        toastView.urlButtonClickedblock = callBack;
        toastView.finishedBlock = ^(id view) {
            
            UIView *maskView = [[SNStoryUtility getAppDelegate].window viewWithTag:kToastBlockMaskViewTag];
            [maskView removeFromSuperview];
            
            if ([view isKindOfClass:[SNStoryToastView class]]) {
                [wself.viewArray removeObject:view];
            }
            if (wself.viewArray.count > 0) {
                SNStoryToastView *currentToast = (SNStoryToastView *)wself.viewArray[0];
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
            SNStoryToastView *preToast = (SNStoryToastView *)self.viewArray[count - 1];
            if ([preToast.toastText isEqualToString:toastView.toastText]) {
                return;
            }
            
            preToast.endInterval = showTime;
        }
        //当前toast加入队列
        if (self.viewArray) {
            [self.viewArray addObject:toastView];
        }
    });
}


@end
