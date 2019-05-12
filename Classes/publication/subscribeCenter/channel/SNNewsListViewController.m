//
//  SNNewsListViewController.m
//  sohunews
//
//  Created by wang yanchen on 13-4-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewsListViewController.h"
#import "NSDictionaryExtend.h"
#import "SNSubChannelHeadView.h"
#import "SNNewsDownloadManager.h"
#import "SNSubDownloadManager.h"
#import "SNActionMenuController.h"
#import "SNAlert.h"
#import "SNTimelinePostService.h"
#import "SNDatabase_ReadCircle.h"
#import "SNCommentEditorViewController.h"
#import "SNGuideRegisterManager.h"
#import "SNNewsTableViewDelegateFactory.h"
#import "SNVideoAdContext.h"
#import "SNSubscribeCenterService.h"

#import "SNNewAlertView.h"
#import "SNNewsShareManager.h"
#import "SNNewsLoginManager.h"
#import "SNUserManager.h"

@interface SNNewsListViewController () {
    NSString *_channelSubId;
    SNSubChannelHeadView *_headView;
    SNToolbar *_toolbar;
    
    UIButton *_backBtn;
    UIButton *_share;
    UIButton *_downloadBtn;
    UIButton *_pubInfoBtn;
    
    SNTimelineOriginContentObject *_shareObj;
    UIView *statusView;
}

@property(nonatomic, copy) NSString *channelSubId;
@property(nonatomic, assign) BOOL isFromSubDetail;
@property(nonatomic, strong) SNActionMenuController *actionMenuController;
@property(nonatomic, strong) SNNewsShareManager *shareManager;
@property(nonatomic, strong) NSDictionary *queryDic;

@end

@implementation SNNewsListViewController
@synthesize channelSubId = _channelSubId;
@synthesize isFromSubDetail = _isFromSubDetail;
@synthesize queryDic = _queryDic;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.channelSubId = [query stringValueForKey:kChannelSubId defaultValue:nil];
        self.isFromSubDetail = [[query stringValueForKey:@"fromSubDetail" defaultValue:@""] length] > 0;
        self.queryDic = query;
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_main;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

- (void)dealloc {
    [[SNSubscribeCenterService defaultService] removeListener:self];
     //(_channelSubId);
     //(_headView);
     //(_toolbar);
     //(_backBtn);
     //(_share);
     //(_downloadBtn);
     //(_pubInfoBtn);
    
    _actionMenuController.delegate = nil;
     //(_actionMenuController);
    
}

- (SNToolbar *)toolbar {
	if (!_toolbar) {//tb_new_background
        //night_tb_new_background
        UIImage  *img = [UIImage  themeImageNamed:@"postTab0.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        imgView.frame = CGRectMake(0,0,320,49);
		_toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0,
															   self.view.height - img.size.height,
															   self.view.width,
															   img.size.height)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_toolbar addSubview:imgView];
		[self.view addSubview:_toolbar];
         imgView = nil;
        
        _toolbar.backgroundColor = [UIColor clearColor];
    }
    return _toolbar;
}

- (void)loadView {
    [super loadView];
    
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
    
    _headView = [[SNSubChannelHeadView alloc] initWithFrame:CGRectZero];
    [self setDate:subObj.publishTime];
    _headView.subTitle = subObj.subName;
    _headView.subId = subObj.subId;
    _headView.isSubed = [subObj.isSubscribed isEqualToString:@"1"];
    __weak __typeof(&*self)weakSelf = self;
    _headView.action = ^{
        
        if (![SNUserManager isLogin]) {//login
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method",[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
            //[SNUtility openLoginViewWithDict:dict];
            //wangshun login open
            [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000废弃
                
            } Failed:nil];
            return ;
        }
        
        SCSubscribeObject *object = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:weakSelf.channelSubId];
        
        if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:object] && ![object.isSubscribed isEqualToString:@"1"]) {
            [SNGuideRegisterManager showGuideWithSubId:weakSelf.channelSubId];
            return;
        }
        
        if (!object) {
            object = [[SCSubscribeObject alloc] init];
            object.subId = weakSelf.channelSubId;
            object.moreInfo = @"确认关注";
        }
        
        if ([object.moreInfo length] == 0) {
            object.moreInfo = @"确认关注";
        }
        
        // 统计的refer
//        if (_refer > 0) {
//            object.from = _refer;
//        } else {
//            object.from = REFER_PAPER_SUBBTN;
//        }
        
        BOOL isSub = [object.isSubscribed isEqualToString:@"1"];
        
        NSString *succMsg = isSub ? [object succUnsubMsg] : [object succSubMsg];
        NSString *failMsg = isSub ? [object failUnsubMsg] : [object failSubMsg];
        
        if (isSub) {
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRemoveMySubToServer request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
            [[SNSubscribeCenterService defaultService] removeMySubToServerBySubObject:object];
        } else {
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
            [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:object];
        }

