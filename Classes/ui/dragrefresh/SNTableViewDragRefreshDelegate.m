//
//  SNTableViewDragRefreshDelegate.m
//  sohunews
//
//  Created by Dan on 7/20/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNTableViewDragRefreshDelegate.h"
#import "SNTableHeaderDragRefreshView.h"
#import "SNTableMoreButton.h"
#import "SNRollingNewsModel.h"
#import "SNLiveModel.h"
#import "SNPhotosListViewController.h"
#import "SNNewsListViewController.h"
#import "SNUserManager.h"
#import "SNRollingNewsPublicManager.h"
#import "NSCellLayout.h"
#import "SNSubscribeNewsModel.h"
#import "SNRollingNewsTableController.h"
#import "SNSpecialNewsModel.h"
#import "SNRollingNewsVideoCell.h"
#import "SNAutoPlayVideoStyleTwoCell.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNRollingVideoCell.h"
#import "SNPullNewGuide.h"
#import "SNRollingTrainFocusCell.h"
#import "SNRollingTrainCardsCell.h"
#import "SNRollingTrainCellConst.h"

static NSString *firstDragChannelId;    //记录第一次下拉刷新channerlId
static int refreshTimes;

#define kDefaultHeaderVisibleHeight ([[SNDevice sharedInstance] isPhoneX] ? 144 : 120)
#define kFullScreenDefaultHeaderVisibleHeight ([[SNDevice sharedInstance] isPhoneX] ? 88 : 64)
#define kDefaultOffsetHeight ([[SNDevice sharedInstance] isPhoneX] ? 88 : 64)
#define kFullScreenDefaultOffsetHeight ([[SNDevice sharedInstance] isPhoneX] ? 34 : 10)
#define kDefaultRefreshDeltaY           -120.f
#define kFullScreenDefaultRefreshDeltaY -64.f
#define kPullADViewHeight               (60)//下拉频道广告位高度

@implementation SNTableViewDragRefreshDelegate {
    CGFloat _lastOffsetYValue;//上次滑动停止的位置，和_lastVerticalOffset不同
    SNRollingTrainFocusCell * _trainCell;
}

- (id)initWithController:(TTTableViewController *)controller {
	if (self = [super initWithController:controller]) {
        shouldUpdateRefreshTime = YES;
        
        _topInsetNormal = kHeadSelectViewHeight;
        _topInsetRefresh = kDefaultHeaderVisibleHeight;
        _isAutoPlay = YES;
	}
	return self;
}

- (id)initWithController:(TTTableViewController *)controller
                headView:(SNDragRefreshView *)header {
	if (self = [super initWithController:controller]) {
        [self setDragRefreshView:header];
        _isAutoPlay = YES;
	}
	
	return self;
}

- (void)setDragLoadingViewType:(SNNewsDragLoadingViewType)newType {
    dragViewType = newType;
    switch (dragViewType) {
        case SNNewsDragLoadingViewTypeTwins:
            [self addTwinsLoadingView];
            break;
        default:
            break;
    }
}

- (void)dragLoadingViewRemove {
    [self.dragLoadingView removeObserver];
}

