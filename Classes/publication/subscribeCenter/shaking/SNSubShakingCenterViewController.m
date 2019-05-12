//
//  SNSubShakingCenterViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-23.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubShakingCenter.h"
#import "SNSubShakingCenterViewController.h"
#import "SNSubShakingImagesViewController.h"
#import "SNSubShakingButtonViewController.h"
#import "SNSubShakingAnimateViewController.h"
#import "SNSubShakingItemView.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"
#import "SNGuideRegisterManager.h"
#import "SNGuideRegisterViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SNToast.h"


@interface SNSubShakingCenterViewController()
-(void)createImagesView;
-(void)createButtonView;
-(void)createShakingView;
-(void)showAnimationView:(BOOL)aStart;
-(void)customerBg;
@end


@implementation SNSubShakingCenterViewController
@synthesize _shakingCenter;
@synthesize _networdSubArray;
@synthesize _imagesViewController;
@synthesize _buttonViewController;
@synthesize _animateViewController;
@synthesize _shakingManager;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)dealloc
{
    [_shakingManager removeListener:self];
    
    SNLocationManager* location = [SNLocationManager GetInstance];
    [location removeListener:self];
    
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        if (query) {
            self.queryDic = [NSMutableDictionary dictionaryWithDictionary:query];
        }
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self._shakingCenter = nil;
        _shakingCenter = [[SNSubShakingCenter alloc] init];
        _shakingCenter._SubShakingCenterDelegate = self;
        self._shakingManager = nil;
        _shakingManager = [[SNShakingManager alloc] init];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_yiy;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

-(void)loadView
{
    [super loadView];
    
    [self createImagesView];
    [self createButtonView];
    [self createShakingView];
    
    [self addHeaderView];
    [self createHeaderViewTopRight:self.headerView];
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"shaking_title", nil), nil]];
    self.headerView.delegate = self;
    
    [self.toolbarView removeFromSuperview];
    [self addToolbar];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self customerBg];
    
    //add location manager
    CGPoint pt;
    SNLocationManager* location = [SNLocationManager GetInstance];
    [location addListener:self];
    [location startLocating:&pt];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self showAnimationView:NO];
    
    //reset
    _shakingCenter._SubShakingCenterDelegate = self;
    
    //add2ShakingListener
    [_shakingManager addListener:self];

    //进入摇一摇界面，需要的话(后台没有音乐在播放)进入音乐模式
    [_shakingManager audioSetActiveIfNeeded];
    
    //刷新 夜间模式
    [_imagesViewController viewWillAppear:animated];
    [_buttonViewController viewWillAppear:animated];
    [_animateViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self onViewDidAppear];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)onViewDidAppear {
    // 什么也不做 就给登陆拦截一个机会去做拦截
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SNNotificationCenter hideLoading];
    [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
    [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
    
    //remove from shakingListener
    [_shakingManager removeListener:self];
    
    if(_shakingCenter!=nil)
        [_shakingCenter clearRequestAndDelegate];
    
    if(_animateViewController!=nil)
       [_animateViewController viewWillDisappear:animated];
    
    //关闭音乐模式
    [_shakingManager audioSetDeActive];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)notifyShaking:(BOOL)aSoundAndShaking
{
    if(_animateViewController.view.hidden) //当前展示页处于前台，动画页在后面
    {
        if(aSoundAndShaking)
        {
            [_shakingManager playMp3];
            [_shakingManager playShaking];
        }
        [self showAnimationView:YES];
    }
    else if(!_animateViewController._animationOpen) //动画页在前面，但是已经停止了
    {
        if(aSoundAndShaking)
        {
            [_shakingManager playMp3];
            [_shakingManager playShaking];
        }
        [self showAnimationView:YES];
    }
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- location回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

/*
-(void)notifyLocation:(CGPoint)aLocation
{
    SNDebugLog(@"SNLocationManagerDelegate notifyLocation %f %f", aLocation.x, aLocation.y);
}

-(void)notifyFailWithError:(NSError*)aError
{
    SNDebugLog([aError description]);
}

-(void)notifyCanceled
{
    SNDebugLog(@"SNLocationManagerDelegate notifyCanceled!");
}*/


//----------------------------------------------------------------------------------------------
//------------------------------------------- 网络回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)notifySubRecomSuccess
{
    SNDebugLog(@"notifySubRecomSuccess");
    [self showSubinfoIfReady];
}

-(void)notifySubRecomFailure;
{
    SNDebugLog(@"notifySubRecomFailure");
    _subFailure = YES;
    [self showSubinfoIfReady];
}

-(void)notifySubRecomRequestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifySubRecomRequestFailure");
    _subRequestFailure = YES;
    [self showSubinfoIfReady];
}

//订阅中心统一的数据回调
-(void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet*)dataSet
{
    SNDebugLog(@"didFinishLoadDataWithDataSet");
    
    if(dataSet!=nil)
    {
        if(dataSet.operation==SCServiceOperationTypeAddOrRemoveMySubsToServer)
        {
            [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
            
            if(!_defaultPush && [_buttonViewController ischecking]) //默认非订阅但是用户已经勾选
            {
                for(NSInteger i=0; i<[_networdSubArray count]; i++)
                {
                    SCSubscribeObject* obj = (SCSubscribeObject*)[_networdSubArray objectAtIndex:i];
                    obj.isPush = @"1";
                }
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
                [[SNSubscribeCenterService defaultService] synchronizeMySubsPushToServerBySubObjects:_networdSubArray];
            }
            else if(_defaultPush && ![_buttonViewController ischecking]) //默认订阅但是用户没有勾选
            {
                for(NSInteger i=0; i<[_networdSubArray count]; i++)
                {
                    SCSubscribeObject* obj = (SCSubscribeObject*)[_networdSubArray objectAtIndex:i];
                    obj.isPush = @"0";
                }
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
                [[SNSubscribeCenterService defaultService] synchronizeMySubsPushToServerBySubObjects:_networdSubArray];
            }
            else //不需要做push同步
            {
                [SNNotificationCenter hideLoading];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"shaking_shake_sub_success", nil), [self._networdSubArray count]] toUrl:nil mode:SNCenterToastModeSuccess];
                [self showAnimationView:NO];
                self._networdSubArray = nil;
            }
        }
        else if(dataSet.operation==SCServiceOperationTypeSynchronizeMySubsPushArray)
        {
            [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
            
            [SNNotificationCenter hideLoading];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"shaking_shake_sub_success", nil), [self._networdSubArray count]] toUrl:nil mode:SNCenterToastModeSuccess];
            [self showAnimationView:NO];
            self._networdSubArray = nil;
        }
    }
    else
    {
        SNDebugLog(@"didFinishLoadDataWithDataSet is null!!!");
        [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
        [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
        
        [SNNotificationCenter hideLoading];
        self._networdSubArray = nil;
    }
}

-(void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet*)dataSet
{
    SNDebugLog(@"didFailLoadDataWithDataSet");
    self._networdSubArray = nil;
    [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
    [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
    [SNNotificationCenter hideLoading];
    
    if(dataSet!=nil)
    {
        if(dataSet.operation==SCServiceOperationTypeAddOrRemoveMySubsToServer)
        {
            if(dataSet.lastError!=nil && dataSet.lastError.domain!=nil && [dataSet.lastError.domain length]>0)
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"shaking_shake_sub_fail",@"") toUrl:nil mode:SNCenterToastModeWarning];
        }
        else if(dataSet.operation==SCServiceOperationTypeSynchronizeMySubsPushArray)
        {
            if(dataSet.lastError!=nil && dataSet.lastError.domain!=nil && [dataSet.lastError.domain length]>0)
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"shaking_shake_sub_fail",@"") toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

-(void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet*)dataSet
{
    SNDebugLog(@"didCancelLoadDataWithDataSet");
    self._networdSubArray = nil;
    [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
    [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeSynchronizeMySubsPushArray];
    
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error",@"") toUrl:nil mode:SNCenterToastModeError];
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)customerBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

-(void)submitHangout:(id)sender
{
    [SNNotificationCenter hideLoading];
    //[self.navigationController popViewControllerAnimated:YES];
    
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:SUBSCRIBE_CENTER_URL_ACTION] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:urlAction];
}

-(void)submitSubnow:(id)sender
{
    self._networdSubArray = [NSMutableArray arrayWithCapacity:0];
    if(_imagesViewController!=nil && _imagesViewController._imagesArray!=nil && [_imagesViewController._imagesArray count]>0)
    {
        for(NSInteger i=0; i<[_imagesViewController._imagesArray count]; i++)
        {
            SNSubShakingItemView* itemView = (SNSubShakingItemView*)[_imagesViewController._imagesArray objectAtIndex:i];
            if(itemView!=nil && itemView._checked && itemView._dataObject!=nil)
            {
                SCSubscribeObject* obj = itemView._dataObject;
                obj.from = REFER_SHAKE;
                _defaultPush = (obj.isPush!=nil && [obj.isPush isEqualToString:@"1"]);
                [_networdSubArray addObject:itemView._dataObject];
            }
        }
    }
    
    if([_networdSubArray count]>0)
    {
        for (SCSubscribeObject *subObj in _networdSubArray) {
            if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:subObj]) {
                [SNGuideRegisterManager showGuideWithSubId:subObj.subId];
                return;
            }
        }
        [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer];
        [[SNSubscribeCenterService defaultService] addAndRemoveMySubsToServerWithAddObjs:_networdSubArray removeObjs:nil];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"shaking_shake_none",@"") toUrl:nil mode:SNCenterToastModeWarning];
    }
}

