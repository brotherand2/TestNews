//
//  SNPhotoTextControllerViewController.m
//  sohunews
//
//  Created by jialei on 13-8-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoListController.h"
#import "SNPhotoListTableCell.h"
#import "SNCommentListCell.h"
#import "SNWeiboDetailMoreCell.h"
#import "SNPhotoListTableItem.h"
#import "SNPhotoListHeaderView.h"
#import "SNPhotoListRecommendCell.h"
#import "SNPhotoListSubscribeCell.h"
#import "SNPhotoListSectionTitleCell.h"
#import "SNSeparateLabel.h"
#import "SNCommentListManager.h"
#import "SNPhotoGallerySlideshowController.h"
#import "SNCommonNewsDatasource.h"
#import "SNDatabase_CloudSave.h"
#import "SNGuideRegisterManager.h"
#import "SNTimelinePostService.h"
#import "SNAnalytics.h"
#import "SNRollingNewsViewController.h"
#import "SNDBManager.h"
#import "SNFloorCommentItem.h"
#import "SNSoundManager.h"
#import "NSCellLayout.h"
#import "SNMyFavouriteManager.h"
#import "SNRollingNewsTableItem.h"
#import "SNRollingPhotoNewsTableCell.h"
#import "SNRecommendParameterManager.h"
#import "SNTimelineConfigs.h"
#import "SNCommentConfigs.h"
#import "SNSendCommentObject.h"
#import "SNHtmlNoteWriter.h"
#import "SNCommentEditorViewController.h"
#import "SNPhotolistDataSource.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNRecommendPhotoListOpenAction.h"
#import "SNCommentCacheManager.h"

#define kTableSectionPhoto          0
#define kTableSectionSubscribe      1
#define kTableSectionRecommendTitle 2
#define kTableSectionRecommend      3
#define kTableSectionCommentTitle   4
#define kTableSectionComment        5

#define kPhotoTextListSectionNumber 6
#define kTableRecommendCellCount    1

@interface SNPhotoListController ()
{
    BOOL    _isModeRefreshed;
    BOOL    _isOnlineMode;
    BOOL    _isPhotoLoading;
    BOOL    _isCommentLoading;
    BOOL    _isWaitingLoadingGid;
    BOOL    _isIndexChanged;
    BOOL    _isRecommend;
    BOOL    _isFullScreenMode;
    BOOL    _animationStopped;
    BOOL    _isSendCount;
    BOOL    _isShowReadCount;
    BOOL    _isCommentNumLoad;
    BOOL    _isPvFired;     // 用户正文阅读pv统计 只记一次
    BOOL    _supportNext;
    
    MYFAVOURITE_REFER   _myFavouriteRefer;
    GallerySourceType   _gallerySourceType;
    SNCommentSendType   commentType;
    
    CGFloat               pinchScale;
    CGFloat               _lastVerticalOffset;
    CGFloat               _lastOffsetY;
    int                   _lastCommentCuont;
    NSString              *_termId;
    NSString              *_newsId;
    NSString              *_channelId;
    NSMutableDictionary   *_queryDict;
    NSMutableArray        *_recommendIds;
    NSIndexPath           *_returnIndex;
    
//    UITableView *_photoTextTable;
    SNPhotoListHeaderView *_headerView;
    SNPostFollow *_postFollow;
    UIImageView         *_fadeInView;
    SNEmbededActivityIndicatorEx *_loadingView;
    
    SNPhotoListModel *_photoListModel;
    UISwipeGestureRecognizer *_swipeLeft;
    UIPinchGestureRecognizer *_pinchGesture;
    SNRecommendPhotoListOpenAction *_recommendPhotoListOpenAction;
    SNContentMoreViewController *_contentMoreController;
    SNPostCommentController *_postCommentController;
    SNPhotoGallerySlideshowController *_slideshowController;
    
    UIView *_imageDetailView;
    FGalleryPhotoView *_photoView;
    
    SNArticleRecomService *_recommendService;
}

@property (nonatomic, retain)NSString *newsId;
@property (nonatomic, retain)NSString *termId;
@property (nonatomic, retain)NSString *channelId;
@property (nonatomic, retain)NSString *lastNewsId;
@property (nonatomic,retain)NSNumber *type;
@property (nonatomic, retain)NSMutableDictionary *queryDict;
//@property (nonatomic, retain)NSMutableArray *photoListItems;
@property (nonatomic,retain)SNPhotoListHeaderView *headerView;
@property (nonatomic,retain)NSIndexPath           *returnIndex;

@property (nonatomic, retain)SNPhotoListModel *photoListModel;
@property (nonatomic, retain)SNCommentListManager *commentListManager;
@property (nonatomic, retain)SCSubscribeObject *subscribe;
@property (nonatomic, retain)SNActionMenuController *actionMenuController;
@property (nonatomic, retain)SNContentMoreViewController *contentMoreController;
@property (nonatomic, retain)SNPhotoGallerySlideshowController *slideshowController;
@property (nonatomic, retain)SNCommentCacheManager *commentCacheManager;
@property (nonatomic, retain)UITableView *photoTextTable;
@property (nonatomic, retain)SNNewsComment *replyComment;
@property (nonatomic, retain)SNNewsComment *shareComment;
@property (nonatomic, retain)NSString *shareContent;
@property (nonatomic,assign)id delegateController;

// for 3.7 统计
@property (nonatomic, assign) SNReferFrom refer;
@property (nonatomic, retain) SNAnalyticsNewsReadTimer *analyticsTimer;

@property (nonatomic, strong) SNPhotolistDataSource *photolistDataSource;

@end

@implementation SNPhotoListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    if (self = [super initWithNavigatorURL:URL query:query])
    {
        self.queryDict = [[[NSMutableDictionary alloc] initWithDictionary:query] autorelease];
        self.newsId = [query objectForKey:kNewsId];
        self.lastNewsId = self.newsId;
		self.termId = [query objectForKey:kTermId];
        //不是从rollingnews页打开，没有termId，设置为-1
        if (self.termId.length <= 0) {
            self.termId = kDftChannelGalleryTermId;
        }
        self.channelId = [query objectForKey:kChannelId];
        if (self.channelId.length <= 0) {
            self.channelId = @"1";
        }
        self.type = [query objectForKey:kType];
        self.rollingNewsList = [query objectForKey:kNewsList];
        self.newsModel = [query objectForKey:kNewsModel];
        self.delegateController = [query objectForKey:kController];
        self.referFrom = [query objectForKey:kReferFrom];
        _myFavouriteRefer = [[query objectForKey:kMyFavouriteRefer] intValue];
        _isShowReadCount = NO;
        _isCommentNumLoad = NO;
        _supportNext = YES;
        if ([query objectForKey:kNewsSupportNext]) {
            _supportNext = [[query objectForKey:kNewsSupportNext] boolValue];
        }
        
        [SNRecommendParameterManager sharedInstance].ctx = nil;
        [SNRecommendParameterManager sharedInstance].tracker = nil;
        
        NSString *linkString = [query objectForKey:kNewsLink2];
        if (linkString && linkString.length > 0) {
            NSDictionary *parameterDic = [SNUtility getParametersWithString:linkString];
            NSString *ctxString = [parameterDic objectForKey:kCtx];
            NSString *trackerString = [parameterDic objectForKey:kTracker];
            if (ctxString && ![ctxString isEqualToString:@""]) {
                [SNRecommendParameterManager sharedInstance].ctx = ctxString;
            }
            if (trackerString && ![trackerString isEqualToString:@""]) {
                [SNRecommendParameterManager sharedInstance].tracker = trackerString;
            }
        }
        
        _recommendService = [[SNArticleRecomService alloc] init];
        _recommendService.adType = SNAdInfoTypePhotoListNews;
        _recommendService.delegate = self;
        [self loadRecommendNews];
        
        //如果从loading页进入，那么手动吧channelid改成1
        //避免云收藏时无法与slide图做区分
        id referId = [query objectForKey:kRefer];
        if(referId!=nil && [referId isKindOfClass:[NSNumber class]])
        {
            NSInteger refer = [((NSNumber*)referId) intValue];
            self.refer = refer;
            if(refer==REFER_LOADING)
                self.channelId = @"1";
        }
        
        NSString *onlineMode  = [query objectForKey:kNewsMode];
        if ([onlineMode length] == 0) {
            _isOnlineMode = YES;
        }
        else
        {
            _isOnlineMode = [onlineMode isEqualToString:kNewsOnline];
        }
        self.hidesBottomBarWhenPushed = YES;
        _animationStopped = YES;
        
        NSNumber *sourceTypeNumber = [query objectForKey:kGallerySourceType];
        _gallerySourceType = [sourceTypeNumber intValue];
        _isSendCount = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];
    }
	
    return self;
}

