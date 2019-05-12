//
//  SNMyMessageTableController.m
//  sohunews
//
//  Created by jialei on 13-7-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMyMessageTableController.h"
#import "SNMyMessage.h"
#import "SNNewsComment.h"
#import "SNBaseEditorViewController.h"
#import "SNCommentEditorViewController.h"
#import "SNTimelineConfigs.h"
#import "SNSendCommentObject.h"
#import "SNCommentConfigs.h"
#import "SNMyMessageModel.h"
#import "SNMessage.h"
#import "SNFloorCommentItem.h"
#import "SNMyMessageTableCell.h"
//#import "SNWeiboDetailMoreCell.h"
#import "SNCommentListManager.h"
#import "SNGalleryPhotoView.h"

#import "SNTwinsLoadingView.h"
#import "SNTripletsLoadingView.h"

#define kDownloadBtnTag   (1004)

@interface SNMyMessageTableController ()<SNTripletsLoadingViewDelegate>
{
    float _lastOffsetY;
    SNCommentSendType _replyType;
    BOOL _shouldUpdateRefreshTime;
    BOOL _isLoading;
    BOOL _needRefresh;
    
    //    SNTableHeaderDragRefreshView* _dragView;
    //SNWeiboDetailMoreCell   *_moreCell;                     //加载更多
    SNEmbededActivityIndicator* _myLoadingView;
    
    SNGalleryPhotoView *_imageDetailView;
    SNTripletsLoadingView *_loading;
}

@property (nonatomic, strong)SNTwinsLoadingView *dragLoadingView;
@property (nonatomic, strong)SNMyMessageModel *messageModel;
@property (nonatomic, strong)SNNewsComment *replyComment;
@property (nonatomic, strong)SNNewsComment *shareComment;
@property (nonatomic, strong)SNActionMenuController *actionMenuController;
@property (nonatomic, strong)NSString *topicId;

@end

@implementation SNMyMessageTableController

@synthesize replyComment = _replyComment;
@synthesize shareComment = _shareComment;
@synthesize topicId = _topicId;

- (id)initWithQuery:(NSMutableDictionary *)query {
    self = [super init];
    if (self) {
        self.newsId = [query objectForKey:kCLKeyNewsId];
        self.gId = [query objectForKey:kCLKeyGid];
        NSNumber *numIsAuthor = [query objectForKey:kCLKeyIsAuthor];
        self.isAuthor = [numIsAuthor boolValue];
        self.subId = [query objectForKey:kCLKeySubId];
        _lastOffsetY = 0;
        _needRefresh = YES;
        
        _shouldUpdateRefreshTime = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(deleteTrendNotification:) name:kTLTrendCellDeleteNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kToolbarViewHeight)];
        bottomView.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = bottomView;
    }
}

- (void)loadView
{
    [super loadView];
    
    self.tableView = [[SNMyMessageTable alloc] initWithFrame:self.view.bounds];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.tableView.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-kToolbarHeightWithoutShadow);
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.eventDelegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
    
    __block typeof(self) wself = self;
    self.tableView.tableTapCallback = ^{
        [wself commentTableRefreshModel];
    };
    
    //下拉刷新
    //    float viewHeight = [UIScreen mainScreen].bounds.size.height;
    //    _dragView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0,
    //                                                                               self.view.height - viewHeight,
    //                                                                               self.view.width,
    //                                                                               viewHeight - self.view.height)];
    //    _dragView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    //    [self.tableView addSubview:_dragView];
    
    // 下拉刷新
    self.dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    [self.view addSubview:self.tableView];
    //    [self createModel];
    
    _loading = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, -60, self.view.frame.size.width, self.view.frame.size.height)];
    _loading.delegate = self;
    _loading.status = SNTripletsLoadingStatusStopped;
    [self.view addSubview:_loading];
    
    [self createModel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SNSoundManager sharedInstance] stopAll];
    if (!_messageModel.hasMore) {
        [self setMoreCellState:kRCMoreCellStateEnd];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SNSoundManager sharedInstance] stopAll];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createModel {
    _messageModel = [[SNMyMessageModel alloc] init];
    _messageModel.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_messageModel loadData:NO];
    });
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    _actionMenuController.delegate = nil;
    _messageModel.delegate = nil;
    
    _dragLoadingView.status = SNTwinsLoadingStatusNil;
    [_dragLoadingView removeFromSuperview];
}