//        _headView.isSubed = YES;
        
    };
//    [self.view addSubview:_headView];
    
    // 请求subinfo
    if (!subObj) {
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeSubInfo];
        [[SNSubscribeCenterService defaultService] loadSubInfoFromServerBySubId:self.channelSubId];
    }
    
    // tool bar
    
    // 返回按钮
    _backBtn = [[UIButton alloc] init];
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setBackgroundColor:[UIColor clearColor]];
    
    _backBtn.accessibilityLabel = @"返回";
    
    _share = [[UIButton alloc] init];
	[_share setImage:[UIImage themeImageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
	[_share setImage:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
	[_share addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
	[_share setBackgroundColor:[UIColor clearColor]];
    
    _share.accessibilityLabel = @"分享";
    
    _downloadBtn = [[UIButton alloc] init];
	[_downloadBtn setImage:[UIImage themeImageNamed:@"tb_new_download.png"] forState:UIControlStateNormal];
	[_downloadBtn setImage:[UIImage themeImageNamed:@"tb_new_download_hl.png"] forState:UIControlStateHighlighted];
	[_downloadBtn addTarget:self action:@selector(downloadClicked:) forControlEvents:UIControlEventTouchUpInside];
	[_downloadBtn setBackgroundColor:[UIColor clearColor]];
    
    _downloadBtn.accessibilityLabel = @"离线下载";
    
    _pubInfoBtn = [[UIButton alloc] init];
    [_pubInfoBtn setImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
    [_pubInfoBtn setImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
    [_pubInfoBtn addTarget:self action:@selector(pubInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_pubInfoBtn setBackgroundColor:[UIColor clearColor]];
    
    _pubInfoBtn.accessibilityLabel = @"刊物信息";
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_backBtn, _downloadBtn, _share, _pubInfoBtn, nil]];
    
    //self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.tableHeaderView = _headView;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        self.tableView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kToolbarViewTop);
        SNDebugLog(@"%@", NSStringFromCGRect(self.tableView.frame));
    }
    else
    {
        self.tableView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kToolbarViewHeight);

        statusView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kSystemBarHeight)];
        statusView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        [self.view insertSubview:statusView aboveSubview:self.tableView];
    }
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kToolbarViewHeight)];
        bottomView.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = bottomView;
    }
}

- (void)viewDidUnload {
     //(_headView);
     //(_toolbar);
     //(_backBtn);
     //(_share);
     //(_downloadBtn);
     //(_pubInfoBtn);
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
    _headView.isSubed = [subObj.isSubscribed boolValue];
    if ([[SNNewsDownloadManager sharedInstance] isSubChannelInList:subObj])
        _downloadBtn.enabled = NO;
    
    [self finishChangeTableviewFrame];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)finishChangeTableviewFrame {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        self.tableView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kToolbarViewTop);
    }
    else
    {
        self.tableView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight);
    }
}

// empty override
- (void)showAdView {
}

- (void)hideAdView {
}

- (void)createModel {
    self.isFromSub = YES;
    [super createModel];
    
}

- (void)reCreateModel {
    self.isFromSub = YES;
    [super reCreateModel];
}

- (id<TTTableViewDelegate>)createDelegate {
    CGRect headViewFrame = CGRectMake(0, -self.tableView.height, self.tableView.width, self.tableView.height);
    SNTableHeaderDragRefreshView *headView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:headViewFrame
                                                                                     needTipsView:YES];
    
    self.dragDelegate = [SNNewsTableViewDelegateFactory tableViewDelegateWithNewsChannelType:_channelType
                                                                                   channelId:_channelSubId
                                                                                  controller:self
                                                                                    headView:headView];
    [self resetTableDelegate:self.dragDelegate];
    self.dragDelegate.topInsetNormal = 0;
    self.dragDelegate.topInsetRefresh = 60;
    self.dragDelegate.enablePreload = NO;

	return (id)self.dragDelegate;
}

- (void)enableScrollToTop {
    _tableView.scrollsToTop = YES;
}