- (SNCCPVPage)currentPage {
    return article_detail_pic;
}

- (NSString *)currentOpenLink2Url {
    NSString *link = [self.queryDict stringValueForKey:kLink defaultValue:nil];
    return [self.queryDict stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:link];
}

- (void)loadRecommendNews
{
    _recommendService.newsId = self.newsId;
    _recommendService.termId = self.termId;
    _recommendService.channelId = self.channelId;
    if ([_recommendService.recommendArray count] == 0) {
        [_recommendService loadRecommendNews];
    }
}

- (void)loadView
{
    [super loadView];
    self.view.frame = TTApplicationFrame();
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushNotificationWillCome:)
                                                 name:kNotifyDidReceive object:nil];
    
    _isModeRefreshed  = NO;
    _swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleSwipeFrom:)] autorelease];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeLeft];
    [self enableSwipeGesture:NO];
    
    UIPinchGestureRecognizer* pinGeture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    [self.view addGestureRecognizer:pinGeture];
    _pinchGesture = pinGeture;

    [self loadTableView];
    [self customerTableBg];

    //loading页面
    [self showLoading];
    
    //工具栏
    _postFollow = [[SNPostFollow  alloc]  init];;
    _postFollow._strPostOrComment = NSLocalizedString(@"ComposeComment", nil);
    _postFollow._viewController = self;
    _postFollow._delegate = self;
    [_postFollow createWithType:SNPostFollowTypeBackAndCommentAndShareAndMore];
    [_postFollow setShareBtnEnabel:NO];
    
    _postFollow._textField.enabled = NO;
    [_postFollow setButton:2 enabled:NO];
    [_postFollow setButton:3 enabled:NO];
    
    [self createModel];
    [self.photoListModel load:TTURLRequestCachePolicyDefault more:YES];
//
//    // chh:添加一层View实现内容淡入效果
//    _fadeInView = [[UIImageView alloc] init];
//    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
//    _fadeInView.backgroundColor = [UIColor colorFromString:backgroundColor];
//    _fadeInView.frame = CGRectMake(0, 0, TTScreenBounds().size.width, TTScreenBounds().size.height);
//    _fadeInView.alpha = 0;
//    [self.view insertSubview:_fadeInView aboveSubview:_photoTextTable];
//    
//    [_fadeInView release];
}

- (void)loadTableView
{
    //列表
    self.photolistDataSource = [[[SNPhotolistDataSource alloc] init] autorelease];
    _photoTextTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight,
                                                                    self.view.width, self.view.height - kSystemBarHeight)
                                                   style:UITableViewStylePlain];
    _photoTextTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoTextTable.dataSource = self.photolistDataSource;
    _photoTextTable.delegate = self.photolistDataSource;
    _photoTextTable.backgroundColor = [UIColor clearColor];
    _photoTextTable.backgroundView = nil;
    _photoTextTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _photoTextTable.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [self.view addSubview:_photoTextTable];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, kPostFollowHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    _photoTextTable.tableFooterView = footerView;
    [footerView release];
    
    if (_isWaitingLoadingGid)
    {
        SNPhotoListModel *myModel = self.photoListModel;
        if (self.returnIndex && self.returnIndex.row < [myModel.photoList.gallerySubItems count])
        {
            [_photoTextTable scrollToRowAtIndexPath:self.returnIndex
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:NO];
        }
    }
}

-(void)customerTableBg {
    _photoTextTable.backgroundView = nil;
    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    _photoTextTable.backgroundColor = [UIColor colorFromString:backgroundColor];
    self.view.backgroundColor = [UIColor colorFromString:backgroundColor];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [[SNSoundManager sharedInstance]stopAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyDidReceive object:nil];
    TT_RELEASE_SAFELY(_headerView);
    TT_RELEASE_SAFELY(_postFollow);
    
    TT_RELEASE_SAFELY(_loadingView);
    _fadeInView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_slideshowController) {
        [self enableSwipeGesture:YES];
    }
    
    [self reportPVAnalyzeWithCurrentNavigationController:_commonNewsController.flipboardNavigationController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isPvFired) {
        // 3.7 新闻正文pv统计
        NSMutableDictionary *actionData = [NSMutableDictionary dictionary];
        if (self.newsId) {
            [actionData setObject:self.newsId forKey:@"newsId"];
        }
        if (self.refer > 0) {
            [actionData setObject:@(self.refer) forKey:@"refer"];
        }
        [actionData setObject:@(SNAnalyticsTimerPageTypeNewsPhotoList) forKey:@"page"];
        
        [[SNAnalytics sharedInstance] realtimeReportNewscontentPvWithActionData:actionData];
        
        _isPvFired = YES;
    }
    
    // 3.7 阅读时常统计
    self.analyticsTimer = [SNAnalyticsNewsReadTimer timer];
    self.analyticsTimer.page = SNAnalyticsTimerPageTypeNewsPhotoList;
    self.analyticsTimer.newsId = self.newsId;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SNSoundManager sharedInstance] stopAll];
    
    // 3.7 阅读时常统计
    if (self.analyticsTimer) {
        [self.analyticsTimer fire];
        self.analyticsTimer = nil;
    }
    
    _isPvFired = NO;
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    TT_RELEASE_SAFELY(_newsId);
    TT_RELEASE_SAFELY(_termId);
    TT_RELEASE_SAFELY(_channelId);
    TT_RELEASE_SAFELY(_lastNewsId);
    TT_RELEASE_SAFELY(_returnIndex);
    TT_RELEASE_SAFELY(_type);
    
    [_recommendService cancel];
    _recommendService.delegate = nil;
    TT_RELEASE_SAFELY(_recommendService);
    
    _photoListModel.delegate = nil;
    TT_RELEASE_SAFELY(_photoListModel);
//    _commentListModel.delegate = nil;
    TT_RELEASE_SAFELY(_commentListManager);
    //    TT_RELEASE_SAFELY(_photoListItems);
    TT_RELEASE_SAFELY(_queryAll);
    TT_RELEASE_SAFELY(_queryDict);
    TT_RELEASE_SAFELY(_commentCacheManager);

    TT_RELEASE_SAFELY(_loadingView);
    
    TT_RELEASE_SAFELY(_headerView);
    TT_RELEASE_SAFELY(_postFollow);
    TT_RELEASE_SAFELY(_subscribe);
    TT_RELEASE_SAFELY(_actionMenuController);
    TT_RELEASE_SAFELY(_contentMoreController);
    TT_RELEASE_SAFELY(_shareComment);
    TT_RELEASE_SAFELY(_shareContent);
    TT_RELEASE_SAFELY(_replyComment);
    TT_RELEASE_SAFELY(_postCommentController);
    
    TT_RELEASE_SAFELY(_newsModel);
    TT_RELEASE_SAFELY(_rollingNewsList);
    TT_RELEASE_SAFELY(_pinchGesture);
    TT_RELEASE_SAFELY(_referFrom);
    
    
    if (_recommendIds) {
        TT_RELEASE_SAFELY(_recommendIds);
    }
    
    if (_slideshowController) {
        _slideshowController.delegate = nil;
        TT_RELEASE_SAFELY(_slideshowController);
    }
    _fadeInView = nil;
    
    TT_RELEASE_SAFELY(_analyticsTimer);
    
    _actionMenuController.delegate = nil;
    TT_RELEASE_SAFELY(_actionMenuController);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - model
