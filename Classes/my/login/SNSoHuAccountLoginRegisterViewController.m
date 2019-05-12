//
//  SNSoHuAccountLoginRegisterViewController.m
//  sohunews
//
//  Created by yangln on 14-10-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSoHuAccountLoginRegisterViewController.h"
#import "SNMyFavouriteManager.h"
#import "SNTimelinePostService.h"
#import "SNTimelineObjects.h"
#import "SNRegisterViewController.h"
#import "SNSoHuAccountLoginViewController.h"
#import "SNUserAccountService.h"
#import "SNUserinfoService.h"
#import "SNSLib.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNBaseWebViewController.h"

@interface SNSoHuAccountLoginRegisterViewController ()

@property (nonatomic, strong)NSString *pid;
@property (nonatomic, strong)NSString *link;
@property (nonatomic, strong)NSString *newsId;
@property (nonatomic, strong)NSString *actId;
@property (nonatomic, assign)int hasApproval;
@property(nonatomic, copy) NSString *subId;
@property(nonatomic, strong)SNBaseFavouriteObject *favouriteObject;
@property (nonatomic, strong)NSString *loginFrom;
@property (nonatomic, assign) UniversalWebViewType webViewType;

@end

@implementation SNSoHuAccountLoginRegisterViewController

-(void)dealloc
{
    [SNNotificationManager removeObserver:self];
    [self.headerView resignOffsetListener];
    [_accountService clearRequestAndDelegate];
     //(_topLineImageView);
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
        if(query!=nil)
        {
            self.delegate = self;
            self.method = [query objectForKey:@"method"];
            self.onBackMethod = [query objectForKey:@"onBackMethod"];
            self.object = [query objectForKey:@"object"];
            self.needPop = [(NSNumber*)[query objectForKey:@"needpop"] boolValue];
            NSNumber *type = [query objectForKey:kRegisterInfoKeyGuideType];
            _guideType = [type intValue];
            self.subId = [query stringValueForKey:kRegisterInfoKeySubId defaultValue:nil];
            self.pid = [query objectForKey:kRegisterInfoKeyUserPid];
            self.link = [query objectForKey:kRegisterInfoKeyUserLink];
            self.favouriteObject = [query objectForKey:kRegisterInfoKeyFavObject];
            self.newsId = [query objectForKey:kRegisterInfoKeyNewsId];
            self.actId = [query objectForKey:kRegisterInfoKeyActId];
            self.hasApproval = [query intValueForKey:kRegisterInfoKeyApprovalType defaultValue:0];
            self.loginFrom = [query objectForKey:kLoginFromKey];
            self.webViewType = [[query stringValueForKey:kUniversalWebViewType defaultValue:@""] integerValue];
            self.queryDictionary = query;
            
            self.commentBindOpen = [query objectForKey:@"commentBindOpen"];
            self.commentpopvc = [query objectForKey:@"commentpopvc"];
            
            if ([query objectForKey:@"loginSuccess"]) {
                
                id sender = [query objectForKey:@"loginSuccess"];
                if ([sender isKindOfClass:[SNNewsLoginSuccess class]]) {
                    self.loginSuccessModel = [query objectForKey:@"loginSuccess"];
                }
                
            }
            
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
//    [self createScrollView];
//    [self createSohuLoginView];
//    //[self createRegisterView];
//    
//    [self addHeaderView];
////    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"user_info_login", nil), NSLocalizedString(@"user_info_register", nil), nil]];
//    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"user_info_login", nil), nil]];//5.2.1屏蔽注册入口
//    CGSize titleSize = [NSLocalizedString(@"user_info_login", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
//    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
//    
//    self.headerView.delegate = self;
//    [self.headerView registerOffsetListener:_scrollView];
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
//    
//    [SNNotificationManager addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [SNNotificationManager addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)createScrollView {
    CGRect screenFrame = TTApplicationFrame();
    self.scrollView = nil;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7)];
    CGFloat orginY = 0;
    if (_queryDictionary[@"fromType"] && [_queryDictionary[@"fromType"] isEqualToString:@"video_report"]) {
        orginY = kHeaderHeight;
    }
    _scrollView.contentSize = CGSizeMake(screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7-orginY);
   // _scrollView.contentSize = CGSizeMake(screenFrame.size.width, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
}

-(void)createSohuLoginView
{
    self.accountLoginViewController = nil;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    _accountLoginViewController = [[SNSoHuAccountLoginViewController alloc] init];
    _accountLoginViewController.accountLoginRegisterViewController = self;
//    _accountLoginViewController.sourceChannelID = self.loginSuccessModel.sourceChannelID?:self.sourceID;
    CGFloat orginY = kHeaderHeightWithoutBottom;
    if (_queryDictionary[@"fromType"] && [_queryDictionary[@"fromType"] isEqualToString:@"video_report"]) {
        orginY = kHeaderHeight;
    }
    _accountLoginViewController.view.frame = CGRectMake(0, orginY,screenFrame.size.width,
                                                 screenFrame.size.height-kToolbarHeight+7);
    _accountLoginViewController.loginFrom = self.loginFrom;
    [_scrollView addSubview:_accountLoginViewController.view];
}