#pragma mark - dragScrollEvent
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.dragging && !_isLoading)
    {
        if ((scrollView.contentOffset.y+scrollView.contentInset.top) > -[_dragLoadingView minDistanceCanReleaseToReload]) {
            self.dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        }
        else {
            self.dragLoadingView.status = SNTwinsLoadingStatusReleaseToReload;
        }
    }
    
    //上拉加载更多
    if (scrollView.contentOffset.y > 0 &&
        (scrollView.contentOffset.y + scrollView.height + kToolbarViewHeight >
         scrollView.contentSize.height /*- kMoreCellHeight * 2*/ &&
         _messageModel.comments.count > 0 &&
         _messageModel.hasMore && !_isLoading)) {
            if (scrollView.contentOffset.y - _lastOffsetY > 0 &&
                [self checkNetworkIsEnableAndTell:_messageModel.comments.count > 0 ? YES : NO] ) {
                [self setMoreCellState:kRCMoreCellStateLoadingMore];
                [_messageModel loadData:YES];
            }
            _lastOffsetY = scrollView.contentOffset.y;
        }
    else if (_messageModel.hasMore) {
        [self setMoreCellState:kRCMoreCellStateDragRefresh];
    }
    else {
        [self setMoreCellState:kRCMoreCellStateEnd];
        if (_messageModel.comments.count == 0) {
            //[_moreCell setPromtLabelTextHide:YES];
        }
    }
    //下拉刷新
    if (scrollView.contentOffset.y <= kRefreshDeltaY && !_isLoading) {
        if ([self checkNetworkIsEnableAndTell:YES]) {
            [_messageModel loadData:NO];
            _needRefresh = YES;
        }
    }

}

#pragma mark - privateMethod
- (BOOL)checkNetworkIsEnableAndTell:(BOOL)showMsg {
    BOOL bRet = YES;
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        bRet = NO;
        if (showMsg) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        }
    }
    return bRet;
}

- (void)setMoreCellState:(SNMoreCellState)state
{
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    switch (state) {
        case kRCMoreCellStateLoadingMore:
            //[_moreCell showLoading:YES];
            break;
        case kRCMoreCellStateDragRefresh:
            //[_moreCell showLoading:NO];
            //[_moreCell setHasNoMore:NO];
            break;
        case kRCMoreCellStateEnd:
            //[_moreCell showLoading:NO];
            //[_moreCell setHasNoMore:YES];
            break;
        default:
            break;
    }
}

#pragma mark - menuAction
//回复
- (void)replyComment:(SNNewsComment *)comment
{
    _replyType = kCommentSendTypeReply;
    self.replyComment = comment;
    [self presentCommentEidtorController];
}

- (void)replyFloorComment:(SNNewsComment *)comment
{
    _replyType = kCommentSendTypeReplyFloor;
    self.replyComment = comment;
    [self replyComment:comment];
}

- (void)updateTheme:(NSNotification *)notifiction
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)presentCommentEidtorController
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    SNSendCommentObject *cmtObj = [SNSendCommentObject new];
    
    NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeShowAll];
    [dic setObject:toolbarType forKey:kCommentToolBarType];
    
    if (self.replyComment.author.length > 0) {
        cmtObj.replyName = self.replyComment.author;
    }
    if (_topicId.length > 0) {
        cmtObj.topicId = _topicId;
    }
    cmtObj.replyComment = [SNNewsComment createReplyComment:self.replyComment replyType:_replyType];
    
    [dic setObject:cmtObj forKey:kEditorKeySendCmtObj];
    
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCommentEditor"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
    
    dic = nil;
}

#pragma mark - UITableViewDatasource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < _messageModel.comments.count) {
        id item = [_messageModel.comments objectAtIndex:[indexPath row]];
        Class itemCellClass = [self classForItem:item];
        NSString *indentifier = NSStringFromClass(itemCellClass);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        if (!cell) {
            cell = [[itemCellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:indentifier];
        }
        if ([item isKindOfClass:[SNFloorCommentItem class]]) {
            SNCommentMessageCell *cmtMsgCell = (SNCommentMessageCell *)cell;
            SNFloorCommentItem *cmtItem = (SNFloorCommentItem *)item;
            cmtItem.index = indexPath.row;
            [cmtMsgCell setObject:cmtItem];
            [cmtMsgCell setDelegate:self];
            __block typeof(self) wself = self;
            cmtMsgCell.replyBlock = ^(SNNewsComment *comment){
                [wself replyComment:comment];
            };
        }
        else if([item isKindOfClass:[SNMyMessageItem class]]) {
            SNMyMessageTableCell *myMsgCell = (SNMyMessageTableCell *)cell;
            SNMyMessageItem *msgItem = (SNMyMessageItem *)item;
            msgItem.rowIndex = indexPath.row;
            [myMsgCell setObject:msgItem];
            [myMsgCell setDelegateController:self];
        }
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageModel.comments.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < _messageModel.comments.count)  {
        id item = [_messageModel.comments objectAtIndex:[indexPath row]];
        if ([item isKindOfClass:[SNMyMessageItem class]]) {
            return [SNMyMessageTableCell rowHeightForObject:item];
        }
        else if ([item isKindOfClass:[SNFloorCommentItem class]]) {
            return [SNCommentMessageCell rowHeightForObject:item];
        }
    }
    else if ([indexPath row] == _messageModel.comments.count) {
        if (_messageModel.comments.count > 0) {
            //return [SNWeiboDetailMoreCell height];
        }
    }
    return 0;
}