- (void)createModel
{
    //photoListModel
    self.photoListModel = [[[SNPhotoListModel alloc] initWithTermId:self.termId
                                                            newsId:self.newsId
                                                         channelId:self.channelId
                                                      isOnlineMode:_isOnlineMode
                                                          userInfo:self.queryDict] autorelease];
    self.photoListModel.delegate = self;
    
    //commentListModel
    SNCommentRequestType type = 0;
    if ([kDftSingleGalleryTermId isEqualToString:self.termId]) {
        type = SNCommentRequestTypeGid;
    }
    else {
        type = SNCommentRequestTypeNewsId;
    }
    self.commentListManager = [[[SNCommentListManager alloc] initWithId:self.newsId requestType:type] autorelease];
    [self setCommentListBlocks];
    
    NSString *link = [_queryDict stringValueForKey:kLink defaultValue:nil];
    if (link) {
        NSRange range = [link rangeOfString:@"://"];
        if (range.length > 0) {
            NSString *schema = [link substringToIndex:range.location + range.length];
            NSMutableDictionary *dic = [SNUtility parseProtocolUrl:link schema:schema];
            self.commentListManager.userInfo = dic;
        }
    }
}

- (void)resetModel {
    self.photoListModel = [[[SNPhotoListModel alloc] initWithTermId:self.termId
                                                            newsId:self.newsId
                                                         channelId:self.channelId
                                                      isOnlineMode:_isOnlineMode
                                                          userInfo:self.queryDict] autorelease];
    self.photoListModel.delegate = self;
    
    SNCommentRequestType type = 0;
    if ([kDftSingleGalleryTermId isEqualToString:self.termId]) {
        type = SNCommentRequestTypeGid;
    }
    else {
        type = SNCommentRequestTypeNewsId;
    }
    self.commentListManager = [[[SNCommentListManager alloc] initWithId:self.newsId requestType:type] autorelease];
    [self setCommentListBlocks];
}

- (void)setCommentListBlocks
{
    __block SNPhotoListController *wself = self;
    self.commentListManager.requestFinishedBlock = ^() {
        if (!wself) {
            return;
        }
        [wself setCommentNumEnble];
        [wself setDataSource];
        if ([wself.newsId isEqualToString:wself.lastNewsId]) {
            [wself setReadCount];
            [wself.photoTextTable reloadData];
        }
    };
    
    self.commentListManager.requestFailedBlock = ^() {
        if (!wself) {
            return;
        }
        [wself setCommentNumEnble];
        [wself setReadCount];
    };
}

- (void)enableSwipeGesture:(BOOL)bEnable {
    _swipeLeft.enabled = bEnable;
}

#pragma mark - gestureRecognizer
- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (_isFullScreenMode)
        {
            [self exitFullScreenModeWithAnimation:NO];
        }
        [_postFollow changeUserName];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        //需要切换页面
        if(_commonNewsController!=nil && [_commonNewsController swithController:[self newsId] type:_type])
            return;
        //推荐
        else if(_commonNewsController!=nil && [_commonNewsController swithControllerInPhotoRecommand:[self newsId]])
            return;
        //报纸里的连续阅读
        else if(_commonNewsController!=nil && [self isInNewsPaper] && [_commonNewsController swithControllerInNewsPaper:[self getNextNewsLink2] current:self])
        {
            return;
        }
        else if(_commonNewsController!=nil && [self isInNewsPaper] && [_commonNewsController swithControllerInNewsPaper:[self getNextNewsLink] current:self])
        {
            return;
        }
        
        NSString *nextId = [self getNextPhotoNewsId];
        if(nextId.length > 0)
        {
            [self openListAtNewsId:nextId];
            [_postFollow setCommentBtnLoading:YES];
        }
        else
        {
            if (_supportNext) {
                [SNNotificationCenter showMessage:NSLocalizedString(@"AlreadyLastNews", @"Already last news")];
            }
        }
    }
}

-(void)handlePinchFrom:(UIPinchGestureRecognizer*)pinch
{
    if(pinch.state == UIGestureRecognizerStateEnded)
    {
        if(pinch.scale > pinchScale)
        {
            [SNUtility setBiggerFontSize];
        }
        else if(pinch.scale < pinchScale)
        {
            [SNUtility setSmallerFontSize];
        }
    }
    else if(pinch.state == UIGestureRecognizerStateBegan)
    {
        pinchScale = pinch.scale;
    }
}

//连续阅读
- (NSString *)getPrePhotoNewsId
{
    if (_gallerySourceType == GallerySourceTypeGroupPhoto)
    {
        int index = [self.rollingNewsList indexOfObject:[self newsId]];
        NSString *nId = nil;
        if (index != NSNotFound && index > 0 && index < self.rollingNewsList.count)
        {
            nId = [self.rollingNewsList objectAtIndex:index - 1];
        }
        return nId;
    }
    else if (_gallerySourceType == GallerySourceTypeRecommend)
    {
        NSUInteger index = [_recommendIds indexOfObject:[self newsId]];
        NSString *nId = nil;
        if (index != NSNotFound && index > 0 && index < _recommendIds.count) {
            nId = [_recommendIds objectAtIndex:index - 1];
        }
        return nId;
    }
    else if (_gallerySourceType == GallerySourceTypeNewsPaper)
    {
        NSString *preId = self.photoListModel.photoList.preId;
        return preId.length > 0 ? preId : nil;
    }
    else
    {
        return nil;
    }
}

- (NSString *)getNextPhotoNewsId
{
    if (_gallerySourceType == GallerySourceTypeGroupPhoto)
    {
        int index = [self.rollingNewsList indexOfObject:[self newsId]];
        NSString *nId = nil;
        if (index != NSNotFound && index >= 0 && index < self.rollingNewsList.count - 1)
        {
            nId = [self.rollingNewsList objectAtIndex:index + 1];
        }
        return nId;
    }
    else if ( _gallerySourceType == GallerySourceTypeRecommend)
    {
        NSString *nextGid = self.photoListModel.nextGid;
        NSUInteger index = [_recommendIds indexOfObject:nextGid];
        if (nextGid && NSNotFound == index)
        {
            [_recommendIds addObject:nextGid];
        }
        return nextGid;
    }
    else if (_gallerySourceType == GallerySourceTypeNewsPaper)
    {
        NSString *nextId = self.photoListModel.photoList.nextId;
        return nextId.length > 0 ? nextId : nil;
    }
    else
    {
        return nil;
    }
}

- (BOOL)isInNewsPaper
{
    return _gallerySourceType == GallerySourceTypeNewsPaper;
}

-(NSString*)getNextNewsLink
{
    NSString *nextId = self.photoListModel.photoList.nextNewsLink;
    return nextId;
}

-(NSString*)getNextNewsLink2
{
    NSString *nextId = self.photoListModel.photoList.nextNewsLink2;
    return nextId;
}

- (void)openListAtNewsId:(NSString *)newsId
{
    self.newsId   = newsId;
    
    _isModeRefreshed = YES;
}

#pragma mark -
#pragma mark SNArticleRecomServiceDelegate

- (void)getRecommendNewsSucceed
{
    [_photoTextTable reloadData];
}

#pragma mark - fullScreen
- (void)toggleFullscreen
{
    if (_isFullScreenMode) {
        [self exitFullScreenModeWithAnimation:YES];
    } else {
        [self enterFullScreenMode];
    }
}

-(void)fullScreenModeAnimationStopped {
    _isFullScreenMode = !_isFullScreenMode;
    _animationStopped = YES;
}

- (void)enterFullScreenMode {
    SNDebugLog(@"enterFullScreenMode");
    
    if (_isFullScreenMode || !_animationStopped) {
        return;
    }
    _animationStopped = NO;
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kNewsSlideDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fullScreenModeAnimationStopped)];

    [_postFollow show:NO];
    [UIView commitAnimations];
}

