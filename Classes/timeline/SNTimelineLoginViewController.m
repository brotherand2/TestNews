//
//  SNTimelineLoginViewController.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineLoginViewController.h"
#import "UIColor+ColorUtils.h"
//#import "SNTImelineModel.h"
#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNUserManager.h"

#define kInfoViewTopMargin              (26 / 2)
#define kInfoLabelTopMargin             (18 / 2)

#define kHasCheckForPid                 (@"hasCheckRecommendedUserForPid_")


@interface SNTimelineLoginViewController () {
    
    
    UIButton *_loginBtnTencentWeibo;
    UIButton *_loginBtnQQ;
    UIButton *_loginOther;
    SNUserAccountService* _accountService;
    SNUserinfoService* _userinfoService;
}

@property(nonatomic, retain) SNURLRequest *checkRecommendRequest;

- (void)goTimelineMainController;
- (void)goRecommendController;

@end

@implementation SNTimelineLoginViewController
@synthesize checkRecommendRequest = _checkRecommendRequest;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self)
    {
        _accountService = [[SNUserAccountService alloc] init];
        _accountService.openLoginUrlDelegate = self;
        _accountService.loginDelegate = self;
        
        _userinfoService = [[SNUserinfoService alloc] init];
        _userinfoService.userinfoDelegate = self;
    }
    return self;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_checkRecommendRequest);
    
    TT_RELEASE_SAFELY(_infoImageView);
    TT_RELEASE_SAFELY(_infoLabel);
    TT_RELEASE_SAFELY(_loginBtnSinaWeibo);
    TT_RELEASE_SAFELY(_loginBtnTencentWeibo);
    TT_RELEASE_SAFELY(_loginBtnQQ);
    TT_RELEASE_SAFELY(_loginOther);
    [_accountService clearRequestAndDelegate];
    TT_RELEASE_SAFELY(_accountService);
    TT_RELEASE_SAFELY(_userinfoService);
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    [self addHeaderView];
    
    [self initInfoPanel];
    
    [self initRegisterButtons];
    
    [self addToolbar];
    
    // iphone 5 长屏幕 适配
    [self layoutSubView];
}

- (void)initInfoPanel
{
    self.headerView.sections = @[@"阅读圈"];

    UIImage *infoImage = [UIImage imageNamed:@"timeline_login_info.png"];
    _infoImageView = [[UIImageView alloc] initWithImage:infoImage];
    _infoImageView.top = self.headerView.bottom + kInfoViewTopMargin;
    _infoImageView.centerX = CGRectGetMidX(self.view.bounds);
    [self.view addSubview:_infoImageView];
    
    _infoPanelBottom = _infoImageView.bottom;
    btnOffsetY = [UIScreen mainScreen].bounds.size.height - 480;
}