- (Class)classForItem:(id)obj {
    if ([obj isKindOfClass:[SNMyMessageItem class]]) {
        return [SNMyMessageTableCell class];
    }
    else if ([obj isKindOfClass:[SNFloorCommentItem class]]) {
        return [SNCommentMessageCell class];
    }
    return nil;
}

#pragma mark - SNCommentListModelDelegate
- (void)commentListModelDidStartLoad:(SNCommentListModel *)commentModel
{
    _isLoading = YES;
    //更新下拉动画
    if (_needRefresh) {
        //        [_dragView setStatus:TTTableHeaderDragRefreshLoading];
        self.dragLoadingView.status = SNTwinsLoadingStatusLoading;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0.0f, kToolbarViewHeight * 2, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)commentListModelDidFinishLoad:(SNCommentListModel *)commentModel
{
    _isLoading = NO;
    //    [self.tableView hideLoading];
    
    //    [_dragView setStatus:TTTableHeaderDragRefreshLoading];
    self.dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    [_dragLoadingView removeFromSuperview];
    _dragLoadingView = nil;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0.0f, kToolbarViewHeight * 2, 0.0f);
    [UIView commitAnimations];
    
    [self.tableView reloadData];
    [self.tableView showEmpty:_messageModel.comments.count == 0];
    _loading.status = SNTripletsLoadingStatusStopped;
    if (!_messageModel.hasMore) {
        [self setMoreCellState:kRCMoreCellStateEnd];
    }
}


- (void)commentListModelDidFailToLoadWithError:(SNCommentListModel *)commentModel
{
    _isLoading = NO;
    self.dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    [_dragLoadingView removeFromSuperview];
    _dragLoadingView = nil;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0.0f, kToolbarViewHeight * 2, 0.0f);
    switch (commentModel.lastErrorCode) {
        case kCommentErrorCodeNoData: {
            //            [self.tableView hideLoading];
            if (!_messageModel.loadHistory)
            {
                if (_messageModel.comments.count <= 0)
                {
                    [self.tableView showEmpty:YES];
                }
            }
            else
            {
                //[_moreCell showLoading:NO];
                //[_moreCell setHasNoMore:YES];
                [self.tableView reloadData];
            }
            break;
        }
        case kCommentErrorCodeDisconnect: {
            if (_messageModel.comments.count > 0) {
                //[_moreCell setHasNoMore:NO];
            }
            //[_moreCell showLoading:NO];
            if (_messageModel.comments.count == 0) {
                //                [self.tableView showError];
                _loading.status = SNTripletsLoadingStatusNetworkNotReachable;
            }
            break;
        }
        default:
            break;
    }
}

- (void)expandSocialComment:(NSString *)messageId
{
    [SNCommentListManager expandSocialByMsgId:_messageModel.comments messageId:messageId];
    [self.tableView reloadData];
}

- (void)expandSocialFloorComment:(NSString *)messageId
{
    [SNCommentListManager expandSocialFloorByMsgId:_messageModel.comments messageId:messageId];
    [self.tableView reloadData];
}

-(void)expandFloorComment:(int)subFloorIndex indexPathRow:(int)rowIndex// tag:(int)tag
{
    [SNCommentListManager expandSubComment:_messageModel.comments subFloorIndex:subFloorIndex indexPathRow:rowIndex];
    [self.tableView reloadData];
}

- (void)expandComment:(NSString *)commentId// tag:(int)tag
{
    [SNCommentListManager expandCommentById:_messageModel.comments cid:commentId];
    [self.tableView reloadData];
}

#pragma mark - showBigImageView
- (void)showImageWithUrl:(NSString *)urlPath {
    if (_imageDetailView == nil) {
        CGRect applicationFrame     = [[UIScreen mainScreen] bounds];
        applicationFrame.size.height = kAppScreenHeight;
        _imageDetailView   = [[SNGalleryPhotoView alloc] initWithFrame:applicationFrame];
    }
    [_imageDetailView loadImageWithUrlPath:urlPath];
    
    [[TTNavigator navigator].topViewController.flipboardNavigationController.view addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _imageDetailView.alpha = 1.0;
    }];
}

#pragma mark- tableLoadingDelegate
- (void)commentTableRefreshModel
{
    [_messageModel loadData:NO];
}

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    [_messageModel loadData:NO];
    _loading.status = SNTripletsLoadingStatusLoading;
}

- (void)deleteTrendNotification:(NSNotification *)notification {
    [self createModel];
}
- (SNTwinsLoadingView *)dragLoadingView {
    if (!_dragLoadingView) {
        CGRect dragLoadingViewFrame = CGRectMake(0, 0, kAppScreenWidth, 44);
        _dragLoadingView = [[SNTwinsLoadingView alloc] initWithFrame:dragLoadingViewFrame andObservedScrollView:self.tableView];
        [self.view addSubview:_dragLoadingView];
    }
    [self.view bringSubviewToFront:self.tableView];
    return _dragLoadingView;
}

@end