- (void)exitFullScreenModeWithAnimation:(BOOL)animate {
    
    SNDebugLog(@"exitFullScreenModeWithAnimation %d", animate);
    
    if (!_isFullScreenMode || !_animationStopped) {
        //        _scrolledByUser = YES;
        return;
    }
    if (animate) {
        _animationStopped = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kNewsSlideDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fullScreenModeAnimationStopped)];
    }

    [_postFollow show:YES];
    
    if (animate) {
        [UIView commitAnimations];
    } else {
        _isFullScreenMode = NO;
    }
}

- (BOOL)scorllViewToBottom:(UIScrollView*)scrollView
{
    float Offset = scrollView.contentOffset.y + TTApplicationFrame().size.height;
    float content = scrollView.contentSize.height;
    return  (Offset > (content - 100) ? YES:NO);
}

// scrollView已滚动到底部，又继续向上拖拽一定距离
- (BOOL)scorllViewToBottomEx:(UIScrollView*)scrollView
{
    float Offset = scrollView.contentOffset.y + TTApplicationFrame().size.height;
    float content = scrollView.contentSize.height;
    return  (Offset > (content + 70) ? YES:NO);
}

- (void)userDidScrolled:(BOOL)scrollDown scrollView:(UIScrollView *)scrollView lastVerticalOffset:(float)lastVerticalOffset
{
    BOOL canToggleFullScreenMode = [SNUtility getApplicationDelegate].autoFullscreenMode && (scrollView.contentSize.height > scrollView.frame.size.height * 1.5f);
    
    if (canToggleFullScreenMode) {
        float offSet = scrollView.contentOffset.y - lastVerticalOffset;
        BOOL isNotBounceToBottom = lastVerticalOffset != (scrollView.contentSize.height - TTNavigationFrame().size.height);
        
        if (scrollDown && !_isFullScreenMode && isNotBounceToBottom && ![self scorllViewToBottom:scrollView]) {
            if (offSet > 3.0 &&
                _animationStopped &&
                !_postFollow._isTouchTxtField)
            {
                [self enterFullScreenMode];
            }
        }
        else if (!scrollDown &&
                 _isFullScreenMode&&
                 !_postFollow._isTouchTxtField) {
            BOOL bBottom = [self scorllViewToBottom:scrollView];
            BOOL bBottomEx = [self scorllViewToBottomEx:scrollView];
            
            if (_animationStopped) {
                if ((offSet <-2.0 && !bBottom) ||
                    scrollView.contentOffset.y<=0.5 ||
                    bBottomEx) {
                    [self exitFullScreenModeWithAnimation:YES];
                }
            }
        }
    }
}

#pragma mark - UITableViewDatasource & UITableViewDelegate
- (void)setDataSource
{
    __block SNPhotoListController* wself = self;
    if (!wself) {
        return;
    }
    
    wself.photolistDataSource.photoItems = wself.photoListModel.photoListItems;
    wself.photolistDataSource.photoCount = wself.photoListModel.photoListItems.count;
    wself.photolistDataSource.subId = wself.photoListModel.photoList.subId;
    wself.photolistDataSource.subscribe = [[SNDBManager currentDataBase]
                                          getSubscribeCenterSubscribeObjectBySubId:wself.photoListModel.photoList.subId];
    wself.photolistDataSource.recommendItems = _recommendService.recommendArray;
    wself.photolistDataSource.recmdCount = _recommendService.recommendArray.count;
    wself.photolistDataSource.sdkAdState = wself.photoListModel.sdkAdNewsRecommend.dataState;
    wself.photolistDataSource.commentItems = wself.commentListManager.commentItems;
    wself.photolistDataSource.cmtCount = wself.commentListManager.comtItemsCount;
    
    if (_gallerySourceType == GallerySourceTypeNewsPaper) {
        wself.photolistDataSource.refer = REFER_PAPER;
    } else {
        wself.photolistDataSource.refer = REFER_ROLLINGNEWS;
    }

    self.photolistDataSource.scrollBlock = ^(UIScrollView *scrollView){
        [wself scrollViewDidScroll:scrollView];
    };
    self.photolistDataSource.cellDisplayBlock = ^(UITableViewCell *cell){
        [wself willDisplayCell:cell];
    };
    self.photolistDataSource.imageClickBlock = ^(id sender) {
        [wself clickImage:sender];
    };
    self.photolistDataSource.tableReload = ^() {
        [wself.photoTextTable reloadData];
    };
    self.photolistDataSource.replyComment = ^(SNNewsComment *comment, SNCommentSendType type) {
        [wself replyComment:comment replyType:type];
    };
    self.photolistDataSource.shareComment = ^(SNNewsComment *comment) {
        [wself shareComment:comment];
    };
    self.photolistDataSource.showComtImage = ^(NSString *urlPath) {
        [wself showImageWithUrl:urlPath];
    };
}

- (void)willDisplayCell:(UITableViewCell *)cell {
    __block SNPhotoListController* wself = self;
    
    if ([cell isKindOfClass:[SNCommentListCell class]])
    {
        if (!_isSendCount)
        {
            [SNAnalytics statisticalCommentAction:wself.newsId gid:nil];
            _isSendCount = YES;
        }
    }
    if ([cell isKindOfClass:[SNPhotoListSubscribeCell class]]) {
        // 3.7 阅读时常统计 只要显示了所属刊物 就认为读者已经看完了整篇文章
        if (wself.analyticsTimer && !wself.analyticsTimer.isEnd) {
            wself.analyticsTimer.isEnd = YES;
        }
    }
}

#pragma mark -
#pragma mark SNPhotoFavModelDelegate
-(void)favRequestWillStart {
    //    [_postFollow showLoadingAt:2];
}

-(void)favRequestFinished:(int)statusCode {
    //    [_postFollow hideLoadingAt:2];
    NSString *msg = nil;
    switch (statusCode) {
        case 1:
        {
            int likeCount = [self.photoListModel.photoList.likeCount intValue];
            [[SNDBManager currentDataBase]
             updateGalleryAsLikeByTermId:self.termId newsId:self.newsId likeCount:[NSString stringWithFormat:@"%d",likeCount+1]];
            if (self.delegateController && [self.delegateController respondsToSelector:@selector(changeFavoriteNum:favNum:)]) {
                [self.delegateController changeFavoriteNum:self.newsId favNum:likeCount+1];
            }
            msg = [NSString stringWithFormat:NSLocalizedString(@"favoriteSuccess", @""), likeCount+1];
            //                [_postFollow stateSelected:2];
        }
            break;
        case 2:
            msg = NSLocalizedString(@"favoriteDuplicate", @"");
            //            [_postFollow stateSelected:2];
            break;
        case 3:
            msg = NSLocalizedString(@"favoriteFailed", @"");
            break;
        case 4:
            msg = NSLocalizedString(@"favoriteUnsuported", @"");
            break;
        default:
            break;
    }
    [SNNotificationCenter showMessage:msg hideAfter:2];
}


#pragma mark - commentListAction
//回复
- (void)replyComment:(SNNewsComment *)comment replyType:(SNCommentSendType)type
{
    __block SNPhotoListController *wself = self;
    wself.replyComment = comment;
    commentType = type;
    
    [wself presentCommentEidtorController];
}


//分享
- (void)shareComment:(SNNewsComment *)comment
{
    __block SNPhotoListController *wself = self;
    wself.shareComment = comment;
    [wself doShare:ShareSubTypeComment];
}

#pragma mark - SNPhotoListModelDelegate
- (void)photoListModelDidFinishLoadRecommendAds {
    [_photoTextTable reloadData];
}

- (void)photoListModelDidStartLoad
{
}

