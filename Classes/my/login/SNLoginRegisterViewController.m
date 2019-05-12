//
//  SNLoginRegisterViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLoginViewController.h"
#import "SNRegisterViewController.h"
#import "SNLoginRegisterViewController.h"
#import "SNUserAccountService.h"
#import "SNUserinfoService.h"
#import "SNMyFavouriteManager.h"
#import "SNTimelinePostService.h"
#import "SNTimelineObjects.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"
#import "SNInterceptConfigManager.h"

#import "SNActionSheetLoginManager.h"
//#import "JKNotificationCenter.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNSLib.h"
#import "SNNewMeViewController.h"
#import "SNBaseWebViewController.h"


@interface SNLoginRegisterViewController ()<SNLoginViewControllerDataSource,SNBindMobileNumViewControllerDelegate>{
    BOOL _loginMsgFromShareSns;
}

@property (nonatomic, strong)NSString *pid;
@property (nonatomic, strong)NSString *link;
@property (nonatomic, strong)NSString *newsId;
@property (nonatomic, strong)NSString *channelId;
@property (nonatomic, strong)NSString *vid;
@property (nonatomic, strong)NSString *reportType;
@property (nonatomic, strong)NSString *actId;
@property (nonatomic, strong)NSString *url;
@property (nonatomic, assign)int hasApproval;
@property(nonatomic, copy) NSString *subId;
@property(nonatomic, strong)SNBaseFavouriteObject *favouriteObject;





-(void)createLoginView;
//-(void)createRegisterView;
@end

@implementation SNLoginRegisterViewController
@synthesize userinfoService = _userinfoService;
@synthesize accountService = _accountService;
@synthesize _scrollView;
@synthesize _loginViewController;
@synthesize _registerViewContronller;
@synthesize _delegate,_method,_object;
@synthesize _onBackMethod;
@synthesize _needPop;
@synthesize _guideLogin;
@synthesize _guideType;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)dealloc
{
    [SNNotificationManager removeObserver:self];
    [self.headerView resignOffsetListener];
    [_accountService clearRequestAndDelegate];
     //(_bindMobileNumViewController);
     //(_queryDictionary);
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        _userinfoService = [[SNUserinfoService alloc] init];
        _accountService = [[SNUserAccountService alloc] init];
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if(self)
    {
        [SNUtility registerSharePlatform];
        if(query!=nil)
        {
            self.isFromVideo = NO;
            _queryDictionary = query;
            self._delegate = [query objectForKey:@"delegate"];
//            self._delegate = self;
            self._method = [query objectForKey:@"method"];
            self._onBackMethod = [query objectForKey:@"onBackMethod"];
            self._object = [query objectForKey:@"object"];
            self._needPop = [(NSNumber*)[query objectForKey:@"needpop"] boolValue];
            self._guideLogin = [(NSNumber*)[query objectForKey:@"guidelogin"] boolValue];
            NSNumber *type = [query objectForKey:kRegisterInfoKeyGuideType];
            _guideType = [type intValue];
            self.backURLString = [query objectForKey:kRegisterInfoKeyBackUrl];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_guideType] forKey:kRegisterInfoKeyGuideType];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.subId = [query stringValueForKey:kRegisterInfoKeySubId defaultValue:nil];
            self.pid = [query objectForKey:kRegisterInfoKeyUserPid];
            self.link = [query objectForKey:kRegisterInfoKeyUserLink];
            self.favouriteObject = [query objectForKey:kRegisterInfoKeyFavObject];
            self.newsId = [query objectForKey:kRegisterInfoKeyNewsId];
            self.channelId = [query objectForKey:kRegisterInfoKeyChannelId];
            self.actId = [query objectForKey:kRegisterInfoKeyActId];
            self.hasApproval = [query intValueForKey:kRegisterInfoKeyApprovalType defaultValue:0];
            self.loginFrom = [query objectForKey:kLoginFromKey];
            self.vid = [query objectForKey:@"vid"];
            self.reportType = [query objectForKey:@"type"];
            self.url  = [query objectForKey:@"url"];
            self.webViewType = [[query stringValueForKey:kUniversalWebViewType defaultValue:@""] integerValue];
            
            self.commentBindOpen = [query objectForKey:@"commentBindOpen"];
            self.commentpopvc    = [query objectForKey:@"commentpopvc"];
            
//            self.loginSuccessModel= [query objectForKey:@"loginSuccess"];
        }
        [SNNotificationManager addObserver: self selector: @selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
        [SNNotificationManager addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(verifyCodeAndMobileNumClick) name:kVerifyCodeAndMobileNumClickNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(mobileNumLoginSucceed) name:kMobileNumLoginSucceedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(verifyCodeAndMobileNumClick) name:kViewTapedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleApplicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}

- (SNCCPVPage)currentPage {
    return login_sohu;
}

- (void)loadView
{
    [super loadView];
    
//    CGRect screenFrame = TTApplicationFrame();
//    
//    self._scrollView = nil;
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7)];
//    _scrollView.contentSize = CGSizeMake(screenFrame.size.width, 0);
//    _scrollView.pagingEnabled = YES;
//    _scrollView.bounces = NO;
//    _scrollView.delegate = self;
//    _scrollView.showsHorizontalScrollIndicator = NO;
//    [self.view addSubview:_scrollView];
//    
//    [self createLoginView];
////    [self createRegisterView];
//
//    [self addHeaderView];
//    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"user_info_login", nil), nil]];
//    self.headerView.delegate = self;
//    [self.headerView registerOffsetListener:_scrollView];
//    CGSize titleSize = [NSLocalizedString(@"user_info_login", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
//    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
//    
//    [self.toolbarView removeFromSuperview];
//    [self addToolbar];
    
