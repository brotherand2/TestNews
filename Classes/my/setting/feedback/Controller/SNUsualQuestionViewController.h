//
//  SNUsualQuestionViewController.h
//  UserFeedBack
//
//  Created by 李腾 on 2016/10/2.
//  Copyright © 2016年 suhu. All rights reserved.
//



#import "SHWebView.h"

@protocol UsualQuestionViewControllerDelegate <NSObject>

@optional
- (void)gotoFeedBack;

@end

@interface SNUsualQuestionViewController : SNBaseViewController
@property (nonatomic, strong) SHWebView *webView;
@property (nonatomic, assign) BOOL isUserComment;
@property (nonatomic, strong) NSString *backUrl;

@property (nonatomic, weak) id<UsualQuestionViewControllerDelegate> delegate;

- (void)stopLoadingAnimation;

- (void)showErrorAnimationView;
//执行H5下拉刷新
- (void)h5Refresh;

@end