- (void)photoListModelDidFinishLoad
{
    if ([self.newsId isEqualToString:self.lastNewsId]) {
        _isCommentLoading = NO;
        [self hideLoading];
        
        // chh: 淡入内容
        if (_fadeInView) {
            _fadeInView.alpha = 1;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            _fadeInView.alpha = 0;
            [UIView commitAnimations];
        }
        
        _postFollow._textField.enabled = YES;
        [_postFollow setButton:3 enabled:YES];
    }
    
    CGFloat screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    GalleryItem *gallery  = self.photoListModel.photoList;
    SNPhotoListHeaderView *aHeaderView = [[SNPhotoListHeaderView alloc] initWithTitle:gallery.title
                                                                                 time:gallery.time
                                                                                 from:gallery.from
                                                                            likeCount:gallery.likeCount
                                                                             delegate:self
                                                                                frame:CGRectMake(0, 0, screenWidth, 0)];
    
    self.headerView = aHeaderView;
    [aHeaderView release];
    _photoTextTable.tableHeaderView  = self.headerView;
    [self setDataSource];
    
    [_photoTextTable reloadData];
    
    
    if (![self.newsId isEqualToString:self.lastNewsId]) {
        [self.commentListManager resetData];
    }
    
    [self.commentListManager loadData:NO];
}

- (void)photoListModelDidFailToLoadWithError:(NSError*)error
{
    [self setDataSource];
    if (![self.newsId isEqualToString:self.lastNewsId]) {
        return;
    }
    
    [self showError];
    
    _isIndexChanged = NO;
    _postFollow._textField.enabled = NO;
    [_postFollow setButton:2 enabled:NO];
    [_postFollow setButton:3 enabled:NO];
}

#pragma mark - photoTextCellDelegate
- (void)clickImage:(id)sender
{
    __block SNPhotoListController* wself = self;
    _photoTextTable.scrollsToTop = NO;
    SNPhotoListTableCell  *_selectedCell  = (SNPhotoListTableCell*)sender;
    if (_slideshowController /*|| ![_selectedCell.item.photo.path length]*/)
    {
        return;
    }
    self.returnIndex = [_photoTextTable indexPathForCell:_selectedCell];
    
    SNPhotoSlideshow *slideshow = [[[SNPhotoSlideshow alloc] initWithGalleryItem:self.photoListModel.photoList isOnlineMode:_isOnlineMode] autorelease];
    
    slideshow.channelId = self.photoListModel.channelId;
    slideshow.termId = self.photoListModel.termId;
    slideshow.sdkAdLastPic = self.photoListModel.sdkAdLastPic;
    slideshow.sdkAdLastRecommend = self.photoListModel.sdkAdLastRecommend;
    
    SNPhotoGallerySlideshowController *photoCtl = [[[SNPhotoGallerySlideshowController alloc] initWithGallery:slideshow] autorelease];
    if (_isCommentNumLoad)
    {
        slideshow.commentNum = self.commentListManager.commentCount;
    }
    wself.slideshowController = photoCtl;
    wself.slideshowController.delegate = wself;
    wself.slideshowController.allItems = wself.rollingNewsList;
    wself.slideshowController.newsModel = wself.newsModel;
    if ([wself.termId isEqualToString:kDftChannelGalleryTermId]) {
        wself.slideshowController.gallerySourceType = GallerySourceTypeGroupPhoto;
    } else {
        wself.slideshowController.gallerySourceType = GallerySourceTypeNewsPaper;
    }
    wself.slideshowController.termId = wself.termId;
    
    //---------
    GalleryItem *gallery = self.photoListModel.photoList;
    
    wself.slideshowController.pubDate = gallery.time;
    
    SNDebugLog(@"_termId: %@, _myFavouriteRefer:%d", _termId, _myFavouriteRefer);
    
    //刊物组图PhotoList进入PhotoSlideShow
    if (_termId && ![_termId isEqualToString:kDftChannelGalleryTermId]) {
        wself.slideshowController.myFavouriteReferInSlideShow = _myFavouriteRefer;
    }
    //滚动新闻的组图PhotoList进入PhotoSlideShow
    else if (_channelId) {
        wself.slideshowController.myFavouriteReferInSlideShow = _myFavouriteRefer;
    }
    //---特殊处理推荐组图
    if (!!_recommendPhotoListOpenAction) {
        wself.slideshowController.myFavouriteReferInSlideShow = _recommendPhotoListOpenAction.myFavoriteRefer;
    }
    //------
    
    BOOL bShow = [_slideshowController showPhotoByIndex:_selectedCell.item.index
                                               fromRect:[_selectedCell getImageRect]
                                                 inView:wself.view animated:YES];
    if (!bShow) {
        SNDebugLog(@"SNPhotoListController - clickImage : showPhotoByIndex failed,index = %d", _selectedCell.item.index);
        _slideshowController.delegate = nil;
        TT_RELEASE_SAFELY(_slideshowController);
    } else {
        [self getTopNavigation].view.userInteractionEnabled = NO;
        _swipeLeft.enabled = NO;
        _pinchGesture.enabled = NO;
    }
}

#pragma mark SNGroupPicturesSlideshowViewControllerDelegate
- (void)slideshowWillShow:(SNGroupPicturesSlideshowContainerViewController *)slideshowController
{
    SNPhotoListTableCell  *_selectedCell = (SNPhotoListTableCell  *)[_photoTextTable cellForRowAtIndexPath:self.returnIndex];
    if (_selectedCell) {
        [_selectedCell showImage:NO];
    }
}

- (void)slideshowDidShow:(SNGroupPicturesSlideshowContainerViewController *)slideshowController
{
    [self getTopNavigation].view.userInteractionEnabled = YES;
    _isSlideShowMode = YES;
}

- (void)slideshowDidChange:(SNGroupPicturesSlideshowContainerViewController *)slideshowController photoIndex:(int)index
{
    if (_returnIndex && _returnIndex.row != index) {
        SNPhotoListTableCell  *_selectedCell = (SNPhotoListTableCell  *)[_photoTextTable cellForRowAtIndexPath:self.returnIndex];
        if (_selectedCell) {
            [_selectedCell showImage:YES];
        }
        self.returnIndex = [NSIndexPath indexPathForRow:index inSection:SNPLTableSectionPhoto];
        SNPhotoListTableCell  *_newSelectedCell = (SNPhotoListTableCell  *)[_photoTextTable cellForRowAtIndexPath:self.returnIndex];
        if (_newSelectedCell && [_newSelectedCell isKindOfClass:[SNPhotoListSubscribeCell class]]) {
            [_newSelectedCell showImage:NO];
        }
        _isIndexChanged = YES;
    }
}

- (CGRect)slideshowPhotoFrameShouldReturn:(SNPhotoGallerySlideshowController *)slideshowController photoIndex:(int)index
{
    if (slideshowController == nil) {
        SNDebugLog(@"SNPhotoListController - slideshowPhotoFrameShouldReturn : Invalid slideshowController");
        return CGRectMake(0, 0, 0, 0);
    }
    
    SNPhotoListModel *model = self.photoListModel;
    if (index < 0 || index >= [model.photoList.gallerySubItems count]) {
        SNDebugLog(@"SNPhotoListController - slideshowPhotoFrameShouldReturn : Invalid index = %d", index);
        return CGRectMake(0, 0, 0, 0);
    }
    
    NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:index inSection:0];
    SNPhotoListTableCell *cell = (SNPhotoListTableCell*)[_photoTextTable cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        SNDebugLog(@"SNPhotoListController - slideshowPhotoFrameShouldReturn : Invalid cell for index = %d", index);
        return CGRectMake(0, 0, 0, 0);
    }
    
    return [cell getImageRect];
}

- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController galleryId:(NSString *)gid
{
    if (gid && [gid length])
    {
        self.lastNewsId = self.newsId;
        self.newsId = gid;
        self.termId = kDftSingleGalleryTermId;
        _isCommentNumLoad = NO;
        _isCommentLoading = NO;
        //图像页切换到下一条新闻后重置新闻model
        [self resetModel];
        [self refreshPhotoTextListModel];
        //[self invalidateModel];
        _isWaitingLoadingGid = YES;
    }
}

- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController termId:(NSString *)termId newsId:(NSString *)newsId
{
    self.lastNewsId = self.newsId;
    self.newsId = newsId;
    self.termId = termId;
    _isCommentNumLoad = NO;
    _isCommentLoading = NO;
    
    //图像页切换到下一条新闻后重置新闻model
    [self resetModel];
    [self refreshPhotoTextListModel];
    
    _isWaitingLoadingGid = YES;
}

