//
//  SNVideoMediaBaseViewController.m
//  sohunews
//
//  Created by handy wang on 12/6/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoMediaBaseViewController.h"
#import "SNTableHeaderDragRefreshView.h"
#import "SNVideoMediaHeadlineView.h"
#import "SNDBManager.h"
#import "SNVideoMediaWebService.h"
#import "SNGuideRegisterManager.h"
#import "SNWebController.h"
#import "SNMyFavouriteManager.h"
#import "UIWebView+Utility.h"
#import "SNShareConfigs.h"
#import "SNVideoAdContext.h"
#import "SNSubscribeCenterService.h"
#import "SNNewsShareManager.h"

#define kResponseHeaderTermName                 (@"termName")
#define kResponseHeaderTermTime                 (@"termTime")
#define kResponseHeaderColumnCount              (@"columnCount")
#define kResponseHeaderInvalidSub               (@"invalidSub")

#define kRefreshByDrag                          (@"kRefreshByDrag")
#define kMediaPage_HeadlineWidth                (320.0f)
#define kMediaPage_HeadlineHeight               (110.0f/2.0f)


@interface SNVideoMediaBaseViewController ()/*<SNClickItemOnHalfViewDelegate>*/
//以下两个属性只有在videoMedia://二代协议时才有值；
@property (nonatomic, copy)NSString *subId;
@property (nonatomic, copy)NSString *columnId;

/**
 * 这个link有两种情况：
 * videoMedia://subId=xxx&columnId=yyy : 表示自媒体页二代协议
 * videoPerson://mid=xx : 表示社交媒体视频列表二代协议
 */
@property (nonatomic, copy)NSString *videoMediaLink;
@property (nonatomic, copy)NSString *videoMediaTitle;

@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, weak)UIScrollView *webScrollView;
@property (nonatomic, strong)SNTableHeaderDragRefreshView *dragHeaderView;
@property (nonatomic, strong)SNVideoMediaHeadlineView *headlineView;

@property (nonatomic, strong)SNToolbar *toolbar;
@property (nonatomic, strong)UIButton *backBtn;
@property (nonatomic, strong)UIButton *shareBtn;
@property (nonatomic, strong)UIButton *moreBtn;
@property (nonatomic, strong)SNEmbededActivityIndicator *loading;

@property (nonatomic, strong)SNVideoMediaWebService *videoMediaWebService;
@property (nonatomic, strong)NSData *htmlData;

//这个变量为了控制：在下拉刷新手没有离开时，不用时时更新显示上次刷新的时间
@property (nonatomic, assign)BOOL shouldRefreLoadDate;

@property (nonatomic, strong)SNActionMenuController *actionMenuController;
@property (nonatomic, strong)SNNewsShareManager *shareManager;

@end

@implementation SNVideoMediaBaseViewController

#pragma mark - Lifecycle
- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super init]) {
        self.subId = [query stringValueForKey:kSubId defaultValue:nil];
        self.columnId = [query stringValueForKey:kVideoColumnId defaultValue:nil];
        self.videoMediaLink = [query stringValueForKey:kVideoMediaLink defaultValue:nil];
        self.videoMediaTitle = [query stringValueForKey:kVideoMediaTitle defaultValue:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateNonPicMode:) name:kNonePictureModeChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self renderBackground];
    [self createWebView];
    [self createDragHeaderView];
    [self createHeadlineView];
    [self createBottomToolBar];
    [self createLoadingView];
    
    [self refresh:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    [self updateHeadlineContent];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.webScrollView.delegate = nil;
    _webScrollView = nil;
    
    self.webView.delegate = nil;
    self.webView = nil;
    
    self.dragHeaderView = nil;
    self.headlineView = nil;
    
    self.toolbar = nil;
    self.backBtn = nil;
    self.shareBtn = nil;
    self.moreBtn = nil;
    
    self.loading.delegate = nil;
    self.loading = nil;
    
    [self.videoMediaWebService cancel];
    self.videoMediaWebService.delegate = nil;
    self.videoMediaWebService = nil;
    
    _actionMenuController.delegate = nil;
     //(_actionMenuController);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    
    self.webScrollView.delegate = nil;
    _webScrollView = nil;
    
    [self.webView stopObserveProgress];
    self.webView.delegate = nil;
    
    
    
    self.loading.delegate = nil;
    
    [self.videoMediaWebService cancel];
    self.videoMediaWebService.delegate = nil;
    
    _actionMenuController.delegate = nil;
     //(_actionMenuController);

}