- (void)addTwinsLoadingView {
    if (self.dragLoadingView) {
        [self.dragLoadingView removeObserver];
        if (self.dragLoadingView.status == SNTwinsLoadingStatusLoading) {
            [self.dragLoadingView setStatus:SNTwinsLoadingStatusNil];
        }
        [self.dragLoadingView removeFromSuperview];
        self.dragLoadingView = nil;
    }
    
    if (_pullDownBgView) {
        [_pullDownBgView removeFromSuperview];
        _pullDownBgView = nil;
    }
    
    CGRect dragLoadingViewFrame = CGRectMake(0, kDefaultOffsetHeight + 8, kAppScreenWidth, 44.f);
    SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
    if ([newsModel.channelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
        //huangzhen TODO...
        self.controller.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        dragLoadingViewFrame = CGRectMake(0, kFullScreenDefaultOffsetHeight + 8, kAppScreenWidth, 44.f);
    } else {
        self.controller.tableView.contentInset = UIEdgeInsetsMake(kDefaultOffsetHeight, 0, 0, 0);
    }
    self.dragLoadingView = [[SNTwinsLoadingView alloc] initWithFrame:dragLoadingViewFrame andObservedScrollView:self.controller.tableView];
    
    CGRect pullDownBgViewFrame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    _pullDownBgView = [[UIScrollView alloc] initWithFrame:pullDownBgViewFrame];
    _pullDownBgView.contentSize = CGSizeMake(kAppScreenWidth, kAppScreenHeight);
    _pullDownBgView.userInteractionEnabled = NO;
    _pullDownBgView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    [self.controller.view insertSubview:_pullDownBgView
                           belowSubview:self.controller.tableView];
    [self.controller.view insertSubview:self.dragLoadingView
                           belowSubview:self.controller.tableView];
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
}

- (void)updateTheme {
    _pullDownBgView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    self.tipsLabel.textColor = SNUICOLOR(kThemeRed1Color);
    self.tipsBackView.backgroundColor = SNUICOLOR(kThemeBg4Color);
}

- (void)setDragRefreshView:(SNDragRefreshView *)refreshView {
    shouldUpdateRefreshTime = YES;
    SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
    if ([newsModel.channelId isEqualToString:@"1"] &&
        [SNNewsFullscreenManager manager].isFullscreenMode) {
        //huangzhen TODO...
        _topInsetRefresh = kFullScreenDefaultHeaderVisibleHeight;
        _topInsetNormal  = kFullscreenHeadSelectViewHeight;
    }else {
        _topInsetRefresh = kDefaultHeaderVisibleHeight;
        _topInsetNormal  = kHeadSelectViewHeight;
    }
}

- (void)setModel:(id<TTModel>)aModel {
    // Hook up to the model to listen for changes.
    if (_model != aModel) {
        [_model.delegates removeObject:self];
        _model = (SNDragRefreshURLRequestModel *)aModel;
        [_model.delegates addObject:self];
    }
    
    // Grab the last refresh date if there is one.
    if ([_model respondsToSelector:@selector(refreshedTime)]) {
        NSDate *date = [_model performSelector:@selector(refreshedTime)];
        [self.dragLoadingView setUpdateDate:date];
    }
}

- (void)dealloc {
	[_model.delegates removeObject:self];
    [self.dragLoadingView removeObserver];
    if (self.dragLoadingView.status == SNTwinsLoadingStatusLoading) {
        [self.dragLoadingView setStatus:SNTwinsLoadingStatuStopAniamtion];
    }
    [self.dragLoadingView setStatus:SNTwinsLoadingStatusUpdateTableView];
    [self.dragLoadingView removeFromSuperview];
    self.dragLoadingView = nil;
    [SNNotificationManager removeObserver:self
                                     name:kThemeDidChangeNotification
                                   object:nil];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //此段代码功能：首页更新完成后，下拉顶部显示特殊文案。其他频道显示更新时间 wyy
    if (scrollView.contentOffset.y <= -kDefaultOffsetHeight) {
        [SNRollingNewsPublicManager sharedInstance].isHomePage = NO;
        if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
            SNRollingNewsModel *newsMode = (SNRollingNewsModel *)_model;
            if ([newsMode isHomePage]) {
                [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
            }
        }
        self.dragLoadingView.hidden = NO;
    }
    if (_trainCell) {
        UITableView * tableView = (UITableView *)scrollView;
        [_trainCell tableViewWillBeginDragging:tableView];
    }
}

- (void)transformationAutoPlayTop:(TTTableView *)tableView {
    //判断连续阅读标记
    if ([SNRollingNewsPublicManager sharedInstance].isReadMoreArticles) {
        [SNRollingNewsPublicManager sharedInstance].isReadMoreArticles = NO;
        for (id cellView in tableView.visibleCells) {
            if ([cellView respondsToSelector:@selector(setNewsReadStyleByMemory)]) {
                //setReadStyleByMemory slide页连续阅读后，item.isRead未修改，需要从cache获取新的已读标志
                [cellView setNewsReadStyleByMemory];
            }
        }
    }
    
    BOOL isWifi = ((![SNUtility isNetworkWWANReachable]) &&
                   [SNUtility isNetworkReachable]);
    if (isWifi && [SNUtility channelVideoSwitchStatus]) {
    } else {
        if (![[SNTimelineSharedVideoPlayerView sharedInstance] getMoviePlayer]) {
            [SNAutoPlaySharedVideoPlayer forceStopVideo];
            return;
        }
    }
    
    if (tableView.visibleCells.count == 0) {
        //如果没有可用数据, 直接返回
        return;
    }
    
    SNRollingBaseCell *topCellView = nil;
    SNRollingBaseCell *bottomCellView = nil;
    
    for (SNRollingBaseCell *cellView in tableView.visibleCells) {
        CGFloat height = cellView.frame.size.height;
        CGRect rect = [tableView convertRect:cellView.frame toView:[tableView superview]];
        NSInteger playerBottom = rect.origin.y + height - 64;
        
        if ([cellView isKindOfClass:[SNRollingNewsVideoCell class]] ||
            [cellView isKindOfClass:[SNAutoPlayVideoStyleTwoCell class]]) {
            if (playerBottom > height / 2) {
                topCellView = cellView;
                break;
            }
        } else if ([cellView isKindOfClass:[SNRollingVideoCell class]]) {
            if (playerBottom > height / 2 && playerBottom < (tableView.frame.size.height + height / 2 - 64 - 44)) {
                topCellView = cellView;
                break;
            }
        } else if ([cellView isKindOfClass:[SNRollingTrainCardsCell class]]) {
            if (playerBottom > height / 2) {
                SNRollingTrainCardsCell *videoCell = (SNRollingTrainCardsCell *)cellView;
                //TODO:获取火车卡片是否有需要自动播放的视频
                //TODO:或者已经自动的视频
                if ([videoCell isVideoCellVisible]) {
                    topCellView = cellView;
                    break;
                }
            }
        }
    }
    
    if (topCellView == nil) {
        for (SNRollingBaseCell *cellView in tableView.visibleCells) {
            if ([cellView isKindOfClass:[SNRollingNewsVideoCell class]] ||
                [cellView isKindOfClass:[SNAutoPlayVideoStyleTwoCell class]] ||
                [cellView isKindOfClass:[SNRollingVideoCell class]]) {
                bottomCellView = cellView;
            } else if ([cellView isKindOfClass:[SNRollingTrainCardsCell class]]) {
                SNRollingTrainCardsCell *videoCell = (SNRollingTrainCardsCell *)cellView;
                //TODO:获取火车卡片是否有需要自动播放的视频
                //TODO:或者已经自动的视频
                if ([videoCell isVideoCellVisible]) {
                    bottomCellView = cellView;
                }
            }
        }
    }
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (topCellView &&
        [topCellView isKindOfClass:[SNRollingNewsVideoCell class]]) {
        SNRollingNewsVideoCell *videoCell = (SNRollingNewsVideoCell *)topCellView;        
        CGFloat height = videoCell.frame.size.height;
        CGRect rect = [tableView convertRect:videoCell.frame toView:[tableView superview]];
        int playerMinBottom = rect.origin.y + height;
        //修改PGC大视频滑倒底部不能播放的问题
        if (playerMinBottom < height / 2 ||
            playerMinBottom > (tableView.frame.size.height + height / 2 - 64.0)) {
            [SNAutoPlaySharedVideoPlayer forceStopVideo];
        } else {
            if (![[player getMoviePlayer].currentPlayMedia.vid isEqualToString:videoCell.item.news.playVid] && videoCell.item.news.autoPlay == YES) {
                [videoCell autoPlay];
            }
        }
    } else if (topCellView &&
        [topCellView isKindOfClass:[SNAutoPlayVideoStyleTwoCell class]]) {
        SNAutoPlayVideoStyleTwoCell *videoCell = (SNAutoPlayVideoStyleTwoCell *)topCellView;
        CGFloat height = videoCell.frame.size.height;
        CGRect rect = [tableView convertRect:videoCell.frame
                                      toView:[tableView superview]];
        int playerMinBottom = rect.origin.y + height - 64;
        if (playerMinBottom < height / 2 ||
            playerMinBottom > (tableView.frame.size.height - height / 2)) {
            [SNAutoPlaySharedVideoPlayer forceStopVideo];
        } else {
            if (![[player getMoviePlayer].currentPlayMedia.vid isEqualToString:videoCell.item.news.playVid] && videoCell.item.news.autoPlay == YES) {
                [videoCell autoPlay];
            }
        }
    } else if (topCellView && [topCellView isKindOfClass:[SNRollingVideoCell class]]) {
        SNRollingVideoCell *videoCell = (SNRollingVideoCell *)topCellView;
        SNTimelineSharedVideoPlayerView *timelinePlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
        NSString *videoUrl = [NSString stringWithFormat:@"%@", [timelinePlayer getMoviePlayer].contentURL];
        CGFloat height = videoCell.frame.size.height;
        CGRect rect = [tableView convertRect:videoCell.frame
                                      toView:[tableView superview]];
        int playerMinBottom = rect.origin.y + height - 64;
        if (playerMinBottom < height / 2 ||
            playerMinBottom > (tableView.frame.size.height + height / 2 - 64 - 44)) {
            [SNTimelineSharedVideoPlayerView forceStop];
        } else {
            if ((![videoCell.video.link isEqualToString:videoUrl] ||
                 [timelinePlayer getMoviePlayer].playbackState != SHMoviePlayStatePlaying) &&
                ![timelinePlayer isLoading] && !timelinePlayer.playingVideoModel.isActivePause) {
                [videoCell autoPlay];
            }
        }
    } else if (topCellView &&
          [topCellView isKindOfClass:[SNRollingTrainCardsCell class]]) {
        SNRollingTrainCardsCell *videoCell = (SNRollingTrainCardsCell *)topCellView;
        CGFloat height = videoCell.frame.size.height;
        CGRect rect = [tableView convertRect:videoCell.frame
                                      toView:[tableView superview]];
        int playerMinBottom = rect.origin.y + height;
        if (playerMinBottom < height / 2 ||
            playerMinBottom > (tableView.frame.size.height + height / 2 - 64.0)) {
            //TODO:火车卡片视频停止播放
            [videoCell stopVideo];
        } else {
            if (![[player getMoviePlayer].currentPlayMedia.vid isEqualToString:videoCell.item.news.playVid]) {
                //TODO:火车卡片视频播放
                [videoCell autoPlayVideo];
            }
        }
    }
    
    if (nil == topCellView && bottomCellView != nil) {
        CGFloat height = bottomCellView.frame.size.height;
        CGRect rect = [tableView convertRect:bottomCellView.frame
                                      toView:[tableView superview]];
        int playerMinBottom = rect.origin.y + height - 64;
        if ([bottomCellView isKindOfClass:
             [SNRollingNewsVideoCell class]] ||
            [bottomCellView isKindOfClass:
             [SNAutoPlayVideoStyleTwoCell class]]) {
            if (playerMinBottom < height / 2 ||
                playerMinBottom > (tableView.frame.size.height - height / 2)) {
                [SNAutoPlaySharedVideoPlayer forceStopVideo];
            }
        } else if (bottomCellView &&
                   [bottomCellView isKindOfClass:[SNRollingVideoCell class]]) {
            if (playerMinBottom < height / 2 ||
                playerMinBottom > (tableView.frame.size.height + height / 2 - 64 - 44)) {
                [SNTimelineSharedVideoPlayerView forceStop];
            }
        } else if ([bottomCellView isKindOfClass:
               [SNRollingTrainCardsCell class]]) {
              if (playerMinBottom < height / 2 ||
                  playerMinBottom > (tableView.frame.size.height - height / 2)) {
                  //TODO:火车卡片视频播放
                  SNRollingTrainCardsCell *videoCell = (SNRollingTrainCardsCell *)bottomCellView;
                  [videoCell stopVideo];
              }
        }
    }
    
    if (!topCellView && !bottomCellView) {
        //避免滑出界面后，仍继续播放
        SNTabbarView *tabview = (SNTabbarView *)[TTNavigator navigator].topViewController.tabbarView;
        if (tabview.currentSelectedIndex != 1) {
            [SNAutoPlaySharedVideoPlayer forceStopVideo];
            [SNTimelineSharedVideoPlayerView forceStop];
        }
    }
}

- (void)countAutoPlayTopAndBottom:(UIScrollView *)scrollView {
    int currentPostion = scrollView.contentOffset.y;
    if (currentPostion - _lastPosition > 25) {
        //向上滑动
        _lastPosition = currentPostion;
    } else if (_lastPosition - currentPostion > 25) {
        //向下滑动
        _lastPosition = currentPostion;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= kTrainCellImageHeight
        && [SNNewsFullscreenManager manager].isFullscreenMode
        && self.isHomePage
        && [SNNewsFullscreenManager needTrainAnimation]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //放到下一次runloop，避免不能及时生效
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetValue = 0.0f;
    
    SNRollingNewsModel *newsModel = nil;
    if ([_model isKindOfClass:[SNRollingNewsModel class]]){
        newsModel = (SNRollingNewsModel *)_model;
    }

    if ([SNRollingNewsPublicManager sharedInstance].pageViewTimer == YES) {
        if (newsModel != nil) {
            if (!newsModel.isRecomendNewChannel) {
                if(scrollView.contentOffset.y > -20 ||
                   scrollView.contentOffset.y < -64) {
                    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = NO;
                }
            }
        }
    }
    
    if (scrollView.contentOffset.y < -64) {
        [self removeRecommendUserGuide];
    }
    
	[super scrollViewDidScroll:scrollView];
    //计算视频位置信息
    [self countAutoPlayTopAndBottom:scrollView];
    CGFloat refreshDeltaY = kDefaultRefreshDeltaY;
    if ([newsModel.channelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {//huangzhen TODO...
        refreshDeltaY = kFullScreenDefaultRefreshDeltaY;
    }
	if (scrollView.dragging && !_model.isLoading) {
		if (scrollView.contentOffset.y > refreshDeltaY
			&& scrollView.contentOffset.y < 0.0f) {
            _model.isRefreshManually = scrollView.dragging;
            if (shouldUpdateRefreshTime) {
                shouldUpdateRefreshTime = NO;
            }
		} else if (scrollView.contentOffset.y > 0) {
            _model.isRefreshManually = NO;
        }
	} else {
        _model.isRefreshManually = NO;
    }
    
	// This is to prevent odd behavior with plain table section headers. They are affected by the
	// content inset, so if the table is scrolled such that there might be a section header abutting
	// the top, we need to clear the content inset.
    if (scrollView.contentOffset.y > _lastVerticalOffset) {
        isScrollingDown = YES;
    } else {
        isScrollingDown = NO;
    }
    
    //流式频道未触底时预先加载 5.3.2 wyy
    int offset = 500;
    if ([_model isKindOfClass:[SNSubscribeNewsModel class]]) {
        /// 已关注列表触底加载更多
        offset = 0;
    }
    BOOL offsetTriger = scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height - offset;
    if (offsetTriger == YES) {
        canLoadMore = YES;
    }
    if ([_model isKindOfClass:[SNSpecialNewsModel class]]) {
        canLoadMore = NO;
    }
  
    if (scrollView.isDragging &&
        canLoadMore &&
        isScrollingDown &&
        !_model.isLoading &&
        offsetTriger) {
        canLoadMore = NO;
        isLoadingMore  = YES;
        
        if ([_model isKindOfClass:[SNSubscribeNewsModel class]]) {
            SNSubscribeNewsModel *subScribeModel = (SNSubscribeNewsModel *)_model;
            subScribeModel.isPullRefresh = NO;
        }
        
        // add By Cae.
        // 经过和书魁商讨，只要下拉都清掉focusPostion参数，由此引发的任何bug，均由书魁负责摆平。
        if (newsModel != nil) {
            newsModel.isPullRefresh = NO;
        }
        //如果加载更多数据时, 停止下拉两个小圆圈
        if (_dragLoadingView.status == SNTwinsLoadingStatusLoading) {
            [_dragLoadingView setStatus:SNTwinsLoadingStatusNil];
        }
        
        [_model load:TTURLRequestCachePolicyNetwork more:YES];
    }

    _lastVerticalOffset = scrollView.contentOffset.y;
    
    //让两个小球随tableView滚动而移动
    if (scrollView.contentOffset.y < -100) {
        [_pullDownBgView setContentOffset:CGPointMake(0, scrollView.contentOffset.y + 100) animated:NO];
    } else {
        [_pullDownBgView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    if (_trainCell) {
        UITableView * tableView = (UITableView *)scrollView;
        [_trainCell tableViewDidScroll:tableView];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SNTableAutoLoadMoreCell class]]) {
        _moreCell = (SNTableAutoLoadMoreCell *)cell;
    }
    
    if ([cell isKindOfClass:[SNRollingLoadMoreCell class]]) {
        _editMoreCell = (SNRollingLoadMoreCell *)cell;
    }
    
    if ([cell isKindOfClass:[SNRollingTrainFocusCell class]] &&
        indexPath.row == 0) {
        _trainCell = (SNRollingTrainFocusCell *)cell;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    TTTableView *tableView = (TTTableView *)scrollView;
    [self transformationAutoPlayTop:tableView];
    if (_trainCell) {
        UITableView * tableView = (UITableView *)scrollView;
        [_trainCell tableViewDidEndScroll:tableView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    SNRollingNewsModel *newsModel = nil;
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        newsModel = (SNRollingNewsModel *)_model;
    }
    if (_trainCell) {
        UITableView * tableView = (UITableView *)scrollView;
        [_trainCell tableViewDidEndDraging:tableView];
    }
    if ([SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
        if (newsModel && [newsModel.channelId isEqualToString:[SNUtility sharedUtility].currentChannelId]) {
            return;
        }
    }
    
    //如果相同频道下拉刷新, 去掉之前的Toast
    if (self.tipsBackView != nil) {
        if (newsModel && [newsModel.channelId isEqualToString:[SNUtility sharedUtility].currentChannelId]) {
            [_controller.tableView.layer removeAllAnimations];
            
            [self.tipsBackView.layer removeAllAnimations];
            [self.tipsLabel.layer removeAllAnimations];
            
            [self.tipsBackView removeFromSuperview];
            self.tipsBackView = nil;
            self.tipsLabel = nil;
        }
    }
    
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
    [self triggerPopoverMessage:scrollView];
    
    float refreshDeltay;
    if ([_controller isKindOfClass:[SNPhotosListViewController class]] ||
        [_controller isKindOfClass:[SNNewsListViewController class]]) {
        refreshDeltay = -64.0f;
    } else {
        refreshDeltay = kDefaultRefreshDeltaY;
    }
    if ([newsModel.channelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
        //huangzhen TODO...
        refreshDeltay = kFullScreenDefaultRefreshDeltaY;
    }
    
    BOOL isLoading = _model.isLoading;
    //新要闻频道正在加载火车不影响频道流刷新
    if ([newsModel isLoadingTrainList]) {
        isLoading = NO;
    }
	if (scrollView.contentOffset.y <= refreshDeltay &&
        !isLoading) {
        if (newsModel && ![SNUserManager isLogin]) {
            if (!firstDragChannelId && [newsModel.channelId isKindOfClass:[NSString class]]) {
                firstDragChannelId = [newsModel.channelId copy];
                refreshTimes = 1;
            }
        }
        
        isLoadingMore = NO;
        _model.isRefreshFromDrag = YES;
        if ([_controller isKindOfClass:[SNNewsListViewController class]]) {
            _model.isRefreshFromDrag = NO;
        }
        
        // add By Cae.
        // 经过和书魁商讨，只要下拉都清掉focusPostion参数，由此引发的任何bug，均由书魁负责摆平。
        if (newsModel != nil && [SNRollingNewsPublicManager sharedInstance].homeADCount == 0) {
            [SNRollingNewsPublicManager sharedInstance].homeADCount = 1;
        }
    
        if ([_controller isKindOfClass:[SNRollingNewsTableController class]]) {
            [_controller performSelector:@selector(reportPullAdShow) withObject:nil];
            [_controller performSelector:@selector(requestPullAd) withObject:nil afterDelay:1];//修改为只有下拉才会刷新频道下拉广告位 add by huang

            if (newsModel != nil) {
                //下拉刷新次数 分频道计数
                if (newsModel.channelId.length > 0) {
                    NSString *refreshCount = [[[SNAnalytics sharedInstance] channelRcs] objectForKey:newsModel.channelId];
                    if (refreshCount.length > 0) {
                        [[[SNAnalytics sharedInstance] channelRcs] setObject:[NSString stringWithFormat:@"%d", [refreshCount integerValue] + 1] forKey:newsModel.channelId];
                    } else {
                        [[[SNAnalytics sharedInstance] channelRcs] setObject:@"1" forKey:newsModel.channelId];
                    }
                }
            }
        }

        if (newsModel != nil) {
            newsModel.isPullRefresh = YES;
            //要闻频道如果改版不跳推荐
            if (![SNNewsFullscreenManager newsChannelChanged] && [newsModel.channelId isEqualToString:@"1"]) {
                //如果是首页, 下拉刷新改为跳转频道
                [SNNotificationManager postNotificationName:SNROLLINGNEWS_PUSHTONEXTCHANNEL object:nil];
                return;
            } else {
                [SNRollingNewsPublicManager sharedInstance].userAction = SNRollingNewsUserPullAndRefresh;
                [_model load:TTURLRequestCachePolicyNetwork more:NO];
            }
        }
        if ([_model isKindOfClass:[SNLiveModel class]] ||
            [_model isKindOfClass:[SNPhotoModel class]] ||
            [_model isKindOfClass:[SNSubscribeNewsModel class]]) {
            [_model load:TTURLRequestCachePolicyNetwork more:NO];
        }
        
        // add By Cae.
        // 经过和书魁商讨，只要下拉都清掉focusPostion参数，由此引发的任何bug，均由书魁负责摆平。
        if (newsModel != nil) {
            if ([newsModel.channelId isEqualToString:@"1"]) {
                [SNRollingNewsPublicManager sharedInstance].showRecommend = YES;
            }
            if (!newsModel.isNewChannel) {
                //下拉刷新，清空缓存
                [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:newsModel.channelId];
            }
        }
	}
    
    shouldUpdateRefreshTime = YES;
    
    if (!decelerate) {
        //这里复制scrollViewDidEndDecelerating里的代码
        TTTableView *tableView = (TTTableView *)scrollView;
        [self transformationAutoPlayTop:tableView];
        
        if (_trainCell) {
            UITableView * tableView = (UITableView *)scrollView;
            [_trainCell tableViewDidEndScroll:tableView];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [super scrollViewDidScrollToTop:scrollView];
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
    TTTableView *tableView = (TTTableView *)scrollView;
    [self transformationAutoPlayTop:tableView];
    
    if ([_controller isKindOfClass:[SNRollingNewsTableController class]]) {
        SNRollingNewsTableController *vc = (SNRollingNewsTableController *)_controller;
        NSNumber *stopFlagNum = [NSNumber numberWithBool:NO];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:vc.selectedChannelId, @"stopChannelId", stopFlagNum, @"stopFlag", nil];
        
        [SNNotificationManager postNotificationName:kStopPageTimerNotification
                                             object:nil userInfo:dic];
    }
}

#pragma mark -
#pragma mark TTModelDelegate
- (void)moreCellToAnimating:(BOOL)animating {
    _moreCell.animating = animating;
    id dataSource = _controller.dataSource;
    NSMutableArray *items = nil;
    if ([dataSource isKindOfClass:[TTSectionedDataSource class]]) {
        TTSectionedDataSource *sdataSource = (TTSectionedDataSource *)dataSource;
        items = sdataSource.items;
    } else if ([dataSource isKindOfClass:[TTListDataSource class]]) {
        TTListDataSource *ldataSource = (TTListDataSource *)dataSource;
        items = ldataSource.items;
    }
    for (id item in [items reverseObjectEnumerator]) {
        if ([item isKindOfClass:[SNTableMoreButton class]]) {
            SNTableMoreButton *moreBtn = (SNTableMoreButton *)item;
            moreBtn.animating = animating;
            break;
        }
    } 
}

- (void)initInsertToast:(NSString *)string
              channelId:(NSString *)channelId {
    if (self.tipsBackView != nil) {
        [_controller.tableView.layer removeAllAnimations];
    
        [self.tipsBackView.layer removeAllAnimations];
        [self.tipsLabel.layer removeAllAnimations];
        
        [self.tipsBackView removeFromSuperview];
        self.tipsBackView = nil;
        self.tipsLabel = nil;
    }
    
    self.tipsMessage = string;
    if (!self.tipsLabel && self.tipsMessage.length > 0) {
        CGFloat currentHeight = 0.0;
        if ([SNNewsFullscreenManager manager].isFullscreenMode &&
            [[SNUtility sharedUtility].currentChannelId
             isEqualToString:@"1"]) {
            currentHeight = 21.0;
        } else {
            currentHeight = 64.0;
        }
        self.tipsBackView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, kAppScreenWidth, 38.0)];
        if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
            self.tipsBackView.frame = CGRectMake(0, currentHeight + 24, kAppScreenWidth, 38.0);
        }
        self.tipsBackView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        self.tipsBackView.tag = kInsertToastTag;
        
        self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 38.0)];
        self.tipsLabel.backgroundColor = [UIColor clearColor];
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        self.tipsLabel.textColor = SNUICOLOR(kThemeRed1Color);
        self.tipsLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC + 1.0];
        [self.tipsBackView addSubview:self.tipsLabel];
    }
    
    self.tipsLabel.text = self.tipsMessage;
    
    if ([channelId isEqualToString:@"1"]) {
        self.isHomePage = YES;
    } else {
        self.isHomePage = NO;
    }
}

- (void)resetTableViewContentInset {
    CGFloat offsetValue = 0;
    if ([_controller isKindOfClass:[SNRollingNewsTableController class]]) {
        offsetValue = [(SNRollingNewsTableController *)_controller getBarHeight];
    }
    SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
    if ([newsModel.channelId isEqualToString:@"1"] &&
        [SNNewsFullscreenManager manager].isFullscreenMode) {
        //huangzhen TODO...
        CGRect dragLoadingViewFrame = CGRectMake(0, kFullScreenDefaultOffsetHeight + 8, kAppScreenWidth, 44.f);
        self.dragLoadingView.frame = dragLoadingViewFrame;
        _topInsetRefresh = kFullScreenDefaultHeaderVisibleHeight;
        [self.dragLoadingView resetObservedScrollViewOriginalContentInsetTop:kFullScreenDefaultOffsetHeight];
        [_controller.tableView setContentInset:UIEdgeInsetsMake(0, 0.f, 0.f, 0.f)];
        [_controller.tableView setContentOffset:CGPointMake(0, offsetValue) animated:NO];
    } else {
        _trainCell = nil;
        CGRect dragLoadingViewFrame = CGRectMake(0, kDefaultOffsetHeight + 8, kAppScreenWidth, 44.f);
        self.dragLoadingView.frame = dragLoadingViewFrame;
        _topInsetRefresh = kDefaultHeaderVisibleHeight;
        [self.dragLoadingView resetObservedScrollViewOriginalContentInsetTop:kDefaultOffsetHeight];
        [_controller.tableView setContentInset:UIEdgeInsetsMake(kDefaultOffsetHeight, 0.f, 0.f, 0.f)];
        [_controller.tableView setContentOffset:CGPointMake(0, -kDefaultOffsetHeight + offsetValue) animated:NO];
    }
}

- (void)resetTableViewFullscreenMode {
    CGFloat offsetValue = 0;
    if ([_controller isKindOfClass:[SNRollingNewsTableController class]]) {
        offsetValue = [(SNRollingNewsTableController *)_controller getBarHeight];
    }
    SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
    if ([newsModel.channelId isEqualToString:@"1"] &&
        [SNNewsFullscreenManager manager].isFullscreenMode) {
        //huangzhen TODO...
        CGRect dragLoadingViewFrame = CGRectMake(0, kFullScreenDefaultOffsetHeight + 8, kAppScreenWidth, 44.f);
        self.dragLoadingView.frame = dragLoadingViewFrame;
        _topInsetRefresh = kFullScreenDefaultHeaderVisibleHeight;
        [self.dragLoadingView resetObservedScrollViewOriginalContentInsetTop:kFullScreenDefaultOffsetHeight];
        [_controller.tableView setContentInset:UIEdgeInsetsMake(0, 0.f, 0.f, 0.f)];
    } else {
        _trainCell = nil;
        CGRect dragLoadingViewFrame = CGRectMake(0, kDefaultOffsetHeight + 8, kAppScreenWidth, 44.f);
        self.dragLoadingView.frame = dragLoadingViewFrame;
        _topInsetRefresh = kDefaultHeaderVisibleHeight;
        [self.dragLoadingView resetObservedScrollViewOriginalContentInsetTop:kDefaultOffsetHeight];
        [_controller.tableView setContentInset:UIEdgeInsetsMake(kDefaultOffsetHeight, 0.f, 0.f, 0.f)];
    }
}

- (void)showToast {
    [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptions)UIViewAnimationOptionCurveEaseInOut animations:^{
    } completion:^(BOOL finished) {
        self.tipsMessage = nil;
        self.tipsBackView.hidden = YES;
        [self.tipsBackView removeFromSuperview];
        self.tipsBackView = nil;
        self.tipsLabel = nil;
    }];
}

- (void)onlyShowToast {
    [_controller.view addSubview:self.tipsBackView];
    [UIView animateWithDuration:0.1 animations:^{
        self.tipsBackView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:0.2 animations:^{
            self.tipsBackView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.tipsLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [self performSelector:@selector(showToast) withObject:nil afterDelay:1.0];
        }];
    }];
}

- (void)p_setTableViewContentOffsetForToast:(CGFloat)contentOffset {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_controller.tableView setContentOffset:CGPointMake(0, contentOffset) animated:YES];
    });
}
- (void)insertToastAnimation {
    if ([self.tipsMessage isEqualToString:kUnintrestedTips] ||
        [self.tipsMessage isEqualToString:kEnterForegroundTips]) {
        [self onlyShowToast];
        return;
    }
    
    __block CGFloat offsetY = 0;
    __block BOOL haveAddInsert = NO;
    [SNRollingNewsPublicManager sharedInstance].isShowInsertToast = YES;
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
         if (_controller.tableView.contentOffset.y == -120.0) {
             if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
                 offsetY = -59.0;
                 if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
                     offsetY = -(59.0 + 24);
                 }
             } else {
                 offsetY = -102.0;
                 if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
                     offsetY = -126.0;
                 }
             }
             [self p_setTableViewContentOffsetForToast:offsetY];
         } else if (_controller.tableView.contentOffset.y <= -64.0) {
             if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
                 offsetY = -59.0;
                 if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
                     offsetY = -(59.0 + 24);
                 }
             } else {
                 offsetY = -102.0;
                 if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
                     offsetY = -126.0;
                 }
             }
             [self p_setTableViewContentOffsetForToast:offsetY];
         } else if (_controller.tableView.contentOffset.y == -20.0) {
             if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
                 offsetY = -59.0;
             }
         } else if (_controller.tableView.contentOffset.y == 0.0) {
             if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
                 offsetY = -59.0;
                 if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
                     offsetY = -(59.0 + 24);
                 }
                 [self p_setTableViewContentOffsetForToast:offsetY];
             } 
         }
    } completion:^(BOOL finished) {
        CGFloat delayShow = 0;
        if (_controller.tableView.contentOffset.y != - 20) {
            delayShow = 0.2;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayShow * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_controller.view.origin.y == 0) {
                //有toast提示时，切换频道，避免toast显示到切入的频道
                //[[UIApplication sharedApplication].keyWindow addSubview:self.tipsBackView];
                [_controller.view addSubview:self.tipsBackView];
                haveAddInsert = YES;
            }
            
            self.tipsBackView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            [UIView animateWithDuration:0.2 animations:^{
                self.tipsBackView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.tipsLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                if (!haveAddInsert) {
                    [_controller.view addSubview:self.tipsBackView];
                }
                
                if (_controller.tableView.contentOffset.y == -20.0) {
                    [self p_setTableViewContentOffsetForToast:offsetY];
                } else {
                    if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && kAppScreenHeight == 480.0 && ![self.tipsLabel.text isEqualToString:kEnterForegroundTips]) {
                        [self p_setTableViewContentOffsetForToast:offsetY];
                    }
                }
                
                //流式频道完成请求
                [SNRollingNewsPublicManager sharedInstance].isRequestChannelData = NO;
                
                [UIView animateWithDuration:0.1 animations:^{
                    self.tipsLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    [self dealToastFinish];
                }];
            }];
        });
    }];
}