- (void)slideshowWillDismiss:(SNGroupPicturesSlideshowContainerViewController *)slideshowController
{
    if (![self.lastNewsId isEqualToString:self.newsId]) {
        [_photoTextTable reloadData];
        SNPhotoListModel *model = self.photoListModel;
        
        GalleryItem *gallery  = model.photoList;
        CGFloat screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        SNPhotoListHeaderView *aHeaderView = [[SNPhotoListHeaderView alloc] initWithTitle:gallery.title
                                                                                     time:gallery.time
                                                                                     from:gallery.from
                                                                                likeCount:nil
                                                                                 delegate:self
                                                                                    frame:CGRectMake(0, 0, screenWidth, 0)];
        
        self.headerView = aHeaderView;
        [aHeaderView release];
        _photoTextTable.tableHeaderView  = self.headerView;
        
        if (self.returnIndex && self.returnIndex.row < [model.photoList.gallerySubItems count])
        {
            [_photoTextTable scrollToRowAtIndexPath:self.returnIndex
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:NO];
            _isIndexChanged = NO;
        }
        _isCommentNumLoad = NO;
        _isCommentLoading = NO;
        self.lastNewsId = self.newsId;
    }
    
    [self getTopNavigation].view.userInteractionEnabled = NO;
    if (_isWaitingLoadingGid)
    {
        _isWaitingLoadingGid = NO;
    }
    else if (_isIndexChanged)
    {
        SNPhotoListModel *model = self.photoListModel;
        if (self.returnIndex && self.returnIndex.row < [model.photoList.gallerySubItems count])
        {
            [_photoTextTable scrollToRowAtIndexPath:self.returnIndex
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:NO];
            _isIndexChanged = NO;
        }
    }
    if (_isFullScreenMode)
    {
        [self exitFullScreenModeWithAnimation:YES];
    }
}

- (void)slideshowDidDismiss:(SNGroupPicturesSlideshowContainerViewController *)slideshowController
{
    if (_slideshowController) {
        _slideshowController.delegate = nil;
        TT_RELEASE_SAFELY(_slideshowController);
    }
    
    SNPhotoListTableCell  *_selectedCell = (SNPhotoListTableCell  *)[_photoTextTable cellForRowAtIndexPath:self.returnIndex];
    if (_selectedCell) {
        [_selectedCell showImage:YES];
    }
    _photoTextTable.scrollsToTop = YES;
    
    [self getTopNavigation].view.userInteractionEnabled = YES;
    _swipeLeft.enabled = YES;
    _pinchGesture.enabled = YES;
    _isSlideShowMode = NO;
}

#pragma mark - favourite
- (void)actionmenuDidSelectLikeBtn
{
    [self addOrRemoveMyFavourite];
}

- (void)addOrRemoveMyFavourite
{
    GalleryItem *gallery = self.photoListModel.photoList;
    
    SNGroupPicturesContentFavourite *groupPicturesContentFavourite = [[SNGroupPicturesContentFavourite alloc] init];
    groupPicturesContentFavourite.title = gallery.title;
    groupPicturesContentFavourite.publicationDate = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
    
    //取第一张图的地址；注意：这里的URL内容在PhotoListModel层会根据在线模式或离线内容来动态设内容，
    //所以用户在离线内容里收藏时url值是本地路径，实时阅读时url值是http打头的真实URL值；
    if ([gallery.gallerySubItems count] > 0)
    {
        PhotoItem *photo = gallery.gallerySubItems[0];
        if (![@"" isEqualToString:photo.url])
        {
            groupPicturesContentFavourite.imageUrl = photo.url;
        }
    }
    groupPicturesContentFavourite.type = _myFavouriteRefer;
    groupPicturesContentFavourite.contentLevelSecondID = _newsId;
    
    if (_channelId)
    {
        //MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS 滚动新闻组图进入PhotoList
        //也报过推荐来的  MYFAVOURITE_REFER_RECOMMEND_NEWS_IN_CHANNEL
        groupPicturesContentFavourite.contentLevelFirstID = _channelId;
    }
    
    [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:groupPicturesContentFavourite];
    [groupPicturesContentFavourite release];
}

#pragma mark - openCommentImage
- (void)showImageWithUrl:(NSString *)urlPath {
    [self.commentListManager showImageWithUrl:urlPath];
}

#pragma mark - private method
- (void)pushNotificationWillCome:(NSNotification *)notification
{
    [self exitFullScreenModeWithAnimation:NO];
}

- (UIViewController*)getTopController
{
    return [TTNavigator navigator].topViewController;
}

- (SNNavigationController*)getTopNavigation
{
    return [TTNavigator navigator].topViewController.flipboardNavigationController;
}

- (void)setCommentNum:(NSString *)count
{
    if (count.length > 0 && [count intValue] > 0) {
        [_postFollow setCommentNum:count];
    } else {
        [_postFollow setCommentNum:@"0"];
    }
}

- (void)setCommentNumEnble
{
    __block SNPhotoListController *wself = self;
    if (!_isCommentNumLoad) {
        [_postFollow setButton:2 enabled:YES];
        [wself setCommentNum:self.commentListManager.commentCount];
        if (wself.commentListManager.commentCount.length > 0 &&
            [wself.commentListManager.commentCount intValue] > 0) {
            _isCommentNumLoad = YES;
        }
    }
}

- (void)setReadCount
{
    __block SNPhotoListController* wself = self;
    if([wself.commentListManager.readCount length] > 0 && [wself.commentListManager.readCount intValue] > 0 && !_isShowReadCount)
    {
        [wself.headerView setReadCount:wself.commentListManager.readCount];
        _isShowReadCount = YES;
    }
}

- (void)showCommentList
{
    GalleryItem *gallery = self.photoListModel.photoList;
    NSString *content = gallery.shareContent;
    NSMutableDictionary *newsInfo = [NSMutableDictionary dictionary];
    if (gallery.title.length > 0) {
        [newsInfo setObject:gallery.title forKey:kCommentListKeyNewsTitle];
    }
    if (gallery.time.length > 0) {
        [newsInfo setObject:gallery.time forKey:kCommentListKeyNewsTime];
    }
    
    if (gallery.from.length > 0) {
        [newsInfo setObject:gallery.from forKey:kCommentListKeyNewsSource];
    }
    
    if (self.commentListManager.readCount.length > 0) {
        [newsInfo setObject:self.commentListManager.readCount forKey:kCommentListKeyNewsReadCount];
    }
    
    if (gallery.stpAudCmtRsn.length > 0) {
        [newsInfo setObject:gallery.stpAudCmtRsn forKey:kCommentListKeyNewsStopAudio];
    }
    
    if (self.queryAll) {
        [newsInfo setObject:self.queryAll forKey:kCommentListKeyNewsQuery];
    }
    [newsInfo setObject:@"0" forKey:kCommentListKeyIsAuthor];
    if (content.length > 0) {
        [newsInfo setObject:content forKey:kCommentListKeyShareContent];
    }
    [newsInfo setObject:KCommentTypeLatest forKey:kCommentListkeyRequestType];
    
    if(self.newsId.length > 0) {
        if([kDftSingleGalleryTermId isEqualToString:self.termId]) {
            [newsInfo setObject:self.newsId forKey:kCommentListKeyGid];
        } else {
            [newsInfo setObject:self.newsId forKey:kCommentListKeyNewsId];
        }
    }
    if (gallery.cmtHint.length > 0) {
        [newsInfo setObject:gallery.cmtHint forKey:kCommentListKeyCmtHint];
    }
    if (gallery.cmtStatus.length > 0) {
        [newsInfo setObject:gallery.cmtStatus forKey:kCommentListKeyCmtStatus];
    }
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto
                                                                                         contentId:gallery.newsId];
    if (obj) {
        newsInfo[kCommentListKeyShareCmtObj] = obj;
    }
    [SNCommentListManager pushAllCommentListWithQuery:newsInfo];
}

- (void)refreshPhotoTextListModel
{
    [self.photoListModel load:TTURLRequestCachePolicyDefault more:YES];
}