- (void)initRegisterButtons {
//    NSString *loginBtnTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLLoginBtnTextColor];
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kInfoLabelFontSize + 1)];
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.textAlignment = UITextAlignmentCenter;
    _infoLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
    _infoLabel.text = @"立即登录";
    _infoLabel.textColor = [UIColor colorFromString:@"#7D7D7D"];
    [self.view addSubview:_infoLabel];
    
    _infoLabel.top = _infoPanelBottom + kInfoLabelTopMargin;
    
    CGFloat btnWidth = self.view.width / 4;
    UIColor *btnTextColor = [UIColor colorFromString:@"#7D7D7D"];
    UIImage *sepImage = [UIImage imageNamed:@"timeline_login_sepline.png"];
    
    UIImage *sinaImage = [UIImage imageNamed:@"timeline_login_sina.png"];
    _loginBtnSinaWeibo = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                    _infoLabel.bottom + kBtnTopMargin + btnOffsetY,
                                                                    btnWidth,
                                                                    sinaImage.size.height + kBtnTitleFontSize + kBtnTitleTopMargin)];
    [_loginBtnSinaWeibo setImage:sinaImage forState:UIControlStateNormal];
    
    UILabel *btnTitleSina = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _loginBtnSinaWeibo.width, kBtnTitleFontSize + 1)];
    btnTitleSina.backgroundColor = [UIColor clearColor];
    btnTitleSina.textAlignment = UITextAlignmentCenter;
    btnTitleSina.font = [UIFont systemFontOfSize:kBtnTitleFontSize];
    btnTitleSina.text = @"新浪微博";
    btnTitleSina.textColor = btnTextColor;
    btnTitleSina.bottom = _loginBtnSinaWeibo.height;
    [_loginBtnSinaWeibo addSubview:btnTitleSina];
    TT_RELEASE_SAFELY(btnTitleSina);
    
    [_loginBtnSinaWeibo setImageEdgeInsets:UIEdgeInsetsMake(0,
                                                            (_loginBtnSinaWeibo.width - sinaImage.size.width) / 2,
                                                            _loginBtnSinaWeibo.height - sinaImage.size.height,
                                                            (_loginBtnSinaWeibo.width - sinaImage.size.width) / 2)];
    [_loginBtnSinaWeibo addTarget:self action:@selector(loginActionWithSinaWeibo:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginBtnSinaWeibo];
    
    UIImageView *sepLineView = [[UIImageView alloc] initWithImage:sepImage];
    sepLineView.right = _loginBtnSinaWeibo.right;
    sepLineView.bottom = _loginBtnSinaWeibo.bottom;
    [self.view addSubview:sepLineView];
    TT_RELEASE_SAFELY(sepLineView);
    
    UIImage *tencentImage = [UIImage imageNamed:@"timeline_login_tencent.png"];
    _loginBtnTencentWeibo = [[UIButton alloc] initWithFrame:_loginBtnSinaWeibo.frame];
    _loginBtnTencentWeibo.left = _loginBtnSinaWeibo.right;
    _loginBtnTencentWeibo.imageEdgeInsets = _loginBtnSinaWeibo.imageEdgeInsets;
    [_loginBtnTencentWeibo setImage:tencentImage forState:UIControlStateNormal];
    [_loginBtnTencentWeibo addTarget:self action:@selector(loginActionWithTencentWeibo:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *btnTitleTencent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _loginBtnTencentWeibo.width, kBtnTitleFontSize + 1)];
    btnTitleTencent.backgroundColor = [UIColor clearColor];
    btnTitleTencent.textAlignment = UITextAlignmentCenter;
    btnTitleTencent.font = [UIFont systemFontOfSize:kBtnTitleFontSize];
    btnTitleTencent.text = @"腾讯微博";
    btnTitleTencent.textColor = btnTextColor;
    btnTitleTencent.bottom = _loginBtnTencentWeibo.height;
    [_loginBtnTencentWeibo addSubview:btnTitleTencent];
    TT_RELEASE_SAFELY(btnTitleTencent);
    [self.view addSubview:_loginBtnTencentWeibo];
    
    sepLineView = [[UIImageView alloc] initWithImage:sepImage];
    sepLineView.right = _loginBtnTencentWeibo.right;
    sepLineView.bottom = _loginBtnTencentWeibo.bottom;
    [self.view addSubview:sepLineView];
    TT_RELEASE_SAFELY(sepLineView);
    
    UIImage *qqImage = [UIImage imageNamed:@"timeline_login_qq.png"];
    _loginBtnQQ = [[UIButton alloc] initWithFrame:_loginBtnTencentWeibo.frame];
    _loginBtnQQ.left = _loginBtnTencentWeibo.right;
    _loginBtnQQ.imageEdgeInsets = _loginBtnTencentWeibo.imageEdgeInsets;
    [_loginBtnQQ setImage:qqImage forState:UIControlStateNormal];
    [_loginBtnQQ addTarget:self action:@selector(loginActionWithQQ:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *btnTitleQQ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _loginBtnQQ.width, kBtnTitleFontSize + 1)];
    btnTitleQQ.backgroundColor = [UIColor clearColor];
    btnTitleQQ.textAlignment = UITextAlignmentCenter;
    btnTitleQQ.font = [UIFont digitAndLetterFontOfSize:kBtnTitleFontSize];
    btnTitleQQ.text = @"QQ";
    btnTitleQQ.textColor = btnTextColor;
    btnTitleQQ.bottom = _loginBtnTencentWeibo.height;
    [_loginBtnQQ addSubview:btnTitleQQ];
    TT_RELEASE_SAFELY(btnTitleQQ);
    
    [self.view addSubview:_loginBtnQQ];
    
    sepLineView = [[UIImageView alloc] initWithImage:sepImage];
    sepLineView.right = _loginBtnQQ.right;
    sepLineView.bottom = _loginBtnQQ.bottom;
    [self.view addSubview:sepLineView];
    TT_RELEASE_SAFELY(sepLineView);
    
    UIImage *otherImage = [UIImage imageNamed:@"timeline_login_other.png"];
    _loginOther = [[UIButton alloc] initWithFrame:_loginBtnQQ.frame];
    _loginOther.left = _loginBtnQQ.right;
    _loginOther.imageEdgeInsets = _loginBtnQQ.imageEdgeInsets;
    [_loginOther setImage:otherImage forState:UIControlStateNormal];
    [_loginOther addTarget:self action:@selector(loginActionWithOthers:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *btnTitleOther = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _loginOther.width, kBtnTitleFontSize + 1)];
    btnTitleOther.backgroundColor = [UIColor clearColor];
    btnTitleOther.textAlignment = UITextAlignmentCenter;
    btnTitleOther.font = [UIFont systemFontOfSize:kBtnTitleFontSize];
    btnTitleOther.text = @"其他方式";
    btnTitleOther.textColor = btnTextColor;
    btnTitleOther.bottom = _loginOther.height;
    [_loginOther addSubview:btnTitleOther];
    TT_RELEASE_SAFELY(btnTitleOther);
    
    [self.view addSubview:_loginOther];
}