- (void)dealToastFinish {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptions)UIViewAnimationOptionCurveLinear animations:^{
            self.tipsMessage = nil;
            if (_controller.tableView.contentOffset.y < -20.0) {
                NSString *channelID = @"";
                if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
                    SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
                    channelID = curModel.channelId;
                } else {
                    channelID = [SNUtility sharedUtility].currentChannelId;
                }
                if ([channelID isEqualToString:@"1"]) {
                    if ([SNNewsFullscreenManager manager].isFullscreenMode) {
                    } else {
                        [_controller.tableView setContentOffset:CGPointMake(0, -kDefaultOffsetHeight)];
                    }
                } else {
                    [_controller.tableView setContentOffset:CGPointMake(0, -kDefaultOffsetHeight)];
                }
            }
            self.tipsBackView.hidden = YES;
        } completion:^(BOOL finished) {
            [self.tipsBackView removeFromSuperview];
            self.tipsBackView = nil;
            self.tipsLabel = nil;
            
            if (dragViewType == SNNewsDragLoadingViewTypeTwins) {
                if (_dragLoadingView.status == SNTwinsLoadingStatusLoading) {
                    [self.dragLoadingView setStatus:SNTwinsLoadingStatuStopAniamtion];
                }
                [self.dragLoadingView setStatus:SNTwinsLoadingStatusUpdateTableView];
            }
            SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
            if ([newsModel.channelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
                [_controller.tableView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
            } else {
                [_controller.tableView setContentInset:UIEdgeInsetsMake(kDefaultOffsetHeight, 0.f, 0.f, 0.f)];
            }
            [SNRollingNewsPublicManager sharedInstance].isShowInsertToast = NO;
            
            //刷新自动播放数据
            [self transformationAutoPlayTop:(TTTableView *)_controller.tableView];
            
            //UI要求延迟1s显示
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //Toast提示结束后，显示推荐流新手引导; 推荐流新安装或升级，
                //提示“下拉刷新，获取更多资讯“
                if ([self isRecommendGuidShow]) {
                    [self showRecommendUserGuide];
                }
            });
        }];
    });
}