-(void)createHeaderViewTopRight:(UIView*)aHeaderView
{
    UIColor* itemLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingItemLabelColor]];
    
    //文字提示
    CGRect subRect = CGRectMake(180, 14 + kSystemBarHeight, 90, 20);
    UILabel* tipLabel = [[UILabel alloc] initWithFrame:subRect];
    tipLabel.tag = 102;
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = itemLabelColor;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.userInteractionEnabled = YES;
    tipLabel.text = NSLocalizedString(@"shaking_tip", nil);
    [aHeaderView addSubview:tipLabel];
    
    //摇晃图片
    subRect = CGRectMake(279, 10 + kSystemBarHeight, 29.5, 25);
    UIImage* image = [UIImage imageNamed:@"shaking_small_image.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:subRect];
    imageView.tag = 101;
    imageView.image = image;
    [aHeaderView addSubview:imageView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [tipLabel addGestureRecognizer:tap];
}

-(void)viewTaped:(id)sender
{
    if ([SNPreference sharedInstance].debugModeEnabled) {
        [self notifyShaking:YES];
    }
}

-(void)createImagesView
{
    self._imagesViewController = nil;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    _imagesViewController = [[SNSubShakingImagesViewController alloc] init];
    _imagesViewController._subViewController = self;
    _imagesViewController.view.frame = CGRectMake(0, kHeaderHeightWithoutBottom,screenFrame.size.width,
                                                 268);
    
	[self.view addSubview:_imagesViewController.view];
}

-(void)createButtonView
{
    self._buttonViewController = nil;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    _buttonViewController = [[SNSubShakingButtonViewController alloc] init];
    _buttonViewController._subViewController = self;
    _buttonViewController.view.frame = CGRectMake(0, kHeaderHeightWithoutBottom + 268,screenFrame.size.width,
                                                  118);
    
	[self.view addSubview:_buttonViewController.view];
}

-(void)createShakingView
{
    self._animateViewController = nil;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    _animateViewController = [[SNSubShakingAnimateViewController alloc] init];
    _animateViewController._subViewController = self;
    _animateViewController.view.frame = CGRectMake(0, kHeaderHeightWithoutBottom ,screenFrame.size.width,
                                                  screenFrame.size.height-kToolbarHeight+7);
    
	[self.view addSubview:_animateViewController.view];
}

-(void)showAnimationView:(BOOL)aStart
{
    _subFailure = NO;
    _subRequestFailure = NO;
    
    BOOL imagesViewReady = (_imagesViewController._animationShowingCount == 0); //飞入动画是否已经执行完毕
    if(aStart && imagesViewReady && !_animateViewController._animationOpen && !_animateViewController._animationWillStop)
    {
        _imagesViewController.view.hidden = YES;
        _buttonViewController.view.hidden = YES;
        _animateViewController.view.hidden = NO;
        [_animateViewController startAnimation];
        
        if(_shakingCenter!=nil)
            [_shakingCenter clearDataAndRequest];
    }
    else if(imagesViewReady && !_animateViewController._animationOpen && !_animateViewController._animationWillStop)
    {
        _imagesViewController.view.hidden = YES;
        _buttonViewController.view.hidden = YES;
        _animateViewController.view.hidden = NO;
        [_animateViewController startGuideAnimation];
    }
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)showSubinfoIfReady
{
    if(_animateViewController._animationReady && [_shakingCenter._SubArray count]>0) //成功:数据取到+计时器到时
    {
        _subFailure = NO;
        _subRequestFailure = NO;
        
        //Images
        _imagesViewController.view.hidden = NO;
        [_imagesViewController setItemsByArray:_shakingCenter._SubArray];
        //注意：使用完整数据再清空 并且触发再次取数据操作
        //[_shakingCenter clearDataAndRequest];
        [_shakingCenter._SubArray removeAllObjects];
        //Button view
        _buttonViewController.view.hidden = NO;
        [_buttonViewController appearWithAnimation];
        //Animate view
        _animateViewController.view.hidden = YES;
        [_animateViewController stopAnimation:0];
        
    }
    else if(_animateViewController._animationReady && _subFailure) //取到的数据长度为0
    {
        _subFailure = NO;
        _subRequestFailure = NO;
        [_animateViewController stopAnimation:2];
    }
    else if(_animateViewController._animationReady && _subRequestFailure) //http超时
    {
        _subFailure = NO;
        _subRequestFailure = NO;
        [_animateViewController stopAnimation:1];
    }
    else //计时器是时间还没到
    {
        SNDebugLog(@"showSubinfoIfReady 计时器是时间还没到");
    }
}

- (void)updateTheme:(NSNotification*)notifiction
{
    [super updateTheme:notifiction];
    
    UIColor* itemLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingItemLabelColor]];
    
    //文字提示
    UILabel* tipLabel = (UILabel*)[self.headerView viewWithTag:102];
    tipLabel.textColor = itemLabelColor;
    tipLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView* imageView = (UIImageView*)[self.headerView viewWithTag:101];
    UIImage* itemImage = [UIImage imageNamed:@"shaking_small_image.png"];
    imageView.image = itemImage;

    [self customerBg];
}

- (void)onBack:(id)sender
{
    NSArray* array = self.flipboardNavigationController.viewControllers;
    [SNGuideRegisterManager popGuideRegisterController:array popController:self];
    [super onBack:sender];
}

@end
