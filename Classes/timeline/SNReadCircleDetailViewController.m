//
//  SNReadCircleDetailViewController.m
//  sohunews
//
//  Created by jialei on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNReadCircleDetailViewController.h"
#import "SNTimelineTrendModel.h"
#import "SNTrendArticleView.h"
#import "SNTrendSubScribeView.h"
#import "SNTrendPeopleView.h"
#import "SNTrendLiveView.h"
#import "SNReadCircleCommentCell.h"
#import "SNApprovalButton.h"
#import "SNPhotoListHeaderView.h"
#import "Toast+UIView.h"
#import "SNWeiboDetailMoreCell.h"
#import "SNBaseEditorViewController.h"
#import "SNUserManager.h"

#define kApprovalBtnWidth       (112 / 2)
#define kApprovalBtnHeight      (56 / 2)
#define kPlaceHolderTopMrigin   (26 / 2)
#define kPlaceHolderGap         (22 / 2)

@interface SNReadCircleDetailViewController ()
{
    CGFloat      _lastOffsetY;
    UIButton     *_textImageButton;
    UITableView  *_commentTable;
    SNApprovalButton *_approvalButton;
    
    SNEmbededActivityIndicatorEx *_loadingView;
}

@property (nonatomic, retain)SNTimeLineTrendModel *detailModel;
@property (nonatomic, retain)SNTimelineTrendItem *item;
@property (nonatomic, retain)SNWeiboDetailMoreCell *moreCell;
@property (nonatomic, retain)SNTimelineTrendCell *detailView;

@end

@implementation SNReadCircleDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.pid = [query stringValueForKey:kCircleDetailKeyPid defaultValue:nil];
        self.actId = [query stringValueForKey:kCircleDetailKeyActId defaultValue:nil];
        self.approvalNum = [query intValueForKey:kCircleDetailKeyAvlNum defaultValue:0];
        self.indexPath = [query intValueForKey:kCircleDetailKeyIndex defaultValue:0];
        if (self.actId.length > 0) {
            self.detailModel = [SNTimeLineTrendModel modelForDetailWithActId:self.actId];
            self.detailModel.delegate = self;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tlSendCommentSuc:)
                                                     name:kTLTrendSendCommentSucNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tlCellDelete:)
                                                     name:kTLTrendCellDeleteNotification
                                                   object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    
    //toolBar
    [self addToolbar];
    
    //placeHoder
    UIImage *approvalImage = [UIImage themeImageNamed:@"timeline_detail_approval_btn.png"];
    _approvalButton = [[SNApprovalButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                         kApprovalBtnWidth, kApprovalBtnHeight)];
    _approvalButton.right = _toolbarView.width - kPlaceHolderGap;
    _approvalButton.top = kPlaceHolderTopMrigin;
    _approvalButton.actId = self.actId;
    _approvalButton.customBgImage = approvalImage;
    _approvalButton.topNumbers = self.approvalNum;
    [_toolbarView addSubview:_approvalButton];

    UIImage *imgField = [UIImage themeImageNamed:@"post.png"];
    _textImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _textImageButton.frame = CGRectMake(_toolbarView.leftButton.right, kPlaceHolderTopMrigin,
                                        _approvalButton.left - _toolbarView.leftButton.width - kPlaceHolderGap,
                                        kApprovalBtnHeight);
    _textImageButton.backgroundColor = [UIColor clearColor];
    [_textImageButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_textImageButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_textImageButton setTitle:NSLocalizedString(@"ComposeComment", nil) forState:UIControlStateNormal];
    [_textImageButton setBackgroundImage:imgField forState:UIControlStateNormal];
    [_textImageButton setBackgroundImage:imgField forState:UIControlStateHighlighted];
    [_textImageButton addTarget:self action:@selector(beginCommentEditor) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_textImageButton];
    
    SNWeiboDetailMoreCell *moreCell = [[[SNWeiboDetailMoreCell alloc]initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"moreCell"] autorelease];
    [moreCell setPromtLabelTextHide:YES];
    [moreCell showLoading:NO];
    moreCell.frame = CGRectMake(0, 0, self.view.width, kMoreCellHeight);
    self.moreCell = moreCell;
    
    //loading页面
    [self showLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.detailModel timelineDetailRefresh];
    });
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    TT_RELEASE_SAFELY(_approvalButton);
    TT_RELEASE_SAFELY(_loadingView);
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    TT_RELEASE_SAFELY(_loadingView);
    _detailModel.delegate = nil;
    TT_RELEASE_SAFELY(_detailModel);
    TT_RELEASE_SAFELY(_detailView);
    TT_RELEASE_SAFELY(_item);
    TT_RELEASE_SAFELY(_approvalButton);
    TT_RELEASE_SAFELY(_moreCell);
    
    [super dealloc];
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + self.view.height > scrollView.contentSize.height - 60 &&
        scrollView.contentOffset.y > _lastOffsetY) {
        if (self.detailModel.commentNextCursor.length > 0 && [self checkNetworkIsEnableAndTell] &&
            self.detailModel.hasMoreComment) {
            [self.detailModel timelineDetailGetMore:self.detailModel.commentNextCursor];
        }
    }
    _lastOffsetY = scrollView.contentOffset.y;
}

