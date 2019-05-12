//
//  SNLoginRegisterViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNHeadSelectView.h"

#import "SNGuideRegisterManager.h"
#import "SNBindMobileNumViewController.h"
#import "SNWebViewManager.h"

//#import "SNNewsLoginSuccess.h"

@class SNLoginViewController;
@class SNRegisterViewController;
@class SNUserAccountService;
@class SNUserinfoService;

@interface SNLoginRegisterViewController : SNBaseViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate, SNHeadSelectViewDelegate, SNUserinfoServiceGetUserinfoDelegate>
{
    SNUserAccountService* _accountService;
    
    UIScrollView* _scrollView;
    SNLoginViewController* _loginViewController;
    SNRegisterViewController* _registerViewContronller;
    
    //下一步需要触发的操作回调，如果为空表示默认操作，即进入用户中心
    BOOL _needPop;
    BOOL _guideLogin; //引导登录
    id __weak _delegate;
    id _method;
    id _onBackMethod;
    id _object;
    
    SNGuideRegisterType _guideType;
    NSDictionary *_queryDictionary;
}
@property(nonatomic,strong) SNUserAccountService* accountService;
@property(nonatomic,strong) SNUserinfoService* userinfoService;
@property(nonatomic,strong) UIScrollView* _scrollView;
@property(nonatomic,strong) SNLoginViewController* _loginViewController;
@property(nonatomic,strong) SNRegisterViewController* _registerViewContronller;
@property(nonatomic,assign) SNGuideRegisterType _guideType;
@property(nonatomic, strong)SNBindMobileNumViewController *bindMobileNumViewController;
@property (nonatomic, strong)NSString *backURLString;

@property (nonatomic, strong)NSString *sourceID;

@property (nonatomic, assign) UniversalWebViewType webViewType;

@property(nonatomic, strong)NSString* commentBindOpen;//这个地方暂时这样
@property(nonatomic, weak)id commentpopvc;

@property(nonatomic,assign) BOOL _needPop;
@property(nonatomic,assign) BOOL _guideLogin;
@property(nonatomic,weak) id _delegate;
@property(nonatomic,strong) id _method;
@property(nonatomic,strong) id _onBackMethod;
@property(nonatomic,strong) id _object;
@property (nonatomic, strong) NSString *loginFrom;
@property(nonatomic,assign)BOOL isFromVideo;

//wangshun 2017.5.8
//@property(nonatomic, strong) SNNewsLoginSuccess *loginSuccessModel;

-(void)pushToProtocolWap;
@end

