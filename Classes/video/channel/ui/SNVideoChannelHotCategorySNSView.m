//
//  SNVideoChannelHotCategorySNSView.m
//  sohunews
//
//  Created by jojo on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelHotCategorySNSView.h"
#import "SNOauthWebViewController.h"
#import "SNUserManager.h"

@implementation SNVideoChannelHotCategorySNSView
@synthesize appId = _appId;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleDidLoginNotify:)
                                                     name:kUserDidLoginNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleLoginDidCloseNotify:)
                                                     name:kSNCommonWebViewControllerDidCloseNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleLoginDidCloseNotify:)
                                                     name:kSSOLoginDidCancelOrFailNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    // clean share manager delegate
    [[SNShareManager defaultManager] setDelegate:nil];
    [SNNotificationManager removeObserver:self];
    
     //(_appId);
    
     //(_bindBtn);
     //(_loadingView);
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bindBtn.centerY = CGRectGetMidY(self.bounds);
    _bindBtn.right = self.width - 5;
}

- (void)setCategoryObj:(SNVideoChannelCategoryObject *)categoryObj {
    [super setCategoryObj:categoryObj];
    
    // todo@jojo 需要根据某个服务器给的依据  判断是否已经绑定  这里目前通过title来判断
    BOOL hasBind = NO;
    NSString *appId = nil;
    
    if ([_categoryObj.title rangeOfString:@"新浪"].location != NSNotFound) {
        appId = @"1";
    }
    else if ([_categoryObj.title rangeOfString:@"腾讯"].location != NSNotFound) {
        appId = @"2";
    }
    else if ([_categoryObj.title rangeOfString:@"空间"].location != NSNotFound) {
        appId = @"6";
    }
    
    self.appId = appId;
    
    hasBind = [[SNShareManager defaultManager] isAppAuthrized:appId];
    
    if (!hasBind) {
        if (!_bindBtn) {
//            UIImage *btnImage = [UIImage imageNamed:@"share_list_bindBtn.png"];
            _bindBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//            _bindBtn.centerY = CGRectGetMidY(self.bounds);
//            _bindBtn.right = self.width - 5;
//            [_bindBtn setImage:btnImage forState:UIControlStateNormal];
            [_bindBtn addTarget:self action:@selector(actionBind:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_bindBtn];
        }
        _bindBtn.hidden = NO;
//        _subStatusIcon.hidden = YES;
    }
    else {
        _bindBtn.hidden = YES;
        _subStatusIcon.hidden = NO;
    }
    
    [self showLoading:NO];
}

#pragma mark - actions

//- (void)viewTappedAction:(id)sender {
//    if (_bindBtn.isHidden) {
//        [super viewTappedAction:sender];
//    }
//}

- (void)actionBind:(id)sender {
    
    [self showLoading:YES];
    _bindBtn.hidden = YES;
    _subStatusIcon.hidden = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(snsCategoryWillSub:)]) {
        [self.delegate snsCategoryWillSub:self];
    }
    
    BOOL isLogin = [SNUserManager isLogin];
    [[SNShareManager defaultManager] authrizeByAppId:self.appId loginType:isLogin ? SNShareManagerAuthLoginTypeBind : SNShareManagerAuthLoginTypeLoginWithBind delegate:self];
}

- (void)handleDidLoginNotify:(id)sender {
    // refresh ui
    self.categoryObj = self.categoryObj;
}

- (void)handleLoginDidCloseNotify:(id)sender {
    // refresh ui
    self.categoryObj = self.categoryObj;
}

#pragma mark - SNShareManagerDelegate

- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController {
    [[TTNavigator navigator].topViewController presentViewController:authNaviController animated:YES completion:nil];
}

- (void)shareManagerDidAuthSuccess:(SNShareManager *)manager {
    _bindBtn.hidden = YES;
    _subStatusIcon.hidden = NO;
    [self showLoading:NO];
    
    // 如果绑定成功 手动再关注一下相关的栏目
    if (!self.isSubed) {
        [self viewTappedAction:nil];
    }
}

- (void)shareManagerDidAuthAndLoginSuccess:(SNShareManager *)manager {
    _bindBtn.hidden = YES;
    _subStatusIcon.hidden = NO;
    [self showLoading:NO];

    // 如果绑定成功 手动再关注一下相关的栏目
    if (!self.isSubed) {
        [self viewTappedAction:nil];
    }
}

- (void)shareManagerDidCancelAuth:(SNShareManager *)manager {
    _bindBtn.hidden = NO;
//    _subStatusIcon.hidden = YES;
    [self showLoading:NO];
}

- (void)shareManager:(SNShareManager *)manager didAuthFailedWithError:(NSError *) error {
    _bindBtn.hidden = NO;
//    _subStatusIcon.hidden = YES;
    [self showLoading:NO];
}

- (BOOL)shareManagerShouldModalAuthViewController:(SNShareManager *)manager {
    return YES;
}

@end