- (void)setTableViewContentInsetInRefreshingMode {
    CGFloat value = -_topInsetRefresh;
    _controller.tableView.contentInset = UIEdgeInsetsMake(_topInsetRefresh, 0.f, 0.f, 0.f);
    [_controller.tableView setContentOffset:CGPointMake(0, value) animated:NO];
}

- (void)modelDidStartLoad:(id<TTModel>)model {
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
        if (curModel.getAction == 3) {
            return;
        }
    }
    
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = NO;
    if (![[SNUtility getApplicationDelegate] isCurrentNetworkReachable] &&
        !_model.isRefreshManually) {
        return;
    }
    
    isLoadingMore = [model isLoadingMore];
    if (isLoadingMore) {
        BOOL isAnimation = YES;
        if ([model isKindOfClass:[SNRollingNewsModel class]]) {
            isAnimation = ![(SNRollingNewsModel *)model isEditLoadingMore];
        }
        [self moreCellToAnimating:isAnimation];
    } else {
        if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
            SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
            //要闻频道改版
            if ([curModel isHomePage] && [SNNewsFullscreenManager manager].isFullscreenMode) {
                //ContentOffset未发生变化
                dispatch_async(dispatch_get_main_queue(), ^{
                    //5.0新版下拉刷新
                    if (dragViewType == SNNewsDragLoadingViewTypeTwins) {
                        if (![SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
                            [self.dragLoadingView setStatus:SNTwinsLoadingStatusLoading];
                        }
                    }
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        [self setTableViewContentInsetInRefreshingMode];
                    }];
                });
            } else {
                [self p_modelDidStartForOldNews];
            }
        } else {
            [self p_modelDidStartForOldNews];
        }
    }
}