- (UIViewController *)backToViewController
{
    return nil;
}

#pragma mark -
#pragma mark updateTheme
-(void)updateTheme {
    [self customerTableBg];
    [self.headerView updateTheme];
    [_postFollow updateTheme];
}

- (void)updateFontTheme
{
    for (SNPhotoListTableItem *photoItem in self.photoListModel.photoListItems) {
        photoItem.cellHeight = 0;
        [photoItem heightForPhotoListItem];
    }
    [self.commentListManager resetAllCommentCellHeight];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCellFontChangeNotification object:nil];
    [_photoTextTable reloadData];
}

#pragma mark - moreAction
- (void)moreAction
{
    SNContentMoreViewController *moreController = [[SNContentMoreViewController alloc]initWithFram:[UIScreen mainScreen].bounds];
    moreController.newsId = self.newsId;
    self.contentMoreController = moreController;
    [moreController release];
    self.contentMoreController.delegate = self;
    [self.contentMoreController showMenuView];
}

- (void)uninterested
{
    if ([[SNUtility getApplicationDelegate] checkNetworkStatus]) {
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
        [[SNAnalytics sharedInstance] realtimeReportCCAnalyzeWithCurrentPage:userTrack
                                                                      toPage:userTrack
                                                              byUserFunction:f_uninterested
                                                                 otherParams:nil];
        
        [SNNotificationCenter showMessage:@"以后不再为您推荐此类内容" hideAfter:1.3];
    } else {
        [SNNotificationCenter showMessage:@"网络连接失败" hideAfter:1.3];
    }
}

#pragma mark - shareAction
-(void)doShare:(ShareSubType)shareType
{
    __block SNPhotoListController *wself = self;
    wself.actionMenuController = [[[SNActionMenuController alloc] init] autorelease];
    _actionMenuController.shareSubType = shareType;
    _actionMenuController.delegate = wself;
    _actionMenuController.shareLogType = @"pics";
    _actionMenuController.contextDic = [wself createActionMenuContentContext];
    _actionMenuController.timelineContentType = SNTimelineContentTypePhoto;
    GalleryItem *gallery = wself.photoListModel.photoList;
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto
                                                                                         contentId:gallery.newsId];
    
    if (obj) {
        _actionMenuController.sourceType = obj.sourceType;
    } else {
        _actionMenuController.sourceType = 4;
    }
    _actionMenuController.timelineContentId = gallery.newsId;
    _actionMenuController.isLiked = [wself checkIfHadBeenMyFavourite];
    [_actionMenuController showActionMenu];
}

//分享选中文字
- (void)shareContent:(NSString*)content {
    
    NSMutableString *text = [NSMutableString stringWithString:@"["];
    if (content.length>0) {
        [text appendString:content];
    }
    
    [text appendString:@"] 分享来自：@搜狐新闻客户端"];
    GalleryItem *gallery    = self.photoListModel.photoList;
    if (gallery.title) {
        [text appendFormat:@" %@",gallery.title];
    }
    
    NSString *link = [SNUtility getLinkFromShareContent:gallery.shareContent];
    if (link) {
        [text appendFormat:@" %@",link];
    }
    self.shareContent = text;
    
    self.actionMenuController = [[[SNActionMenuController alloc] init] autorelease];
    _actionMenuController.shareSubType = ShareSubTypeQuoteText;
    _actionMenuController.shareLogType = @"pics";
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto
                                                                                         contentId:gallery.newsId];
    
    if (obj) {
        _actionMenuController.sourceType = obj.sourceType;
    } else {
        _actionMenuController.sourceType = 4;
    }
    _actionMenuController.timelineContentType = SNTimelineContentTypePhoto;
    _actionMenuController.timelineContentId = gallery.newsId;
    _actionMenuController.delegate = self;
    _actionMenuController.disableLikeBtn = YES; // 分享正文内容  禁用收藏按钮 @jojo
    [_actionMenuController showActionMenu];
    
}

#pragma mark -
#pragma mark ShareInfoController
- (NSMutableDictionary *)createActionMenuContentContext {
    
    __block SNPhotoListController *wself = self;
    //update by sampanli
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    
    GalleryItem *gallery = self.photoListModel.photoList;
    NSString *content = gallery.shareContent;
    NSString *title = gallery.title;

    if (content.length > 0) {
        [dicShareInfo setObject:content forKey:kShareInfoKeyContent];
    }
    else{
        [dicShareInfo setObject:@"" forKey:kShareInfoKeyContent];
    }
    
    [dicShareInfo setObject:[SNHtmlNoteWriter writePhotoList:gallery] forKey:kShareInfoKeyHtmlContent];
    
    if (wself.shareContent.length > 0) {
        [dicShareInfo setObject:self.shareContent forKey:kShareInfoKeyShareContent];
        wself.shareContent = nil;
    }
    
    if (title.length > 0) {
        [dicShareInfo setObject:title forKey:kShareInfoKeyTitle];
    }
    
    if ([gallery.gallerySubItems count] > 0) {
        PhotoItem *firstPhoto = [gallery.gallerySubItems objectAtIndex:0];
        
        if (firstPhoto.shareLink) {
            dicShareInfo[kShareInfoKeyNoteSourceURL] = firstPhoto.shareLink;
        }
        
        if ([firstPhoto.path length] != 0 && [[NSFileManager defaultManager] fileExistsAtPath:firstPhoto.path]) {
            [dicShareInfo setObject:firstPhoto.path forKey:kShareInfoKeyImagePath];
        }
        if ([firstPhoto.url length] > 0) {
            if (_isOnlineMode) {
                [dicShareInfo setObject:firstPhoto.url forKey:kShareInfoKeyImageUrl];
                
                if ([firstPhoto.path length] == 0) {
                    firstPhoto.path	= [[[SNDBManager currentDataBase] getCommonCachePath] stringByAppendingPathComponent:
                                   [[TTURLCache sharedCache] keyForURL:firstPhoto.url]];
                    if (firstPhoto.path && [[NSFileManager defaultManager] fileExistsAtPath:firstPhoto.path]) {
                        [dicShareInfo setObject:firstPhoto.path forKey:kShareInfoKeyImagePath];
                    }
                }
            }
            else {
                [dicShareInfo setObject:firstPhoto.url forKey:kShareInfoKeyImagePath];
                // todo 提供本地图片路径上传分享 目前接口不支持 不带图
                [dicShareInfo setObject:@"" forKey:kShareInfoKeyImageUrl];
            }
        }
        if ([firstPhoto.newsId length] > 0) {
            [dicShareInfo setObject:firstPhoto.newsId forKey:kShareInfoKeyNewsId];
        }
    }
    
    if (_actionMenuController.shareSubType == ShareSubTypeComment)
    {
        if (wself.shareComment.content.length > 0) {
            [dicShareInfo setObject:wself.shareComment.content forKey:kShareInfoKeyShareComment];
        }
        wself.shareComment = nil;
        _actionMenuController.shareLogType = @"comment";
    }

    return dicShareInfo;
}

- (BOOL)checkIfHadBeenMyFavourite
{
    SNGroupPicturesContentFavourite *groupPicturesContentFavourite = [[[SNGroupPicturesContentFavourite alloc] init] autorelease];
    groupPicturesContentFavourite.type = _myFavouriteRefer;
    groupPicturesContentFavourite.contentLevelSecondID = _newsId;
    
    if (_channelId)
    {
        //滚动新闻进入组图PhotoList  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS
        //也报过推荐来的,不把推荐做特殊处理
        groupPicturesContentFavourite.contentLevelFirstID = _channelId;
    }
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:groupPicturesContentFavourite];
}