#pragma mark- UITablewViewDelegate
-(NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (self.detailModel.commentObjects.count > 0) {
        return self.detailModel.commentObjects.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.detailModel.commentObjects.count > 0) {
        SNTimelineCommentsObject *cmtObj = [self.detailModel.commentObjects objectAtIndex:[indexPath row]];
        return [SNReadCircleCommentCell heightForReadCircleComment:cmtObj objIndex:[indexPath row]];
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.detailModel.commentObjects.count > 0 && [indexPath row] < self.detailModel.commentObjects.count) {
        SNTimelineCommentsObject *cmtObj = [self.detailModel.commentObjects objectAtIndex:[indexPath row]];
        
        static NSString *identifier = @"cell_iidentifier";
        SNReadCircleCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[SNReadCircleCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier] autorelease];
        }
        if ([indexPath row] == 0) {
            cell.index = SNTimelineCommentBgTypeTop;
        }
        else if ([indexPath row] == self.detailModel.commentObjects.count - 1) {
            cell.index = SNTimelineCommentBgTypeBottom;
        }
        else {
            cell.index = SNTimelineCommentBgTypeMiddle;
        }
        cell.delegate = self;
        [cell setObject:cmtObj];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark- subViews
- (void)createTableView
{
    _commentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, kSystemBarHeight,
                                                              kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - 42)
                                             style:UITableViewStylePlain];
    _commentTable.dataSource = self;
    _commentTable.delegate = self;
    _commentTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _commentTable.backgroundColor = SNUICOLOR(kBackgroundColor);
    _commentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commentTable.decelerationRate = UIScrollViewDecelerationRateFast;
    _commentTable.separatorColor = [UIColor clearColor];
    
    [self.view addSubview:_commentTable];
}

- (void)createDetailView
{
    if (self.detailModel.detailItem > 0) {
        self.item = self.detailModel.detailItem;
        _approvalButton.topNumbers = self.item.topNum;
        _approvalButton.hasApproval = self.item.isTop;
        _approvalButton.trendItem = self.item;
    }
    if (self.item) {
        switch (self.item.trendType) {
            case kSNTimelineItemTypeArticle:
            case kSNTimelineItemTypeUGC:
                self.detailView = [[SNTrendArticleView alloc]initWithFrame:CGRectZero];
                break;
            case kSNTimelineItemTypeSub:
                self.detailView = [[SNTrendSubScribeView alloc]initWithFrame:CGRectZero];
                break;
            case kSNTimelineItemTypeLive:
                self.detailView = [[SNTrendLiveView alloc]initWithFrame:CGRectZero];
                break;
            case kSNTimelineItemTypePeople:
                self.detailView = [[SNTrendPeopleView alloc]initWithFrame:CGRectZero];
                break;
        }
    }
    
    if (self.detailView) {
        self.detailView.canEnterCenter = (self.item.pid != [SNUserManager getPid]);
        self.detailView.delegate = self;
        self.detailView.needSepLine = NO;
        self.detailView.indexPath = self.indexPath;
        self.detailView.backgroundColor = SNUICOLOR(kBackgroundColor);
        [self.detailView setFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, self.item.height - self.item.commentsHeight - kTLCommentsViewNameTextMargin)];
        [self.detailView setTrendObject:self.item];
        
        _commentTable.tableHeaderView = self.detailView;
        _commentTable.tableHeaderView.backgroundColor = SNUICOLOR(kBackgroundColor);
        [self.detailView release];
    }
}

#pragma mark- timelineModelDelegate
- (void)timelineModelDidStartLoad
{
    [self setMoreCellState:kRCMoreCellStateLoadingMore];
}

- (void)timelineModelDidFinishLoad
{
    [self hideLoading];
    if (!_commentTable) {
        [self createTableView];
        [self createDetailView];
    }
    [_commentTable reloadData];
    
    if (_detailModel.commentObjects.count > 0) {
        _commentTable.tableFooterView = _moreCell;
    }
    else {
        _commentTable.tableFooterView = nil;
    }
    
    if (_detailModel.hasMoreComment) {
        [self setMoreCellState:kRCMoreCellStateLoadingMore];
    }
    else {
        [self setMoreCellState:kRCMoreCellStateEnd];
    }
}