#pragma mark - for Analysis
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (SNCCPVPage)currentPage {
    return paper_main;
}

- (NSString *)currentOpenLink2Url {
    return self.videoMediaLink;
}

#pragma mark - Public

#pragma mark - Private
- (void)renderBackground {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

#pragma mark - About UI - WebView
- (void)createWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight-kSystemBarHeight-kToolbarViewTop)];
    self.webView.delegate = self;
    self.webView.opaque = NO;//make system draw the logo below transparent webview
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];//不load空内部的话headlineView就跑到上边缘以外去了
    [self hideGradientBackground:self.webView];
    [self.webView startObserveProgress];
    [self.view addSubview:_webView];
    
    self.webScrollView = self.webView.scrollView;
    self.webScrollView.contentInset = UIEdgeInsetsMake(kMediaPage_HeadlineHeight, 0.f, kToolbarViewHeight, 0.f);
    self.webScrollView.delegate = self;
    self.webScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

- (void)hideGradientBackground:(UIView*)theView {
	for (UIView* subview in theView.subviews) {
		if ([subview isKindOfClass:[UIImageView class]]) {
			subview.hidden = YES;
		}
		[self hideGradientBackground:subview];
	}
}

- (void)handleWebViewProgressDidChange:(NSNotification *)notification {
    if (notification.object == self.webView) {
        CGFloat progress = [[notification userInfo] floatValueForKey:kSNWebViewCurrentProgressValueKey
                                                        defaultValue:0];
        if (progress > 0) {
            if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
            } else {
                _loading.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
            }
        }
    }
}

#pragma mark - About UI - Others
- (void)createDragHeaderView {
    _dragHeaderView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0,
                                                                                     -_webScrollView.bounds.size.height-kMediaPage_HeadlineHeight,
                                                                                     _webScrollView.width,
                                                                                     _webScrollView.bounds.size.height)];
    _dragHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
    [self.webScrollView addSubview:_dragHeaderView];
}

- (void)createHeadlineView {
    _headlineView = [[SNVideoMediaHeadlineView alloc] initWithFrame:CGRectMake(0,
                                                                      -kMediaPage_HeadlineHeight,
                                                                      kMediaPage_HeadlineWidth,
                                                                      kMediaPage_HeadlineHeight)
                                                  Delegate:self];
    _headlineView.subId = self.subId;
    UIScrollView *scrollView = _webView.scrollView;
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        [self.view addSubview:_headlineView];//故意让logo头部悬浮顶部抢占voiceover焦点，防止voiceover看完一篇文章点返回之后总是回到报纸第一个新闻
    }
    else {
        [scrollView addSubview:_headlineView];
    }
    _headlineView.hidden = YES;
    
    [self updateHeadlineContent];
}

- (void)updateHeadlineContent {
    //显示标题或logo、订阅按钮或日期
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SCSubscribeObject *subObject = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(subObject.subName.length > 0) {
                self.videoMediaTitle = subObject.subName;
            }
            _headlineView.pubName = self.videoMediaTitle;
            
            
            if (![self isVideoMedia] || [subObject.isSubscribed boolValue]) {
                _headlineView.state = Subscribe;
                
                if (subObject.publishTime.length > 0) {
                    NSDate *tempDate = [NSDate dateWithTimeIntervalSince1970:([subObject.publishTime floatValue]/1000)];
                    [_headlineView setDateString:[NSDate stringFromDate:tempDate withFormat:@"yyyy-MM-dd"]];
                }
                else {
                    NSDate *tempDate = [NSDate date];
                    NSString *tempDateStr = [NSDate stringFromDate:tempDate withFormat:@"yyyy-MM-dd"];
                    [self.headlineView setDateString:tempDateStr];
                }
            }
            else {
                _headlineView.state = UnSubcribe;
            }
            
            _headlineView.hidden = !(self.htmlData);
        });
    });
}