- (void)updateTheme:(NSNotification *)notifiction {
    //[self didReceiveMemoryWarning];
    [self updateTheme];
    
    [_headView updateTheme];
    
    [_toolbar removeFromSuperview];
     //(_toolbar);
    
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    
	[_share setImage:[UIImage themeImageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
	[_share setImage:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
    
	[_downloadBtn setImage:[UIImage themeImageNamed:@"tb_new_download.png"] forState:UIControlStateNormal];
	[_downloadBtn setImage:[UIImage themeImageNamed:@"tb_new_download_hl.png"] forState:UIControlStateHighlighted];
    
    [_pubInfoBtn setImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
    [_pubInfoBtn setImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_backBtn, _downloadBtn, _share, _pubInfoBtn, nil]];
    statusView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];

}

#pragma mark - SNActionMenuControllerDelegate
- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    
    if (self.channelSubId) {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        if (subObj.subName) [dicShareInfo setObject:subObj.subName forKey:kShareInfoKeyTitle];
        if (subObj.subIcon) [dicShareInfo setObject:subObj.subIcon forKey:kShareInfoKeyImageUrl];
    }
    
    NSString *screenShotPath = [UIImage screenshotImagePathFromView:self.view];
    if ([screenShotPath length] > 0) {
        [dicShareInfo setObject:screenShotPath forKey:kShareInfoKeyScreenImagePath];
    }
    
    NSString *shareContent = nil;
    if ([self.model isKindOfClass:[SNRollingNewsModel class]]) {
        shareContent = [(SNRollingNewsModel*)self.model shareContent];
    }
    if (shareContent.length == 0)
        shareContent = [NSString stringWithFormat:@"%@ 分享 %@ @搜狐新闻客户端", _headView.subTitle ? _headView.subTitle : @"",SNLinks_FixedUrl_3gk];
    
    if (shareContent.length > 0) {
        [dicShareInfo setObject:shareContent forKey:kShareInfoKeyContent];
    }
    
    //log
    if ([self.channelSubId length] > 0) {
        [dicShareInfo setObject:self.channelSubId forKey:kShareInfoKeyNewsId];
    }
    if ([shareContent length] > 0) {
        [dicShareInfo setObject:shareContent forKey:kShareInfoKeyShareContent];
    }
    
    return dicShareInfo;
}

- (void)commentWillPost:(NSMutableDictionary *)commentData sendType:(SNEditorType)sendType{
    NSString* sendContent = [commentData objectForKey:kCommentDataKeyText];
    
    //分享到阅读圈
    if (sendType == SNEditorTypeShare) {
        if (_shareObj) {
            [[SNTimelinePostService sharedService]timelineShareWithContent:sendContent
                                                             originContent:_shareObj
                                                               fromShareId:nil];
        }
    } else if (sendType == SNEditorTypeComment) {
        
    }
    
    sendContent = nil;
}

#pragma mark - SNSubscribeCenterServiceDelegate
// 统一的数据回调
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeSubInfo) {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        _headView.subTitle = subObj.subName;
        _headView.subId = subObj.subId;
        _headView.isSubed = [subObj.isSubscribed isEqualToString:@"1"];
    }
}

#pragma mark - actions
- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [[SNSubscribeCenterService defaultService] removeListener:self];        
    }
}

- (void)onBack:(id)sender {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(id)sender {
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    [mDic setObject:@"newsChannel" forKey:SNNewsShare_LOG_type];
    NSString* sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeChannel];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    
    [self callShare:mDic];
    return;
    
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    self.actionMenuController.shareSubType = ShareSubTypeQuoteText;
    self.actionMenuController.delegate = self;
    self.actionMenuController.contextDic = [self createActionMenuContentContext];
    self.actionMenuController.shareLogType = @"newsChannel";
    self.actionMenuController.disableLikeBtn = YES;
    [self.actionMenuController showActionMenu];
    _actionMenuController.sourceType = 33;
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (void)downloadClicked:(id)sender {
    //如果网络不可用提示网络不可用；
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    //2G、3G网络下进行流量警告
    if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        
        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"waste_data_bandwidth", @"") cancelButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_cancel", @"") otherButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_continue", @"")];
        [alert show];
        [alert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
            SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
            if (subObj) {
                [[SNNewsDownloadManager sharedInstance] addDownloadSub:subObj];
                _downloadBtn.enabled = NO;
            }
        }];
       
        return;

    }
    
    // todo  下载
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
    if (subObj) {
        [[SNNewsDownloadManager sharedInstance] addDownloadSub:subObj];
        _downloadBtn.enabled = NO;
    }
}

#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        //如果用户点“继续下载”
        // todo  下载
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        if (subObj) {
            [[SNNewsDownloadManager sharedInstance] addDownloadSub:subObj];
            _downloadBtn.enabled = NO;
        }
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //如果用户点“继续下载”
        // todo  下载
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        if (subObj) {
            [[SNNewsDownloadManager sharedInstance] addDownloadSub:subObj];
            _downloadBtn.enabled = NO;
        }
    }
}

- (void)pubInfoClicked:(id)sender {
    if (self.isFromSubDetail) {
        [self onBack:nil];
    }
    else {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        if (!subObj) {
            subObj = [[SCSubscribeObject alloc] init];
            subObj.subId = self.channelSubId;
        }
        subObj.openContext = @{@"fromNewsPaper" : @"YES"};
        [subObj openDetail];
    }
}

- (void)setDate:(NSString *)dateString {
    if (dateString && [dateString rangeOfString:@"-"].location == NSNotFound && [dateString length] > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([dateString floatValue] / 1000)]];
        
        [_headView setDateString:dateString];
    }
}

@end
