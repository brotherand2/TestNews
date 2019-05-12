//
//  SNSoHuAccountLoginRegisterViewController.h
//  sohunews
//
//  Created by yangln on 14-10-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//


#import "SNHeadSelectView.h"
#import "SNGuideRegisterManager.h"
#import "SNNewsLoginSuccess.h"

@class SNRegisterViewController;
@class SNUserAccountService;
@class SNUserinfoService;
@class SNSoHuAccountLoginViewController;

@interface SNSoHuAccountLoginRegisterViewController : SNBaseViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate, SNHeadSelectViewDelegate> {
    SNGuideRegisterType _guideType;
    UIImageView *_topLineImageView;
    NSDictionary *_queryDictionary;
}

@property(nonatomic, strong) SNSoHuAccountLoginViewController *accountLoginViewController;
@property(nonatomic, strong) SNRegisterViewController *registerViewContronller;
@property(nonatomic, strong) SNUserAccountService* accountService;
@property(nonatomic, strong) SNUserinfoService* userinfoService;
@property(nonatomic, strong) UIScrollView* scrollView;
@property(nonatomic, strong) NSDictionary* queryDictionary;
@property(nonatomic, assign) BOOL needPop;
@property(nonatomic, weak) id delegate;
@property(nonatomic, strong) id method;
@property(nonatomic, strong) id onBackMethod;
@property(nonatomic, strong) id object;
@property(nonatomic, assign) BOOL isFromVideo;

@property(nonatomic, strong) NSString* sourceID;


@property (nonatomic, strong) SNNewsLoginSuccess* loginSuccessModel;

@property(nonatomic, strong)NSString* commentBindOpen;//这个地方先这样 wangshun  评论回调
@property(nonatomic, weak)id commentpopvc;


-(void)pushToProtocolWap;
-(void)setToolBarOrigin;

@end