-(void)createRegisterView
{
    self.registerViewContronller = nil;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    _registerViewContronller = [[SNRegisterViewController alloc] init];
    _registerViewContronller.accountLoginRegisterViewController = self;
    _registerViewContronller.view.frame = CGRectMake(screenFrame.size.width, kHeaderHeightWithoutBottom,screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7);
    [_scrollView addSubview:_registerViewContronller.view];
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

- (void)onBack:(id)sender {
    [super onBack:sender];
    [self doBack];
    [_accountLoginViewController resignResponserByTag:-1];
    [_registerViewContronller resignResponserByTag:-1];
    if (!self.flipboardNavigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat orginY = kHeaderHeightWithoutBottom;
    if (_queryDictionary[@"fromType"] && [_queryDictionary[@"fromType"] isEqualToString:@"video_report"]) {
        if (nil == self.flipboardNavigationController) {
            orginY = kHeaderHeight;
        }
    }
    [_accountLoginViewController.view setOrigin:CGPointMake(_accountLoginViewController.view.origin.x, orginY)];
    [_accountLoginViewController viewWillAppear:animated];
    [_registerViewContronller viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_accountLoginViewController viewDidAppear:animated];
    [_registerViewContronller viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_accountLoginViewController viewWillDisappear:animated];
    
    [SNNotificationManager removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    [SNNotificationCenter hideLoading];
}

#pragma mark scrollView delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    
    CGRect frame = TTApplicationFrame();
    int index = scrollView.contentOffset.x / frame.size.width;
    [self.headerView setCurrentIndex:index animated:YES];
    
    //[self resetToolBarOrigin];
   // [_accountLoginViewController resignResponserByTag:-1];
    [_registerViewContronller resignResponserByTag:-1];
    
    if (scrollView.contentOffset.x == frame.size.width) {
        CGSize titleSize = [NSLocalizedString(@"user_info_register", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.headerView.bottomLineImageView.frame = CGRectMake(69 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
    else {
        CGSize titleSize = [NSLocalizedString(@"user_info_login", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
}

#pragma mark HeadSelectViewDelegate

-(void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index
{
    if(index==0)
        [_registerViewContronller willChangeScrollviewBack];
    
    CGRect frame = TTApplicationFrame();
    CGFloat pointX = index * frame.size.width;
    [_scrollView setContentOffset:CGPointMake(pointX, 0) animated:YES];
    
    if (pointX == frame.size.width) {
        CGSize titleSize = [NSLocalizedString(@"user_info_register", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.headerView.bottomLineImageView.frame = CGRectMake(69 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
    else {
        CGSize titleSize = [NSLocalizedString(@"user_info_login", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
    
    [self resetToolBarOrigin];
    [_accountLoginViewController resignResponserByTag:-1];
    [_registerViewContronller resignResponserByTag:-1];
}

//------------------------------------------- 外部接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)pushToProtocolWap
{
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    NSString* url = [NSString stringWithFormat:kLoginToPushProtocolUrl ,cid];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:url, @"url", @"YES", @"isRegisterProtocol",nil];
    TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic];
    urlAction.animated = YES;
    [[TTNavigator navigator] openURLAction:urlAction];
}

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

//搜狐账号登陆成功
- (void)loginSuccess {
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.loginChanged" withObject:nil];
    BOOL needPop = [self guideLoginSuccessFunction];
    
    //需要返回的页面，执行返回操作
    UIViewController *viewController = [SNSLib forLoginSuccessToPush];
    if (nil != viewController) {
        if (self.loginSuccessModel && self.loginSuccessModel.current_topViewController) {
            if (self.loginSuccessModel) {
                //[self.loginSuccessModel loginSuccessed:nil];
            }
        }
        [self.flipboardNavigationController pushViewController:viewController];
    }else{
        
        //wangshun 有self.loginSuccessModel 优先
        if (self.loginSuccessModel && self.loginSuccessModel.current_topViewController) {
            SNDebugLog(@"wangshun loginSuccessModel pop for sohu register");
            if (self.flipboardNavigationController) {
                __weak SNSoHuAccountLoginRegisterViewController* weakSelf = self;
                [self.flipboardNavigationController popToViewController:self.loginSuccessModel.current_topViewController animated:YES completion:^{
                    if (weakSelf.loginSuccessModel) {
                        //wangshun
                        //[weakSelf.loginSuccessModel loginSuccessed:nil];
                    }
                }];
                return;
            }
        }
        
        
        if (needPop) {
            NSArray* array = self.flipboardNavigationController.viewControllers;
            for (UIViewController *vc in array) {
                if([vc isKindOfClass:[SNSoHuAccountLoginRegisterViewController class]]) {
                    NSInteger index = [array indexOfObject:vc] - 2;
                    if (index >= 0) {
                        UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                        
                        __weak SNSoHuAccountLoginRegisterViewController* weakSelf = self;
                        
                        [self.flipboardNavigationController popToViewController:baseView animated:YES completion:^{
                            if (_guideType == SNGuideRegisterTypeContentComment || _guideType == SNGuideRegisterTypeReplayComment) { // pop完成之后再弹出评论
                                [SNGuideRegisterManager guideForContentComment];
                            }
                            
                            
                            if (weakSelf.loginSuccessModel) {
//                                wangshun
                                //[weakSelf.loginSuccessModel loginSuccessed:nil];
                            }
                        }];
                        return ;
                    }
                }
            }
        }
    }
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
        case SNGuideRegisterTypeReplayComment:
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
                if([vc isKindOfClass:[SNSoHuAccountLoginRegisterViewController class]]) {
                    NSInteger index = [array indexOfObject:vc] - 2;
                    if (index >= 0) {
                        UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                        [self.flipboardNavigationController popToViewController:baseView animated:NO];
                    }
                }
            }
            
            if ([array count] == 0 && !self.flipboardNavigationController) {//视频举报登录返回
                NSArray *vArray = self.navigationController.viewControllers;
                if ([vArray count] > 1) {
                    UIViewController *viewController = (UIViewController *)[vArray objectAtIndex:1];
                    if ([viewController isKindOfClass:NSClassFromString(@"VideoDetailViewController")]) {
                        [self.navigationController popToViewController:viewController animated:NO];
                    }
                    
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5f*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.newsId) {
                    [SNUtility shouldUseSpreadAnimation:NO];
                    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.newsId,@"newsId", nil];
                    NSString *urlString = [NSString stringWithFormat:kUrlReport,@"1"];
                    urlString = [SNUtility addParamP1ToURL:urlString];
                    urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, self.newsId];
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
        case SNGuideRegisterTypeBackToUrl: {
            [SNNotificationManager postNotificationName:kRefreshChannelWebViewNotification object:nil];
            //需要返回的页面，执行返回操作
            NSString *backUrl = [[SNActionSheetLoginManager sharedInstance] backUrl];
            UIViewController *viewController = [SNSLib forLoginSuccessToPush];
            if (nil != viewController || backUrl.length == 0) {
                return YES;
            }
            else {
                NSArray *array = self.flipboardNavigationController.viewControllers;
                for (UIViewController *vc in array) {
                    if([vc isKindOfClass:[SNSoHuAccountLoginRegisterViewController class]]) {
                        NSInteger index = [array indexOfObject:vc] - 2;
                        
                        if ((array.count-1)>=index) {//wangshun 崩溃
                            if ([[array objectAtIndex:index] isKindOfClass:[SNBaseWebViewController class]] && index > 1) {
                                
                                if ((array.count-1)>=(index - 1)) {
                                    if ([[array objectAtIndex:index - 1] isKindOfClass:[SNBaseWebViewController class]]) {
                                        index = index-1;
                                    }
                                }
                            }
                        }
                        
                        if (index >= 0) {
                            if ([SNActionSheetLoginManager sharedInstance].forceBackWebView) {
                                index = 0;
                            }
                            UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                            [self.flipboardNavigationController popToViewController:baseView animated:YES];
                            continue;
                        }
                            
                    }
                }
                if ([SNUtility isProtocolV2:backUrl] || [backUrl hasPrefix:@"http"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^() {
                        [SNUtility shouldUseSpreadAnimation:NO];
                        
                        NSString *urlString = nil;
                        if ([SNAPI isWebURL:backUrl]) {
                            urlString = [SNUtility addParamSuccessToURL:backUrl];
                        }
                        else {
                            urlString = backUrl;
                        }
                        BOOL forceBack = [SNActionSheetLoginManager sharedInstance].forceBackWebView;
                        [SNUtility openProtocolUrl:urlString context:@{kUniversalWebViewType:[NSNumber numberWithInteger:self.webViewType], kWebViewForceBackKey:[NSNumber numberWithBool:forceBack]}];
                    });
                }
                
                return NO;
            }
        }
        default:
            return NO;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    CGFloat pointY = kAppScreenHeight - bg.size.height - keyboardSize.height + 5;
    self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
}
- (void)keyboardWillHide:(NSNotification *)notification{
    self.toolbarView.frame = CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight);
}

-(void)setToolBarOrigin {
    [self resetToolBarOrigin];
}

@end