//老频道流逻辑
- (void)p_modelDidStartForOldNews {
    [UIView animateWithDuration:.3f animations:^{
        CGFloat value = -_topInsetRefresh;
        _controller.tableView.contentInset = UIEdgeInsetsMake(_topInsetRefresh, 0.f, 0.f, 0.f);
        [_controller.tableView setContentOffset:CGPointMake(0, value) animated:NO];
    }];
    //5.0新版下拉刷新
    switch (dragViewType) {
        case SNNewsDragLoadingViewTypeTwins:
            if (![SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
                [_dragLoadingView setStatus:SNTwinsLoadingStatusLoading];
            }
            break;
        default:
            break;
    }
}

- (void)p_HideNewsAnimationLoading {
    //要闻改版
    //首次安装启动App同步List.go
    [SNNotificationManager postNotificationName:SNROLLINGNEWS_HIDEANIMATIONLOADING object:nil];
}

- (void)p_NeedInsertToast {
    BOOL isNeedToShowToast = ![[NSUserDefaults standardUserDefaults] boolForKey:kShowLoadingPageKey];
    if (isNeedToShowToast) {
        if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
            SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
            //kShowLoadingPageKey 程序中全部设置为NO，下版本梳理逻辑
            if ([curModel.channelId isEqualToString:[SNUtility sharedUtility].currentChannelId]) {
                NSString *toastStr = [curModel.messageDic objectForKey:@"message"];
                UIView *view = [_controller.view viewWithTag:kInsertToastTag];
                if (toastStr != nil && [toastStr length] != 0 &&
                    view == nil) {
                    [self initInsertToast:toastStr channelId:curModel.channelId];
                    [self insertToastAnimation];
                    //完成后清除Toast
                    curModel.messageDic = nil;
                } else {
                    if (self.dragLoadingView.status == SNTwinsLoadingStatusLoading) {
                        [self.dragLoadingView setStatus:SNTwinsLoadingStatuStopAniamtion];
                    }
                    [self.dragLoadingView setStatus:SNTwinsLoadingStatusUpdateTableView];
                    [self resetTableViewContentInset];
                }
            } else {
                if (self.dragLoadingView.status == SNTwinsLoadingStatusLoading) {
                    [self.dragLoadingView setStatus:SNTwinsLoadingStatuStopAniamtion];
                }
                [self.dragLoadingView setStatus:SNTwinsLoadingStatusUpdateTableView];
                [self resetTableViewContentInset];
            }
        } else {
            if (self.dragLoadingView.status == SNTwinsLoadingStatusLoading) {
                [self.dragLoadingView setStatus:SNTwinsLoadingStatuStopAniamtion];
            }
            [self.dragLoadingView setStatus:SNTwinsLoadingStatusUpdateTableView];
            [self resetTableViewContentInset];
        }
    } else {
        if (self.dragLoadingView.status == SNTwinsLoadingStatusLoading) {
            [self.dragLoadingView setStatus:SNTwinsLoadingStatuStopAniamtion];
        }
        [self.dragLoadingView setStatus:SNTwinsLoadingStatusUpdateTableView];
        [self resetTableViewContentInset];
    }
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
        if (curModel.getAction == 3) {
            return;
        }
    }
    
    if ([model isKindOfClass:[SNSubscribeNewsModel class]]) {
        SNSubscribeNewsModel *subModel = (SNSubscribeNewsModel *)model;
        if ([subModel.subscribeArray count] == 0) {
            [self.dragLoadingView setStatus:SNTwinsLoadingStatusNil];
            if (!isLoadingMore) {
                _controller.tableView.scrollEnabled = YES;
                [NSTimer timerWithTimeInterval:0.2
                                        target:self
                                selector:@selector(resetTableViewContentInset)
                                      userInfo:nil
                                       repeats:NO];
            }
            return;
        }
    }
    
    canLoadMore = NO;
    if (_moreCell) {
        [self moreCellToAnimating:NO];
    }
    if (_editMoreCell) {
        [_editMoreCell endLoadAnimation];
    }
    
    if (!isLoadingMore) {
        if ([SNNewsFullscreenManager manager].isFullscreenMode &&
            [[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
            //要闻频道全屏焦点图Toast单独处理
            if (_dragLoadingView.status == SNTwinsLoadingStatusLoading) {
                [self.dragLoadingView setStatus:SNTwinsLoadingStatusPullToReload];
                [self resetTableViewContentInset];
            }
        } else {
            [self p_NeedInsertToast];
        }
    }

    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
        if (curModel.rollingNews.count != 0 ||
            curModel.recommendNews.count != 0) {
            [self p_HideNewsAnimationLoading];
        }
    }
    
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error {
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *curModel = (SNRollingNewsModel *)_model;
        if (curModel.getAction == 3) {
            return;
        }
    }
    
    if (_moreCell) {
        [self moreCellToAnimating:NO];
    }
    if (_editMoreCell) {
        [_editMoreCell endLoadAnimation];
    }

    _moreCell.animating = NO;
    
    if (_dragLoadingView) {
        if (_dragLoadingView.status == SNTwinsLoadingStatusLoading) {
            [self.dragLoadingView setStatus:SNTwinsLoadingStatusPullToReload];
        }
    }

    if (!isLoadingMore) {
        [self resetTableViewContentInset];
    }
    
    [self p_HideNewsAnimationLoading];
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
    if (_moreCell) {
        [self moreCellToAnimating:NO];
    }
    if (_editMoreCell) {
        [_editMoreCell endLoadAnimation];
    }
    
    if (_dragLoadingView) {
        if (_dragLoadingView.status == SNTwinsLoadingStatusLoading) {
            [self.dragLoadingView setStatus:SNTwinsLoadingStatusPullToReload];
        }
    }
    
    if (!isLoadingMore) {
        [self resetTableViewContentInset];
    }
    
    [self p_HideNewsAnimationLoading];
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
}