//    if (SYSTEM_VERSION_LESS_THAN(@"7"))
//    {
//        if ([UIApplication sharedApplication].statusBarHidden)
//        {
//            _headerView.top += 20.f;
//            _scrollView.top += 20.f;
//            _toolbarView.bottom += 20.f;
//        }
//    }
//    [self addSwipeGesture];
}

- (void)doBack {
    if(_delegate!=nil && _onBackMethod!=nil && [_onBackMethod isKindOfClass:[NSValue class]] && [_delegate respondsToSelector:[_onBackMethod pointerValue]])
        [_delegate performSelector:[_onBackMethod pointerValue] withObject:nil afterDelay:0.5f];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self doBack];
    }
}

- (void)bury:(NSString*)type{
    //wechat sina qq sohu
//    NSDictionary* dic = @{@"loginSuccess":@"2",@"cid":[SNUserManager getP1],@"errType":@"0"};
//    NSString* sourceChannelID = self.loginSuccessModel.sourceChannelID?:self.sourceID;
//    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
//        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
//    }
}

-(void)onBack:(id)sender
{
    //取消登录 wangshun
    [self bury:nil];
    [_bindMobileNumViewController.loginView setResignFirstResponder];
    if (_guideType == SNGuideRegisterTypeBackToUrl) {
        NSArray *viewControllers = self.flipboardNavigationController.viewControllers;
        if ([viewControllers count] > 0) {
            if ([[viewControllers objectAtIndex:0] isKindOfClass:[SNNewMeViewController class]]) {
                if (viewControllers.count>2) {
                    UIViewController* vc = [viewControllers objectAtIndex:1];
                    if ([vc isKindOfClass:[SNBaseWebViewController class]]) {
                        SNBaseWebViewController* webvc = (SNBaseWebViewController*)vc;
                        NSString* link = [webvc valueForKey:@"newsOriginLink"];
                        if ([link containsString:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html"]) {//如果是用户画像的登录 不返回 wangshun
                            [self.flipboardNavigationController popViewControllerAnimated:YES];
                            return;
                        }
                    }
                }
                [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
            }
            else {
                [self.flipboardNavigationController popViewControllerAnimated:YES];
            }
        }
    }else{
        [super onBack:sender];
        [self doBack];
        if (!self.flipboardNavigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [SNNotificationManager addObserver:self selector:@selector(weiboLoginMsgFromShareSNS) name:kLoginMsgFromShareToSNSNotification object:nil];
    _loginMsgFromShareSns = NO;
    
//    NSString* sourceChannelID = self.loginSuccessModel.sourceChannelID?:self.sourceID;
//    NSDictionary* dic = @{@"loginSuccess":@"0",@"cid":[SNUserManager getP1]};
//    SNDebugLog(@"sourceID:%@,dic:%@",sourceChannelID,dic);
//    [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
}

- (void)weiboLoginMsgFromShareSNS {
    _loginMsgFromShareSns = YES;
}


- (void)viewDidUnload {
    [self.headerView resignOffsetListener];
    self._scrollView = nil;
    self._loginViewController = nil;
    self._registerViewContronller = nil;

    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat orginY = kHeaderHeightWithoutBottom;
    if (_queryDictionary[@"fromType"] && [_queryDictionary[@"fromType"] isEqualToString:@"video_report"]) {
        if (nil == self.flipboardNavigationController) {
            orginY = kHeaderHeight;
        }
    }
    [_loginViewController.view setOrigin:CGPointMake(_loginViewController.view.origin.x, orginY)];
    [_loginViewController viewWillAppear:animated];
    [_registerViewContronller viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_loginViewController viewDidAppear:animated];
    [_registerViewContronller viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [SNNotificationCenter hideLoading];
    [self resetToolBarOrigin];
    [SNNotificationManager removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    
    CGRect frame = TTApplicationFrame();
    int index = scrollView.contentOffset.x / frame.size.width;
    [self.headerView setCurrentIndex:index animated:YES];
    
//    if(index==1)
//        [_registerViewContronller loadFlushCodeIfNeed];
    
    [_loginViewController resignResponserByTag:-1];
    [_registerViewContronller resignResponserByTag:-1];
}

-(void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index
{
    if(index==0)
        [_registerViewContronller willChangeScrollviewBack];
//    else if(index==1)
//        [_registerViewContronller loadFlushCodeIfNeed];
    
    CGRect frame = TTApplicationFrame();
    [_scrollView setContentOffset:CGPointMake(index * frame.size.width, 0) animated:YES];
    
    [_loginViewController resignResponserByTag:-1];
    [_registerViewContronller resignResponserByTag:-1];
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 外部接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)pushToProtocolWap
{
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    NSString* url = [NSString stringWithFormat:kLoginToPushProtocolUrl ,cid];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:url, @"address",nil];
    TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic];
    urlAction.animated = YES;
    [[TTNavigator navigator] openURLAction:urlAction];
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

- (NSDictionary *)getPhoneNumberData{
    NSDictionary* dic = [self.bindMobileNumViewController getCurrentPhoneData:nil];
    return dic;
}

-(void)createLoginView
{
    self._loginViewController = nil;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    _loginViewController = [[SNLoginViewController alloc] initWithParams:_queryDictionary];
    _loginViewController._guideLogin = self._guideLogin;
    _loginViewController.isFromVideo = self.isFromVideo;
    _loginViewController.dataSource = self;
    _loginViewController._SNLoginRegisterViewController = self;
//    _loginViewController.sourceChannelID = self.loginSuccessModel.sourceChannelID;
//    if (self.loginSuccessModel == nil) {
//        if (self.sourceID) {
//            _loginViewController.sourceChannelID = self.sourceID;
//        }
//    }
    
    CGFloat orginY = kHeaderHeightWithoutBottom;
    if (_queryDictionary[@"fromType"] && [_queryDictionary[@"fromType"] isEqualToString:@"video_report"]) {
        orginY = kHeaderHeight;
    }
    _loginViewController.view.frame = CGRectMake(0, orginY,screenFrame.size.width,
                                                 screenFrame.size.height-kToolbarHeight+7);
	[_scrollView addSubview:_loginViewController.view];
    
    //add mobile login view //手机号登录
    __weak SNLoginRegisterViewController* weakSelf = self;
    _bindMobileNumViewController = [[SNBindMobileNumViewController alloc] initWithButtonTitle:@"立即登录" WithLoginSuccessBlock:^(NSDictionary *info) {//登录成功回调 (仅手机号)
//        [weakSelf.loginSuccessModel loginSuccessed:info];
    }];
    
//    if (self.loginSuccessModel == nil) {
//        if (self.sourceID) {
//            _bindMobileNumViewController.sourceChannelID = self.sourceID;
//        }
//    }
//    else{
//        _bindMobileNumViewController.sourceChannelID = self.loginSuccessModel.sourceChannelID;
//    }
    
    _bindMobileNumViewController.arri_delegate = self;
    
    _bindMobileNumViewController.registerType = _guideType;
    _bindMobileNumViewController.view.frame = CGRectMake(0, 0, kAppScreenWidth, 170);
    _bindMobileNumViewController.loginFrom = self.loginFrom;
    [_loginViewController._scrollView addSubview:_bindMobileNumViewController.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [_loginViewController.view addGestureRecognizer:tap];
     //(tap);
}

- (void)arrive10secondLoginRegister{
    [_loginViewController showPhoneVerify];
}

- (void)onTap:(id)sender {
    
    [self resetToolBarOrigin];
    [_bindMobileNumViewController.loginView setResignFirstResponder];
}
- (void)handleApplicationDidEnterBackground {
    [self resetToolBarOrigin];
    [_bindMobileNumViewController.loginView setResignFirstResponder];

}

//
//-(void)createRegisterView
//{
//    self._registerViewContronller = nil;
//    
//    CGRect screenFrame = [UIScreen mainScreen].bounds;
//    _registerViewContronller = [[SNRegisterViewController alloc] init];
//    _registerViewContronller._SNLoginRegisterViewController = self;
//    _registerViewContronller.view.frame = CGRectMake(screenFrame.size.width, kHeaderHeightWithoutBottom,screenFrame.size.width,
//                                                     screenFrame.size.height-kToolbarHeight+7);
//	[_scrollView addSubview:_registerViewContronller.view];
//}

#pragma mark - SNNavigationController
- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldRecognizerPanGesture:(UIPanGestureRecognizer*)panGestureRecognizer {
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

- (void)exLoginSuccessedBlock{
//    if (self.loginSuccessModel) {
//        [self.loginSuccessModel loginSuccessed:nil];
//    }
}

//新浪微博登陆成功2 手机号登陆 微信登陆2
- (void)loginSuccess {
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.loginChanged" withObject:nil];
    
    BOOL needPop = [self guideLoginSuccessFunction];
    //从‘我的’广场点击调起登录，需要执行相关跳转操作
    UIViewController *viewController = [SNSLib forLoginSuccessToPush];
    if (nil != viewController) {
//        if (self.loginSuccessModel && self.loginSuccessModel.current_topViewController) {
//             [self exLoginSuccessedBlock];
//        }
        [self.flipboardNavigationController pushViewController:viewController animated:YES];
        [[SNCenterToast shareInstance] hideToast];
        return;
    }
    
    [[SNCenterToast shareInstance] hideToast];
    
    //wangshun 兼容 login SuccessModel
//    if (self.loginSuccessModel && self.loginSuccessModel.current_topViewController) {
//        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
//        [navi popToViewController:self.loginSuccessModel.current_topViewController animated:YES completion:^{
//             SNDebugLog(@"weakSelf.loginSuccessModel");
//            
//            [self exLoginSuccessedBlock];
//         }];
//        return;
//    }
    
    //需要返回的页面，执行返回操作
    if (needPop) {
        NSArray* array = self.flipboardNavigationController.viewControllers;
        for (UIViewController *vc in array) {
            if([vc isKindOfClass:[SNLoginRegisterViewController class]]) {
                NSInteger index = [array indexOfObject:vc] - 1;
                if (index >= 0) {
                    UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                    
                    __weak SNLoginRegisterViewController* weakSelf = self;
                    [self.flipboardNavigationController popToViewController:baseView animated:YES completion:^{
                        if (_guideType == SNGuideRegisterTypeContentComment || _guideType == SNGuideRegisterTypeReplayComment) { // pop完成之后再弹出评论
                            [SNGuideRegisterManager guideForContentComment];
                        }
                        
//                        [weakSelf.loginSuccessModel loginSuccessed:nil];

                    }];
                    if (_loginMsgFromShareSns) {
                        _loginMsgFromShareSns = NO;
                    }
                    
                    [[SNCenterToast shareInstance] hideToast];
                    return ;
                }
            }
        }
    }
    [[SNCenterToast shareInstance] hideToast];
}

//引导登陆后续操作
- (BOOL)guideLoginSuccessFunction
{
    switch (_guideType) {
        case SNGuideRegisterTypeSubscribe:
        {
            [SNGuideRegisterManager guideForSubscribe:self.subId];
            return YES;
        }
        case SNGuideRegisterTypeContentComment:
        {
            
            return YES;
        }
        case SNGuideRegisterTypeMediaComment:
        {
            [SNGuideRegisterManager guideForMediaComment];
            return YES;
        }
        case SNGuideRegisterTypeShake:
        {
            if (self.subId.length > 0)
                [SNGuideRegisterManager guideForShake:self.subId];
            
            return NO;
        }
        case SNGuideRegisterTypeUsercenter:
        {
            [SNGuideRegisterManager guideForUserCenter:self.pid userSpace:self.link];
            return NO;
        }
        case SNGuideRegisterTypeUserAttention:
        {
            [SNGuideRegisterManager guideForAttention];
            return YES;
        }
        case SNGuideRegisterTypeLogin:
        {
            //[SNGuideRegisterManager showUserCenter];
            if([SNGuideRegisterManager showAddFriend])
                return NO;
            else
                return YES;
        }
        case SNGuideRegisterTypeFav:
        {
            [SNGuideRegisterManager showMyFav];
            return NO;
        }
        case SNGuideRegisterTypeMessage:
        {
            [SNGuideRegisterManager showMyMessage];
            return NO;
        }
        case SNGuideRegisterTypeFavNews:
        {
            if (self.favouriteObject) {
                [[SNMyFavouriteManager shareInstance] addToMyFavouriteList:self.favouriteObject];
            }
            return YES;
        }
        case SNGuideRegisterTypeReport:
        {
            NSArray* array = self.flipboardNavigationController.viewControllers;
            for (UIViewController *vc in array) {
                if([vc isKindOfClass:[SNLoginRegisterViewController class]]) {
                    NSInteger index = [array indexOfObject:vc] - 1;
                    if (index >= 0) {
                        UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                        [self.flipboardNavigationController popToViewController:baseView animated:YES];
                    }
                }
            }
            
            if ([array count] == 0 && !self.flipboardNavigationController) {//视频举报登录返回
                [self.navigationController popViewControllerAnimated:NO];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5f*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.newsId) {
                    [SNUtility shouldUseSpreadAnimation:NO];
                    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.newsId,@"newsId", nil];
                    if (self.vid) {
                        self.reportType = @"2";
                    }
                    if (self.reportType.length  == 0) {
                        self.reportType = @"1";
                    }
                    NSString *urlString = [NSString stringWithFormat:kUrlReport,self.reportType];
                    urlString = [SNUtility addParamP1ToURL:urlString];
                    urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, self.newsId];
                    urlString = [NSString stringWithFormat:@"%@&channelId=%@", urlString, self.channelId];
                    if (self.vid) {
                        urlString = [NSString stringWithFormat:@"%@&vid=%@", urlString, self.vid];
                    }
                    if (self.url.length > 0) {
                        urlString = [NSString stringWithFormat:@"%@&url=%@", urlString, self.url];
                    }
                    [dic setObject:urlString forKey:kLink];
                    [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
                    [SNUtility openUniversalWebView:dic];
                }
            });
            
            return NO;
        }
        case SNGuideRegisterTypeStar:
        {
            return YES;
        }
        case SNGuideRegisterTypeTrendApproval:
        {
            [[SNTimelinePostService sharedService] timelineTrendApproval:self.actId
                                                                    spid:self.pid
                                                            approvalType:self.hasApproval];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.actId.length) {
                [dic setObject:self.actId forKey:kSNTLTrendKeyActId];
            }
            [SNNotificationManager postNotificationName:kTLTrendSendApprovalSucNotification object:dic];
            return YES;
        }
        case SNGuideRegisterTypeProtocolLogin:
        {
            [self popToBaseViewController];
            NSString *urlString = nil;
            if ([SNAPI isWebURL:self.backURLString]) {
                urlString = [SNUtility addParamSuccessToURL:self.backURLString];
            }
            else {
                urlString = self.backURLString;
            }
            [SNUtility openProtocolUrl:urlString];
            return NO;
        }
        case SNGuideRegisterTypeBackToUrl:
        {
            [SNNotificationManager postNotificationName:kRefreshChannelWebViewNotification object:nil];
            NSString * backUrl = [[SNActionSheetLoginManager sharedInstance] backUrl];
            if (backUrl.length == 0) {
                return YES;
            }
            else {
                [self popToBaseViewController];
                if ([SNUtility isProtocolV2:backUrl] || [backUrl hasPrefix:@"http"]) {
                    [SNUtility shouldUseSpreadAnimation:NO];
                    
                    NSString *urlString = nil;
                    if ([SNAPI isWebURL:backUrl]) {
                        urlString = [SNUtility addParamSuccessToURL:backUrl];
                    }
                    else {
                        urlString = backUrl;
                    }
                    BOOL forceBack = [SNActionSheetLoginManager sharedInstance].forceBackWebView;
                    NSDictionary *dict = nil;
                    if ([[urlString URLDecodedString] containsString:@"coupon.sohu.com"]) {
                        dict = @{kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType], kWebViewForceBackKey:[NSNumber numberWithBool:forceBack]};
                    }
                    else {
                        dict = @{kUniversalWebViewType:[NSNumber numberWithInteger:self.webViewType], kWebViewForceBackKey:[NSNumber numberWithBool:forceBack]};
                    }
                    [SNUtility openProtocolUrl:urlString context:dict];
                }
                return NO;
            }
        }
        case SNGuideRegisterTypeReplayComment:
        {
            
            return YES;
        }

        default:
            return NO;
    }
}

- (void)popToBaseViewController {
    NSArray* array = self.flipboardNavigationController.viewControllers;
    for (UIViewController *vc in array) {
        if([vc isKindOfClass:[SNLoginRegisterViewController class]]) {
            NSInteger index = [array indexOfObject:vc] - 1;
            if ([[array objectAtIndex:index] isKindOfClass:[SNBaseWebViewController class]] && index > 1) {
                if ([[array objectAtIndex:index - 1] isKindOfClass:[SNBaseWebViewController class]]) {
                    index = index-1;
                }
            }
            if (index >= 0) {
                if ([SNActionSheetLoginManager sharedInstance].forceBackWebView) {
                    index = 0;
                }
                UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                [self.flipboardNavigationController popToViewController:baseView animated:NO];
                if (_loginMsgFromShareSns) {
                    _loginMsgFromShareSns = NO;
                }
            }
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSArray* array = self.flipboardNavigationController.viewControllers;
    if ([array count]!=0 && [[array lastObject] isKindOfClass:[SNLoginRegisterViewController class]]) {
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        
        CGFloat pointY = kAppScreenHeight - kToolbarHeight - keyboardSize.height;
        self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
    }
    if (array == nil) {
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        
        CGFloat pointY = kAppScreenHeight - kToolbarHeight - keyboardSize.height;
        self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {


   self.toolbarView.frame = CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight);
}
- (void)verifyCodeAndMobileNumClick {
    [self resetToolBarOrigin];
}

- (void)mobileNumLoginSucceed {
//    [self loginSuccess];
    SNDebugLog(@"mobileNumLoginSucceed");
    
    if (!self.flipboardNavigationController) {
        [self doBack];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)addSwipeGesture {
    UISwipeGestureRecognizer *recognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture)];
    [recognizerUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizerUp];
    
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture)];
    [recognizerDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizerDown];
}

- (void)handleSwipeGesture {
    [self resetToolBarOrigin];
    [_bindMobileNumViewController.loginView setResignFirstResponder];
}

@end