#pragma mark - recommendCellDelegate
- (void)openRecommendGallery:(id)sender
{
    RecommendGallery *recommendGallery  = (RecommendGallery*)sender;
    
#ifdef COMMON_NEWS_PUSH_INTO_NEXT
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:recommendGallery.termId forKey:kTermId];
    [userInfo setObject:recommendGallery.newsId forKey:kNewsId];
    
    [userInfo setObject:kNewsOnline forKey:kNewsMode];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kisFromRelatedNewsList];
    [userInfo setObject:self.newsId forKey:kRecommendFromNewsId];
    
    NSArray* recommendPhotoList = self.photoListModel.photoList.moreRecommends;
    if(recommendPhotoList!=nil)
        [userInfo setObject:recommendPhotoList forKey:kRecommendNewsIDList];
    
    NSMutableDictionary* dic = [[[SNCommonNewsDatasource getPhotoListRecommandDictionary:userInfo] retain] autorelease];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:urlAction];
#else
    //为了区别是打开推荐组图
    TT_RELEASE_SAFELY(_recommendPhotoListOpenAction);
    _recommendPhotoListOpenAction = [[SNRecommendPhotoListOpenAction alloc] init];
    _recommendPhotoListOpenAction.myFavoriteRefer = MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_ROLLINGNEWS_PHOTOLIST;
    _recommendPhotoListOpenAction.contentLevelOneID = @"0";
    
    //执行打开操作
    SNDebugLog(@"SNPhotoListController - openRecommendGallery : title  = %@, self.termId=%@",recommendGallery.title, self.termId);
    
    self.termId   = recommendGallery.termId;
    self.newsId   = recommendGallery.newsId;
    
    if (recommendIds) {
        TT_RELEASE_SAFELY(recommendIds);
    }
    recommendIds = [[NSMutableArray array] retain];
    [recommendIds addObject:self.newsId];
    
    _gallerySourceType = GallerySourceTypeRecommend;
    
    _isRecommend = YES;
    
    //暂定推荐组图都是在线的
    _isOnlineMode   = YES;
    _isModeRefreshed = YES;
    [self invalidateModel];
#endif
}

#pragma mark - PostFollowDelegate
- (void)postFollow:(SNPostFollow*)postFollow andButtonTag:(int)iTag
{
    switch (iTag)
    {
        case 1: {
            [_postFollow changeUserName];
            break;
        }
        case 2: {
            [self performSelector:@selector(showCommentList)];
            break;
        }
        case 3: {
            [self doShare:ShareSubTypeQuoteCard];
            break;
        }
        case 4: {
            [self moreAction];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Post Comment
- (void)postFollowEditor
{
    self.replyComment = nil;
    [self textFieldDidBeginAction];
}

- (void)textFieldDidBeginAction
{
    GalleryItem *gallery = self.photoListModel.photoList;
    BOOL needLogin = [SNSubscribeCenterService shouldLoginForSubscribeWithSubId:gallery.subId];
    if (needLogin)
    {
        [SNGuideRegisterManager showGuideWithMediaComment:gallery.subId];
    }
    else
    {
        [self presentCommentEidtorController];
    }
}

- (void)guideLoginSuccess
{
    [self presentCommentEidtorController];
}

- (void)presentCommentEidtorController
{
    __block SNPhotoListController *wself = self;
    
    GalleryItem *gallery = wself.photoListModel.photoList;
    NSString *controlStaus = (wself.commentListManager.comtStatus.length > 0 ?
                              wself.commentListManager.comtStatus :
                              gallery.cmtStatus);
    NSString *controlHint  =  (wself.commentListManager.comtHint.length > 0 ?
                               wself.commentListManager.comtHint :
                               gallery.cmtHint);
    if (!_commentCacheManager) {
        self.commentCacheManager = [[[SNCommentCacheManager alloc] init] autorelease];
    }

    if (![SNUtility needCommentControlTip:controlStaus
                            currentStatus:kCommentStsForbidAll
                                      tip:controlHint
                                 isBottom:YES]) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        //发评论数据结构
        SNSendCommentObject *cmtObj = [[SNSendCommentObject new] autorelease];
        if (controlStaus.length > 0) {
            [dic setObject:controlStaus forKey:kEditorKeyComtStatus];
        }
        if (controlHint.length > 0) {
            [dic setObject:controlHint forKey:kEditorKeyComtHint];
        }
        //缓存评论
        if (wself.commentCacheManager.cacheCommentObj > 0) {
            [dic setObject:wself.commentCacheManager.cacheCommentObj forKey:kEditorKeyCacheComment];
        }
        
        NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeShowAll];
        if (self.commentListManager.stpAudCmtRsn.length > 0)
        {
            toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeTextAndCam];
        }
        [dic setObject:toolbarType forKey:kCommentToolBarType];
        
        if (self.replyComment && self.replyComment.author.length > 0)
        {
            cmtObj.replyName = wself.replyComment.author;
        }

        if (self.newsId.length > 0) {
            cmtObj.newsId = wself.newsId;
        }
        
        if ([kDftGroupGalleryTermId isEqualToString:_termId]) {
            cmtObj.gid = wself.newsId;
        } else if ([kDftChannelGalleryTermId isEqualToString:_termId]) {
            cmtObj.newsId = wself.newsId;
        } else {
            cmtObj.newsId = wself.newsId;
        }

        // 评论来源统计
        if (_gallerySourceType == GallerySourceTypeNewsPaper) {
            cmtObj.refer = REFER_PAPER;
        } else {
            cmtObj.refer = REFER_ROLLINGNEWS;
        }
        
        //回复评论数据结构
        cmtObj.replyComment = [SNNewsComment createReplyComment:wself.replyComment replyType:commentType];
        if (cmtObj) {
            [dic setObject:cmtObj forKey:kEditorKeySendCmtObj];
        }
        
        SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto
                                                                                             contentId:gallery.newsId];
        if (obj) {
            dic[kEditorKeyShareCmtObj] = obj;
        }
        
        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCommentEditor"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:action];
        
        [dic release];
        dic = nil;
    }
}

- (void)setCurrentTableShouldScrollsToTop
{
    _photoTextTable.scrollsToTop = YES;
}

// for hide menu
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    __block SNPhotoListController* wself = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUIMenuControllerHideMenuNotification
                                                        object:nil
                                                      userInfo:nil];
    if (wself.isSlideShowMode) {
        return;
    }
    
    //
    if (scrollView.contentOffset.y - _lastVerticalOffset>0&&
        scrollView.contentOffset.y>0&&
        scrollView.contentSize.height > scrollView.frame.size.height+10) {
        [wself userDidScrolled:YES scrollView:scrollView lastVerticalOffset:_lastVerticalOffset];
        _lastVerticalOffset = scrollView.contentOffset.y;
    }
    else {
        if (scrollView.contentOffset.y  - _lastVerticalOffset<=0 &&
            scrollView.contentOffset.y>=0) {
            [wself userDidScrolled:NO scrollView:scrollView lastVerticalOffset:_lastVerticalOffset];
            _lastVerticalOffset = scrollView.contentOffset.y;
        }
    }
    
    //请求评论
    if(scrollView.contentOffset.y - _lastOffsetY > 0 && [wself.commentListManager loadMoreComment:scrollView]) {
        [wself.photolistDataSource setMoreCellState:kRCMoreCellStateLoadingMore tableView:_photoTextTable];
    }
    _lastOffsetY = scrollView.contentOffset.y;
}

#pragma mark - loading status
- (void)showLoading {
	if (!_loadingView) {
		_loadingView = [[SNEmbededActivityIndicatorEx alloc] initWithFrame:CGRectZero andDelegate:self];
        _loadingView.hidesWhenStopped = YES;
        _loadingView.delegate = self;
        _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
        [self.view addSubview:_loadingView];
	}
    [self.view bringSubviewToFront:_loadingView];
	[_loadingView setFrame:CGRectMake(0, 0, self.view.width, self.view.height - kPostFollowHeight)];
    _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
}

- (void)hideLoading {
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [_loadingView removeFromSuperview];
    TT_RELEASE_SAFELY(_loadingView);
}

- (void)showError {
    _loadingView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
}

- (void)hideError {
    _loadingView.status = SNEmbededActivityIndicatorStatusInit;
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry
{
    [self showLoading];
    [self refreshPhotoTextListModel];
}

- (BOOL)shouldRecognizerPanGesture:(UIPanGestureRecognizer*)panGestureRecognizer {
    return !_isSlideShowMode;
}


@end