- (void)timelineModelDidFailToLoadWithError:(NSError *)error
{
    switch (self.detailModel.lastErrorCode) {
        case kCircleDetailErrorDelete:
        case kCommentErrorCodeNoData:
        {
            [self hideLoading];
            _approvalButton.userInteractionEnabled = NO;
            _toolbarView.userInteractionEnabled = NO;
            [SNNotificationCenter showExclamation:@"该动态已被作者删除"];
            [self performSelector:@selector(noDetailBack) withObject:nil afterDelay:2];
        }
            break;
        case kCommentErrorCodeDisconnect:
        case kCommentErrorCancel:
            [self showError];
            [self setMoreCellState:kRCMoreCellStateDragRefresh];
            break;
        default:
            break;
    }
    [_commentTable reloadData];
}

#pragma mark- maskPage
- (void)showLoading {
	if (!_loadingView) {
		_loadingView = [[SNEmbededActivityIndicatorEx alloc] initWithFrame:CGRectZero andDelegate:self];
        _loadingView.hidesWhenStopped = YES;
        _loadingView.delegate = self;
        _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
        [_loadingView setFrame:CGRectMake(0, kSystemBarHeight,
                                          kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - 44)];
        [self.view addSubview:_loadingView];
	}
    [self.view bringSubviewToFront:_loadingView];
    _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
}

- (void)hideLoading {
    //    _photoTextTable.hidden = NO;
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [_loadingView removeFromSuperview];
    TT_RELEASE_SAFELY(_loadingView);
}

- (void)showError {
    _loadingView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
    //    _photoTextTable.hidden = YES;
}

- (void)hideError {
    _loadingView.status = SNEmbededActivityIndicatorStatusInit;
}

- (void)didTapRetry {
    [self.detailModel timelineDetailRefresh];
}

- (void)beginCommentEditor {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (self.item.actId.length) {
        [dic setObject:self.item.actId forKey:kCircleCommentKeyActId];
    }
    
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCircleCommentEditor"] applyAnimated:YES]
                           applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)showMessage:(NSString *)message
{
    [self.view.window makeToast:message
                          image:nil
                       duration:2.0
                       position:[NSValue valueWithCGPoint:CGPointMake(self.view.width/2,  _toolbarView.origin.y - 18)]];
}

- (void)setMoreCellState:(SNMoreCellState)state
{
    switch (state) {
        case kRCMoreCellStateLoadingMore:
            [_moreCell showLoading:YES];
            break;
        case kRCMoreCellStateDragRefresh:
            [_moreCell showLoading:NO];
            [_moreCell setHasNoMore:NO];
            break;
        case kRCMoreCellStateEnd:
            [_moreCell showLoading:NO];
            [_moreCell setHasNoMore:YES];
            break;
        default:
            break;
    }
}

- (void)noDetailBack
{
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

#pragma mark- openMoreAction
- (void)snTrendCmtBtnOpenMore:(NSString *)cmtId
{
    [SNTimelineTrendItem SNTimelineTrendCmtsReset:self.item id:cmtId];
    [_commentTable reloadData];
}

#pragma mark- delegateAction
- (void)tlCellDelete:(NSNotification *)notification
{
    [self.flipboardNavigationController popViewControllerAnimated:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTLTrendCellDeleteNotification object:dic];
}

//评论发送成功回调
- (void)tlSendCommentSuc:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (mDic && [SNUserManager getHeadImageUrl]) {
        [mDic setObject:[SNUserManager getHeadImageUrl] forKey:@"headUrl"];
    }
    SNTimelineCommentsObject *cmt = [SNTimelineTrendItem SNTrendDetailSendCmtSuc:mDic];
    if (cmt) {
        [self.detailModel.commentObjects insertObject:cmt atIndex:0];
    }
    [_commentTable reloadData];
    //更新评论数
    self.detailView.timelineTrendObj.commentNum++;
    [self.detailView setCommentNum];
}

#pragma mark - timelineCellDelegate
- (void)timelineCellExpandComment
{
    [self.detailView setFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, self.item.height - self.item.commentsHeight - kTLCommentsViewNameTextMargin)];
    [self.detailView setTrendObject:self.item];
    _commentTable.tableHeaderView = self.detailView;
}

#pragma mark - updateTheme
- (void)updateTheme
{
    UIImage *approvalImage = [UIImage themeImageNamed:@"timeline_detail_approval_btn.png"];
    _approvalButton.customBgImage = approvalImage;
    [_approvalButton updateTheme];
    _commentTable.backgroundColor = SNUICOLOR(kBackgroundColor);
    _commentTable.tableHeaderView.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    
    [super updateTheme:nil];
}

- (BOOL)checkNetworkIsEnableAndTell {
    BOOL bRet = YES;
    if (![SNUtility getApplicationDelegate].isNetwork) {
        bRet = NO;
        [SNNotificationCenter showExclamation:NSLocalizedString(SN_String("network error"), @"")];
        [self setMoreCellState:kRCMoreCellStateDragRefresh];
    }
    return bRet;
}

@end