- (void)createBottomToolBar {
    UIImage  *img = [UIImage  themeImageNamed:@"postTab0.png"];
    _toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0,
                                                           kAppScreenHeight - img.size.height,
                                                           self.view.width,
                                                           img.size.height)];
    
    
    self.toolbar.backgroundColor = [UIColor clearColor];
    [self.toolbar setBackgroundImage:img];
    [self.view addSubview:_toolbar];
    
    //Toolbar items
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    [self.backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setBackgroundColor:[UIColor clearColor]];
    self.backBtn.accessibilityLabel = @"返回";
    
    self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.shareBtn setImage:[UIImage themeImageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
	[self.shareBtn setImage:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
	[self.shareBtn addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
	[self.shareBtn setBackgroundColor:[UIColor clearColor]];
    self.shareBtn.enabled = NO;
    self.shareBtn.accessibilityLabel = @"分享";
    
    if ([self isVideoMedia]) {//自媒体内容的情况
        self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.moreBtn setImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
        [self.moreBtn setImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
        [self.moreBtn addTarget:self action:@selector(pubInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.moreBtn setBackgroundColor:[UIColor clearColor]];
        self.moreBtn.enabled = NO;
        self.moreBtn.accessibilityLabel = @"媒体信息";
        [self.toolbar setButtons:[NSArray arrayWithObjects:self.backBtn, self.shareBtn, self.moreBtn, nil] withType:SNToolbarAlignRight];
    }
    else {
        [self.toolbar setButtons:[NSArray arrayWithObjects:self.backBtn, self.shareBtn, nil] withType:SNToolbarAlignRight];
    }
}

- (void)updateBottomBoolBarTheme {
    UIImage  *img = [UIImage  themeImageNamed:@"postTab0.png"];
    [_toolbar setBackgroundImage:img];
    
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    
	[_shareBtn setImage:[UIImage themeImageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
	[_shareBtn setImage:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
    
    [_moreBtn setImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
    [_moreBtn setImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
}

- (void)onBack:(UIButton *)backButton {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)onShare:(UIButton *)shareButton {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    
#if 1 //wangshun share test
    
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    [mDic setObject:@"video" forKey:@"shareLogType"];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = ShareSubTypeQuoteText;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    _actionMenuController.shareLogType = @"video";
    _actionMenuController.delegate = self;
    _actionMenuController.sourceType = SNShareSourceTypeSub;
    if ([self isVideoMedia])
    {
        _actionMenuController.disableLikeBtn = NO;
        _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];

    }
    else
    {
        _actionMenuController.disableLikeBtn = YES;
    }
    _actionMenuController.disableCopyLinkBtn = YES;
    [_actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}


- (BOOL)checkIfHadBeenMyFavourite
{
    SNVideoMediaFavourite *videoMediaFavourite = [[SNVideoMediaFavourite alloc] init];
    videoMediaFavourite.type = MYFAVOURITE_REFER_VIDEOMEDIA;
    videoMediaFavourite.contentLevelFirstID = _columnId;
    videoMediaFavourite.contentLevelSecondID = _subId;
    videoMediaFavourite.link2 = _videoMediaLink;
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:videoMediaFavourite];
}

- (void)actionmenuDidSelectLikeBtn {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if ([self checkIfHadBeenMyFavourite]) {
        [self executeFavouriteNews:nil];
    }
    else {
        [SNUtility executeFloatView:self selector:@selector(executeFavouriteNews:)];
    }
}

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self executeFavouriteNews:dict];
}

- (void)executeFavouriteNews:(NSDictionary *)dict {
    SNVideoMediaFavourite *videoMediaFavourite = [[SNVideoMediaFavourite alloc] init];
    videoMediaFavourite.type = MYFAVOURITE_REFER_VIDEOMEDIA;
    videoMediaFavourite.contentLevelFirstID = _columnId;
    videoMediaFavourite.contentLevelSecondID = _subId;
    videoMediaFavourite.link2 = _videoMediaLink;
    videoMediaFavourite.title = _videoMediaTitle;
    [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:videoMediaFavourite corpusDict:dict];
}


- (void)pubInfoClicked:(UIButton *)sender {
    if (self.subId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self.subId forKey:kSubId];
        [dic setObject:@"1" forKey:@"fromNewsPaper"];
        
        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:action];
    }
}

- (void)createLoadingView {
	_loading = [[SNEmbededActivityIndicator alloc] initWithFrame:CGRectMake(0,
                                                                            kSystemBarHeight,
                                                                            320,
                                                                            TTScreenBounds().size.height-kSystemBarHeight-kToolbarHeight)
                                                     andDelegate:self];
    _loading.hidesWhenStopped = YES;
    _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
	[self.view addSubview:_loading];
}

#pragma mark - About Drag to refresh
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if (scrollView.dragging && !(self.videoMediaWebService.isLoading)) {
        
		if ((scrollView.contentOffset.y > kRefreshDeltaY-kMediaPage_HeadlineHeight)) {
            if (self.shouldRefreLoadDate) {
                // 这里需要一个上次刷新时间的提醒
                [self.dragHeaderView refreshUpdateDate];
                self.shouldRefreLoadDate = NO;
            }
			[self.dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
		}
        else if (scrollView.contentOffset.y < kRefreshDeltaY - kMediaPage_HeadlineHeight) {
			[self.dragHeaderView setStatus:TTTableHeaderDragRefreshReleaseToReload];
		}
	}
	else if (self.videoMediaWebService.isLoading) {
		if (self.webScrollView.contentOffset.y >= -kMediaPage_HeadlineHeight) {
            self.webScrollView.contentInset = UIEdgeInsetsMake(kMediaPage_HeadlineHeight, 0, kToolbarViewHeight, 0);
			
		} else if (self.webScrollView.contentOffset.y < -kMediaPage_HeadlineHeight) {
			self.webScrollView.contentInset = UIEdgeInsetsMake(kMediaPage_HeadlineHeight + kHeaderVisibleHeight, 0, kToolbarViewHeight, 0);
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	if ((scrollView.contentOffset.y <= kRefreshDeltaY - kMediaPage_HeadlineHeight) && !(self.videoMediaWebService.isLoading)) {
        [self refresh:YES];
	}
    
    self.shouldRefreLoadDate = YES;
}

- (void)refresh:(BOOL)byDrag {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        if (!(self.htmlData)) {
            [self.loading setStatus:SNEmbededActivityIndicatorStatusUnstableNetwork];
        }
        return;
    }
    
    [self.videoMediaWebService cancel];
    self.videoMediaWebService.delegate = nil;
    
    NSURL *serviceURL = [self contentURL];
    SNDebugLog(@"Made media conent url: %@", serviceURL.absoluteString);
    
    self.videoMediaWebService = [[SNVideoMediaWebService alloc] init];
    self.videoMediaWebService.url = serviceURL;
    self.videoMediaWebService.delegate = self;
    self.videoMediaWebService.userInfo = @{kRefreshByDrag : @(byDrag)};
    if (!!serviceURL) {
        [self.videoMediaWebService loadAsynchronously];
    }
}

#pragma mark - SNVideoMediaWebServiceDelegate
- (void)didStartLoad {
    NSDictionary *userInfo = self.videoMediaWebService.userInfo;
    BOOL refreshByDrag = [userInfo[kRefreshByDrag] boolValue];
    
    if (!refreshByDrag) {
        [self.loading setStatus:SNEmbededActivityIndicatorStatusStartLoading];
    }
    
    [self.dragHeaderView setStatus:TTTableHeaderDragRefreshLoading];
    
    if (refreshByDrag) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
        self.webScrollView.contentInset = UIEdgeInsetsMake(kMediaPage_HeadlineHeight + kHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)didFinishedLoad:(NSString *)htmlContent request:(ASIHTTPRequest *)request {
    self.htmlData = [htmlContent dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.loading setStatus:SNEmbededActivityIndicatorStatusStopLoading];
    [self updateLoadStateToFinishWithAnimation:YES];
    
    [self.webView loadData:self.htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:request.url.absoluteString]];
    
    self.shareBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    
    [self updateUIWhenDidFinish:request];
}

- (void)didFailedLoad {
    [self.loading setStatus:SNEmbededActivityIndicatorStatusUnstableNetwork];
    [self updateLoadStateToFinishWithAnimation:YES];
    
    self.shareBtn.enabled = NO;
    self.moreBtn.enabled = NO;
}

- (void)updateLoadStateToFinishWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    }
    
    [self.dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
    self.webScrollView.contentInset = UIEdgeInsetsMake(kMediaPage_HeadlineHeight, 0.0f, kToolbarViewHeight, 0.0f);
    
    if (animation) {
        [UIView commitAnimations];
    }
    
    [self.dragHeaderView setCurrentDate];
}

- (void)updateUIWhenDidFinish:(ASIHTTPRequest *)request {
    NSString *titleText = nil;
    NSString *termTime = nil;
    int columnCount = 0;
    int invalidSub = -1;
    
    NSDictionary *responseHeaders = request.responseHeaders;
    for(NSString* key in responseHeaders) {
        if ([[key lowercaseString] isEqualToString:[kResponseHeaderTermName lowercaseString]]) {
            titleText = [responseHeaders objectForKey:key];
            if (titleText.length > 0) {
                if (titleText.length > 0) {
                    titleText = [titleText stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
                }
                
                titleText = [titleText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
        else if ([[key lowercaseString] isEqualToString:[kResponseHeaderTermTime lowercaseString]]) {
            termTime = [responseHeaders objectForKey:key];
        }
        else if ([[key lowercaseString] isEqualToString:[kResponseHeaderColumnCount lowercaseString]]) {
            columnCount = [[responseHeaders objectForKey:key] intValue];
        }
        else if ([[key lowercaseString] isEqualToString:[kResponseHeaderInvalidSub lowercaseString]]) {
            invalidSub = [[responseHeaders objectForKey:key] intValue];
        }
    }
    
    if (titleText.length > 0) {
        self.videoMediaTitle = titleText;
    }
    self.headlineView.pubName = self.videoMediaTitle;
    
    if (termTime.length > 0) {
        NSDate *tempDate = [NSDate dateFromString:termTime];
        NSString *tempDateStr = [NSDate stringFromDate:tempDate withFormat:@"yyyy-MM-dd"];
        [self.headlineView setDateString:tempDateStr];
    }
    else {
        NSDate *tempDate = [NSDate date];
        NSString *tempDateStr = [NSDate stringFromDate:tempDate withFormat:@"yyyy-MM-dd"];
        [self.headlineView setDateString:tempDateStr];
    }
    
    [_headlineView setSeperatorHidden:(columnCount>1)];
    _headlineView.hidden = !(self.htmlData) || (invalidSub == 1);
    
    if (invalidSub == 1) {
        self.shareBtn.enabled = NO;
        self.moreBtn.enabled = NO;
    }
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry {
    [self refresh:NO];
}

#pragma mark - Private
- (void)subscribeAction {
    SCSubscribeObject *object = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
    BOOL isSub = [object.isSubscribed isEqualToString:@"1"];
    
    if (!isSub && [SNSubscribeCenterService shouldLoginForSubscribeWithObj:object]) {
        [SNGuideRegisterManager showGuideWithSubId:self.subId];
        return;
    }
    
    if (!object) {
        object = [[SCSubscribeObject alloc] init];
        object.subId = self.subId;
        object.moreInfo = @"确认关注";
    }
    
    if ([object.moreInfo length] == 0) {
        object.moreInfo = @"确认关注";
    }

    NSString *succMsg = isSub ? [object succUnsubMsg] : [object succSubMsg];
    NSString *failMsg = isSub ? [object failUnsubMsg] : [object failSubMsg];
    
    if (isSub) {
        SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRemoveMySubToServer request:nil refId:object.subId];
        [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
        [[SNSubscribeCenterService defaultService] removeMySubToServerBySubObject:object];
        self.headlineView.state = UnSubcribe;
    } else {
        SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:self.subId];
        [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
        [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:object];
        self.headlineView.state = Subscribe;
    }
}

- (NSURL *)contentURL {
    if ([self.videoMediaLink rangeOfString:kProtocolVideoMidia options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSString *urlString = [NSString stringWithFormat:kVideoMediaURL, self.subId, self.columnId];
        
        if([SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
            urlString = [urlString stringByAppendingString:@"&noPic=1"];
        }
        if([[SNThemeManager sharedThemeManager] isNightTheme]) {
            urlString = [urlString stringByAppendingString:@"&mode=1"];
        }
        
        return [NSURL URLWithString:urlString];
    }
    else if ([self.videoMediaLink rangeOfString:kProtocolVideoPerson options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSString *mid = [[SNUtility parseURLParam:self.videoMediaLink schema:kProtocolVideoPerson] objectForKey:kMidInMediaLink];
        if (mid.length > 0) {
            NSString *urlString = [NSString stringWithFormat:kVideoPersonURL, mid];
            if([SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
                urlString = [urlString stringByAppendingString:@"&noPic=1"];
            }
            if([[SNThemeManager sharedThemeManager] isNightTheme]) {
                urlString = [urlString stringByAppendingString:@"&mode=1"];
            }
            return [NSURL URLWithString:urlString];
        }
    }
    return nil;
}

- (BOOL)isVideoMedia {
    return (NSNotFound != [self.videoMediaLink rangeOfString:kProtocolVideoMidia options:NSCaseInsensitiveSearch].location);
}

#pragma mark - About Share
- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    
//    NSString *allHTML = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//    if (allHTML.length > 0) {
//        [dicShareInfo setObject:allHTML forKey:@"htmlContent"];
//    }

    SharedInfo *shareInfo	= [self getSharedInfo];
    NSString *content = shareInfo.sharedTitle;
    if (content.length > 0) {
        [dicShareInfo setObject:content forKey:kShareInfoKeyContent];
    }
    
    if (self.subId.length > 0) {
        [dicShareInfo setObject:self.subId forKey:kSubId];
    }
    
    if (self.videoMediaTitle.length > 0) {
        [dicShareInfo setObject:self.videoMediaTitle forKey:kShareInfoKeyTitle];
    }
    
    NSString *screenShotPath = [UIImage screenshotImagePathFromView:self.view];
    if ([screenShotPath length] > 0) {
        [dicShareInfo setObject:screenShotPath forKey:kShareInfoKeyScreenImagePath];
    }
    
    NSString *tempShareLink = [SNUtility getLinkFromShareContent:content];
    if (tempShareLink.length > 0) {
        [dicShareInfo setObject:tempShareLink forKey:kShareInfoKeyShareLink];
    }
    if (tempShareLink.length > 0) {
        [dicShareInfo setObject:tempShareLink forKey:kShareInfoKeyWebUrl];
    }
    
    //log
    if ([self.subId length] > 0) {
        [dicShareInfo setObject:self.subId forKey:kShareInfoKeyNewsId];
    }
    if ([shareInfo.sharedTitle length] > 0) {
        [dicShareInfo setObject:shareInfo.sharedTitle forKey:kShareInfoKeyShareContent];
    }
    if (self.subId.length > 0) {
        [dicShareInfo setObject:self.subId forKey:kShareInfoLogKeySubId];
    }
    
    return dicShareInfo;
}

- (SharedInfo *)getSharedInfo {
	SharedInfo *sharedInfo = [[SharedInfo alloc] init];
    sharedInfo.sharedUrl =  [self.webView.request.URL absoluteString];
    
    TBXML *xml = [TBXML tbxmlWithXMLData:self.htmlData];
    TBXMLElement *rootElm = xml.rootXMLElement;
    TBXMLElement *headElm = [TBXML childElementNamed:@"head" parentElement:rootElm];
    TBXMLElement *metaElm = [TBXML childElementNamed:@"meta" parentElement:headElm];
    
    NSString *shareContentStr = nil;
    if (metaElm) {
        do {
            NSString *shareReadId = [TBXML valueOfAttributeNamed:@"name" forElement:metaElm];
            if ([shareReadId isEqualToString:@"sohunews-shareSns"]) {
                shareContentStr = [TBXML valueOfAttributeNamed:@"content" forElement:metaElm];
                break;
            }
        } while ((metaElm = [TBXML nextSiblingNamed:@"meta" searchFromElement:metaElm]) != nil);
    }
    
    if (shareContentStr.length > 0) {
        shareContentStr = [shareContentStr stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    }
    if (shareContentStr.length > 0) {
        sharedInfo.sharedTitle = [shareContentStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    SNDebugLog(@"Share title: %@", sharedInfo.sharedTitle);
    return sharedInfo;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestStr = [request.URL absoluteString];
    if([requestStr hasPrefix:kProtocolVideo]) {
        [SNUtility openProtocolUrl:requestStr];
        return NO;
    }
    
    return YES;
}

#pragma mark - SNSubscribeCenterServiceDelegate
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        [self updateHeadlineContent];
        [[SNSubscribeCenterService defaultService] removeListener:self];
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        [self updateHeadlineContent];
        [[SNSubscribeCenterService defaultService] removeListener:self];
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        [self updateHeadlineContent];
        [[SNSubscribeCenterService defaultService] removeListener:self];
    }
}

#pragma mark - Notification
- (void)updateTheme:(NSNotification*)notification {
    [_headlineView updateTheme];
    [self updateBottomBoolBarTheme];
    
    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.view.backgroundColor = [UIColor colorFromString:backgroundColor];
    [self refresh:NO];
}

- (void)updateNonPicMode:(NSNotificationCenter*)notification {
    [self refresh:NO];
}

@end