- (void)reload {
	[_model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (void)setDragLoadingViewNil {
    if (_dragLoadingView.status == SNTwinsLoadingStatusLoading) {
        [self.dragLoadingView setStatus:SNTwinsLoadingStatusNil];
    }
}

- (void)triggerPopoverMessage:(UIScrollView *)scrollView {
    //只有在流式频道里显示
    if (![_model isKindOfClass:[SNRollingNewsModel class]]) {
        return;
    } else {
        SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
        if (![newsModel hasTopNews]) {
            return;
        }
    }
    
    //App生命周期里，只显示一次
    if ([self showPopoverOnetime] == NO) {
        return;
    }
    
    CGFloat offsetY = fabsf(scrollView.contentOffset.y - _lastOffsetYValue);
    CGFloat screenHeight = kAppScreenHeight - [SNChannelScrollTabBar channelBarHeight];
    
    //触发popover条件，￼￼￼上滑超过三屏幕，再下滑连续超过两屏
    if (scrollView.contentOffset.y / screenHeight >= 3 &&
        !isScrollingDown && offsetY / screenHeight > 1) {
        [SNNotificationManager postNotificationName:kTriggerPopoverMessage object:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showPopoverview"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _lastOffsetYValue = scrollView.contentOffset.y;
}

- (BOOL)showPopoverOnetime {
    BOOL showPopoverview = [[NSUserDefaults standardUserDefaults] boolForKey:@"showPopoverview"];
    return showPopoverview == YES ? NO : YES;
}

#pragma mark 新手引导
//==========推荐流新手引导===============
- (BOOL)isRecommendNewPage {
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *newsMode = (SNRollingNewsModel *)_model;
        if ([newsMode.channelId isEqualToString:[SNUtility sharedUtility].currentChannelId]) {
            if ([newsMode isRecomendNewChannel]) {
                return YES;
            }
            //旧版本过滤要闻, 新版本要闻需要显示新手引导
            if ([SNNewsFullscreenManager newsChannelChanged] &&
                [newsMode isHomePage]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isRecommendGuidShow {
    if (![self isRecommendNewPage]) {
        return NO;
    }    
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kRecommendGuidShow, [SNUtility sharedUtility].currentChannelId];
    return ![[NSUserDefaults standardUserDefaults] boolForKey:keyName];
}

- (void)showRecommendUserGuide {
    SNPullNewGuide *pullNewGuide = [[SNPullNewGuide alloc] initWithFrame:CGRectMake((kAppScreenWidth - 210) / 2, 80, 210, 55)];
    
    if ([[UIDevice currentDevice] platformTypeForSohuNews] ==
        UIDeviceiPhoneX) {
        pullNewGuide.frame = CGRectMake((kAppScreenWidth - 210) / 2, 80 + 24, 210, 55);
    }
    pullNewGuide.tag = kPullGuideTag;
    [_controller.view addSubview:pullNewGuide];
    
    pullNewGuide.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [UIView animateWithDuration:0.3 animations:^{
        pullNewGuide.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    [SNUtility hideRecommendGuide:[SNUtility sharedUtility].currentChannelId];
}

- (void)removeRecommendUserGuide {
    UIView *pullGuide = [_controller.view viewWithTag:kPullGuideTag];
    if (pullGuide && [pullGuide isKindOfClass:[SNPullNewGuide class]]) {
        [pullGuide removeFromSuperview];
    }
}

- (void)newsFullscreenModeToast {
    [self p_NeedInsertToast];
}

@end