- (void)layoutSubView
{
    if (btnOffsetY > 0) {
        CGFloat dsY = _loginBtnSinaWeibo.top - self.headerView.bottom;
        CGFloat dsTop = _infoImageView.centerY - self.headerView.bottom;
        _infoImageView.centerY = self.headerView.bottom + dsY / 2 - dsTop / 4;
        _infoLabel.top = _infoImageView.bottom + kInfoLabelTopMargin;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    TT_RELEASE_SAFELY(_infoImageView);
    TT_RELEASE_SAFELY(_loginBtnSinaWeibo);
    TT_RELEASE_SAFELY(_loginBtnTencentWeibo);
    TT_RELEASE_SAFELY(_loginBtnQQ);
    TT_RELEASE_SAFELY(_loginOther);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[SNShareManager defaultManager] cancelSyncTokenRequest];
}
#pragma mark - actions

- (void)onBack:(id)sender {
    if (self.checkRecommendRequest) {
        [self.checkRecommendRequest.delegates removeObject:self];
        [self.checkRecommendRequest cancel];
    }
    [super onBack:nil];
}

- (void)loginActionWithSinaWeibo:(id)sender {
    _accountService.openLoginUrlDelegate = self;
    _accountService.loginDelegate = self;
    [_accountService openLoginLinkRequest:@"sina"];
}

- (void)loginActionWithTencentWeibo:(id)sender {
    _accountService.openLoginUrlDelegate = self;
    _accountService.loginDelegate = self;
    [_accountService openLoginLinkRequest:@"t.qq"];
}

- (void)loginActionWithQQ:(id)sender {
    _accountService.openLoginUrlDelegate = self;
    _accountService.loginDelegate = self;
    [_accountService openLoginLinkRequest:@"qq"];
}

- (void)loginActionWithOthers:(id)sender {
    // 这个就是进之前的用户中心
    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self,@"delegate", method,@"method" , nil];
    
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)loginSuccess {
//    NSString *pid = [[SNUserinfoEx userinfoEx] _pid];
//    NSString *checkKey = [NSString stringWithFormat:@"%@%@", kHasCheckForPid, pid];
//    
//    // 如果当前用户 pid  已经检测过是否需要推荐好友  则直接进入timeline
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:checkKey]) {
//        [self goTimelineMainController];
//        return;
//    }
//    
//    if (self.checkRecommendRequest) {
//        [self.checkRecommendRequest.delegates removeObject:self];
//        [self.checkRecommendRequest cancel];
//    }
//    
//    NSString *requestUrl = [NSString stringWithFormat:@"%@user/relationopt?action=checkRecommend", kTimelineServer];
//    requestUrl = [SNUtility addParamsToURLForReadingCircle:requestUrl];
//    self.checkRecommendRequest = [SNURLRequest requestWithURL:requestUrl delegate:self];
//    self.checkRecommendRequest.timeOut = 10;
//    self.checkRecommendRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
//    self.checkRecommendRequest.response = [[[SNURLJSONResponse alloc] init] autorelease];
//    
//    [self.checkRecommendRequest send];
//    [SNNotificationCenter showLoading:@"请稍候..."];
}

#pragma mark - SNUserinfoOpenLoginUrlDelegate
//Get user info
- (void)notifyOpenLoginUrSuccess:aUrl domain:(NSString*)aDomain {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)notifyOpenLoginUrFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    [SNNotificationCenter showMessage:aMsg hideAfter:2];
}

- (void)notifyOpenLoginUrFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

#pragma mark - SNUserAccountLoginDelegate
- (void)notifyLoginSuccess {
    //只有成功获取pid才算登录成功
    if([SNUserManager isLogin])
    {
        [SNNotificationCenter showMessage:@"登录成功!"];
        [self loginSuccess];
    }
    else
    {
        _userinfoService.userinfoDelegate = self;
        [_userinfoService circle_userinfoRequest:nil];
    }
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)notifyLoginFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)notifyLoginRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - SNUserinfoGetUserinfoDelegate

- (void)notifyGetUserinfoSuccess:(NSArray*)mediaArray {
    [SNNotificationCenter showMessage:@"登录成功!"];
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    [self loginSuccess];
}

- (void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    [SNNotificationCenter hideLoading];
    if (request == self.checkRecommendRequest) {
        BOOL needRecommend = NO;
        SNURLJSONResponse *responseObj = request.response;
        NSDictionary *jsonObj = [responseObj rootObject];
        if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *valueObj = [jsonObj dictionaryValueForKey:@"value" defalutValue:nil];
            if (valueObj) {
                int rtCode = [valueObj intValueForKey:@"code" defaultValue:0];
                needRecommend = (rtCode == 200);
            }
        }
        
        NSString *pid = [SNUserManager getPid];
        NSString *checkKey = [NSString stringWithFormat:@"%@%@", kHasCheckForPid, pid];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:checkKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (needRecommend)
            [self goRecommendController];
        else
            [self goTimelineMainController];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    [SNNotificationCenter hideLoading];
    if (request == self.checkRecommendRequest) {
        [self goTimelineMainController];
    }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    [SNNotificationCenter hideLoading];
    if (request == self.checkRecommendRequest) {
        [self goTimelineMainController];
    }
}

#pragma mark - private

- (void)goTimelineMainController {
    TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://timeline_main"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)goRecommendController {
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://recommendUser"] applyAnimated:YES] applyQuery:@{@"showReadCircle" : @""}];
    [[TTNavigator navigator] openURLAction:action];
}

@end
