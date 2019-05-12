//
//  SNVideoDetailViewController.m
//  sohunews
//
//  Created by jojo on 13-8-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoDetailViewController.h"
#import "SNVideoDetailModel.h"
#import "WSMVVideoPlayerView.h"
#import "SNVideoDetailHeadItemView.h"
#import "SNVideoDetailCell.h"
#import "SNVideoDetailRecommendModel.h"
#import "SNNotificationCenter.h"
#import "SNNewAlertView.h"
#import "SNVideoDetailModel.h"
#import "WSMVVideoStatisticManager.h"
#import "SNTripletsLoadingView.h"
#import "SNActionSheet.h"
#import "SNVideosModel.h"
#import "SNTimelineTrendObjects.h"
#import "SNDBManager.h"
#import "SNVideoChannelObjects.h"
#import "SNVideoChannelManager.h"
#import "WSMVVideoHelper.h"
#import "SNMyFavouriteManager.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNUserManager.h"
#import "SNShareConfigs.h"
#import "SNVideoAdContext.h"
#import "SNRollingNewsConst.h"
#import "SNNewsShareManager.h"

#import "sohunewsAppDelegate.h"

#define kVideoDetailPlayerSideMargin                        (0)
#define kVideoDetailPlayerHeight                            (362 / 2)
#define kSectionSelectViewTextFont                          (34 / 2)
#define kSectionSelectViewHeight                            (72 / 2)

#define kRecommendEmptyNoticeViewWidth     (152.f/2.f)
#define kRecommendEmptyNoticeViewHeight    (152.f/2.f)
#define kRecommendEmptyNoticeLabelHeight   (18.f)

#define kRechabilityChangedActionSheetTag                   (1000)

@interface SNVideoDetailViewController () <SNActionSheetDelegate, SNVideosModelDelegate/*, SNClickItemOnHalfViewDelegate*/> {
    SNHeadSelectView *_sectionSelectView;
    UIButton *_shareButton;
    SNTripletsLoadingView *_loadingView;
    
    NSString *_newsfrom;
    UIView *_emptyNoticeView;
}

@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString * subId;

@property (nonatomic, strong) SNVideoData *currentVideo;;
@property (nonatomic, strong) NSMutableArray *timelineVideosOfChannel;
@property (nonatomic, strong) NSMutableArray *offlinePlayVideos;

@property (nonatomic, strong) SNVideoDetailModel *videoDetailModel;
@property (nonatomic, strong) SNVideosModel *videosTimelineModel;
@property (nonatomic, strong) SNVideoDetailRecommendModel *recommendModel;

@property (nonatomic, strong) UIView *statusBarBgView;
@property (nonatomic, strong) WSMVVideoPlayerView *videoPlayer;
@property (nonatomic, strong) UITableView *recommendVideosTableView;
//@property (nonatomic, strong) SNWeiboDetailMoreCell *moreCell;
@property (nonatomic, strong) SNActionSheet *networkStatusActionSheet;

// share
@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager* shareManager;

@property (nonatomic, assign) WSMVVideoPlayerRefer videoPlayerRefer;

//stat
@property (nonatomic, copy) NSString *subIdForVideoStat;

@property(nonatomic, assign)SNRollingNewsVideoPosition rollingNewsVideoPosition;

@property (nonatomic, copy) NSString *newsfrom;

@property (nonatomic, assign) BOOL isdissAppear;
@end

@implementation SNVideoDetailViewController

@synthesize newsfrom = _newsfrom;

#pragma mark - Lifecycle
- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        [[SNVideoAdContext sharedInstance] setCurrentVideoAdPosition:SNVideoAdContextCurrentVideoAdPosition_VideoDetail];
        
        self.rollingNewsVideoPosition = [[query objectForKey:kRollingNewsVideoPosition] intValue];
        self.videoPlayerRefer = [[query objectForKey:kWSMVVideoPlayerReferKey] intValue];
        self.subIdForVideoStat = [query objectForKey:kSubId defalutObj:nil];
        self.currentVideo = [query objectForKey:kDataKey_TimelineVideo ofClass:[SNVideoData class] defaultObj:nil];
        self.link = [query objectForKey:kOpenProtocolOriginalLink2];
        self.subId = query[kSubId]?:@"";
        self.newsfrom = [query objectForKey:kNewsFrom defalutObj:kOtherNews];
        
        if ([[query objectForKey:kNewsExpressType] intValue] == 1){
            self.isPush = YES;
        }
        
        //离线列表进入
        if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
            self.offlinePlayVideos = [query objectForKey:kDataKey_OfflinePlayVideos ofClass:[NSArray class] defaultObj:nil];
        }
        //非离线列表进入
        else {
            self.timelineVideosOfChannel = [query objectForKey:kDataKey_TimelineVideos ofClass:[NSArray class] defaultObj:nil];
            self.videosTimelineModel = [query objectForKey:kDataKey_VideoTabTimelineVideoModel ofClass:[SNVideosModel class] defaultObj:nil];
            self.videosTimelineModel.delegateForDetail = self;
        }
        
        self.channelId = [query stringValueForKey:@"channelId" defaultValue:nil];
        NSString *messageIdPassedIn = nil;
        NSString *vid = nil;
        
        //如果是视频列表进入currentVideo一定有值，否则是二代协议打开
        if (self.currentVideo) {
            messageIdPassedIn = self.currentVideo.messageId;
            vid = self.currentVideo.vid;
        }
        //通过二代协议打开 看看是否传了channelId  mid等参数
        else {
            messageIdPassedIn = [query stringValueForKey:@"mid" defaultValue:nil];
            vid = [query stringValueForKey:@"vid" defaultValue:nil];
        }

        //不是播放离线列表时才从网络加载推荐视频(因为播放离线视频列表时，相关视频列表是已离线视频列表)
        if (self.videoPlayerRefer != WSMVVideoPlayerRefer_OfflinePlay) {
            self.recommendModel = [SNVideoDetailRecommendModel videoRecommendModelWithMid:messageIdPassedIn];
            self.recommendModel.delegate = self;
        }
        
        //如果视频对象为空，则反查
        self.videoDetailModel = [[SNVideoDetailModel alloc] init];
        self.videoDetailModel.vid = vid;
        self.videoDetailModel.mid = messageIdPassedIn;
        self.videoDetailModel.channelId = self.channelId;
        if (!(self.currentVideo)) {
            [self.videoDetailModel refreshVideoDetail];
        }

        [self addNotificationObservers];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0.f, 0.f, kAppScreenWidth, kAppScreenHeight);
    
    //StatusBarBgView
    self.statusBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSystemBarHeight)];
    self.statusBarBgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.statusBarBgView];
    
    //PlayerView
    self.videoPlayer = [[WSMVVideoPlayerView alloc] initWithFrame:CGRectMake(0,
                                                                              kSystemBarHeight,
                                                                              self.view.width - 2 * kVideoDetailPlayerSideMargin,
                                                                              kVideoDetailPlayerHeight)
                                                       andDelegate:self];
    self.videoPlayer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.videoPlayer.videoPlayerRefer = self.videoPlayerRefer;
    
    // 有可能是二代协议打开的 所以这里不一定有值
    if (self.currentVideo) {
        NSArray *videos = nil;
        if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
            videos = self.offlinePlayVideos;
            self.videoPlayer.isPlayingRecommendList = YES;
        }
        else {
            videos = self.timelineVideosOfChannel;
        }
        if (videos.count > 0) {
            NSInteger _playingIndex = [videos indexOfObject:self.currentVideo];
            [self.videoPlayer initPlaylist:videos initPlayingIndex:_playingIndex];
        }
        else {
            [self.videoPlayer initPlaylist:@[self.currentVideo] initPlayingIndex:0];
        }
    }
    [self.view addSubview:self.videoPlayer];
    if (self.currentVideo) {
        [self.videoPlayer playCurrentVideo];
    }
    
    //---
    _sectionSelectView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0,
                                                                            self.videoPlayer.bottom,
                                                                            self.view.width,
                                                                            kSectionSelectViewHeight)];
    _sectionSelectView.userInteractionEnabled = NO;
    _sectionSelectView.textFont = kSectionSelectViewTextFont;
    [self.view addSubview:_sectionSelectView];
    [_sectionSelectView setSections:@[@"相关推荐", @" "] withItemViewClass:[SNVideoDetailHeadItemView class]];
    
    UITableView *newRecmTable = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                              _sectionSelectView.top,
                                                                              self.view.width,
                                                                              0)
                                                             style:UITableViewStylePlain];
    newRecmTable.backgroundColor = [UIColor clearColor];
    newRecmTable.backgroundView = nil;
    newRecmTable.dataSource = self;
    newRecmTable.delegate = self;
    newRecmTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newRecmTable.scrollIndicatorInsets = UIEdgeInsetsMake(_sectionSelectView.height, 0, 50, 0);
    newRecmTable.contentInset = UIEdgeInsetsMake(_sectionSelectView.height, 0, 50, 0);
    newRecmTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:newRecmTable belowSubview:_sectionSelectView];
    self.recommendVideosTableView = newRecmTable;
     //(newRecmTable);
    
    if (!_emptyNoticeView)
    {
        _emptyNoticeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.recommendVideosTableView.frame.origin.y, self.recommendVideosTableView.frame.size.width, kAppScreenHeight - kSystemBarHeight - self.videoPlayer.height)];
        _emptyNoticeView.backgroundColor = [UIColor clearColor];
        _emptyNoticeView.hidden = YES;
        [self.view addSubview:_emptyNoticeView];

        
        UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f,  _emptyNoticeView.height/2, _emptyNoticeView.width, kRecommendEmptyNoticeLabelHeight)];
        NSString *labelColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        UIColor *fontColor = [UIColor colorFromString:labelColorString];
        noticeLabel.textColor = fontColor;
        noticeLabel.text = @"暂时没有相关推荐视频";
        noticeLabel.backgroundColor = [UIColor clearColor];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyNoticeView addSubview:noticeLabel];
    }
    
    [self createLoadingView];
    [self addToolbar];
    
    // 是否可以分享
    _shareButton.enabled = !!(self.currentVideo); // 不再通过接口来请求 从currentVideo数据中获取
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.recommendVideosTableView.height = kAppScreenHeight - kSystemBarHeight - self.videoPlayer.height;
    //离线列表进入播放页进行离线播放，相关视频应该是离线视频列表，所以不需要联网查询相关视频
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
        [self refreshRecommendVideosOfOfflinePlay];
    } else {
        if (self.recommendModel.videos.count == 0) {
            [self.recommendModel loadRecommendVideosFromServer];
        }
    }
}

- (SNCCPVPage)currentPage {
    return videoDetail;
}

- (NSString *)currentOpenLink2Url {
    return self.link;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:YES];
//    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.newsfrom) {
        [dict setValue:self.newsfrom forKey:kNewsFrom];
    }
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController dictInfo:dict];
    self.isdissAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIViewController *snsViewController = [self.flipboardNavigationController previousViewController];
    if (snsViewController && [snsViewController isKindOfClass:NSClassFromString(@"SNSPlaygroundViewController")]) {
        self.isdissAppear = YES;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:NO];

    
    [_videoPlayer stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.statusBarBgView = nil;
    
    [_videoPlayer stop];
    _videoPlayer.delegate = nil;
     //(_videoPlayer);
     //(_sectionSelectView);
     //(_recommendVideosTableView);
     //(_moreCell);
     //(_networkStatusActionSheet);
    
     //(_shareButton);
    _loadingView.delegate = nil;
     //(_loadingView);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    _videosTimelineModel.delegateForDetail = nil;
    _recommendModel.delegate = nil;
    
    [_videoPlayer clearMoviePlayerController];
    [_videoPlayer removeFromSuperview];
    _loadingView.delegate = nil;
    
    _actionMenuController.delegate = nil;
}

#pragma mark - overrides

- (void)onBack:(id)sender {
    [self.videoPlayer stop];
    [self.videoPlayer forceStop];
    self.videoPlayer.delegate = nil;
    
    [[WSMVVideoStatisticManager sharedIntance] statVideoSV];
    
    [super onBack:sender];
}

- (void)addToolbar {
    [super addToolbar];
    
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [_shareButton setImage:[UIImage imageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
    [_shareButton setImage:[UIImage imageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
    [_shareButton addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
    [_shareButton setAccessibilityLabel:@"分享"];
    [_toolbarView setRightButton:_shareButton];
}

#pragma mark - StatusBarStyle for iOS7+
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.isdissAppear ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark - actions
//视频频道  视频分享
- (void)actionShare:(id)sender {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];

    NSString * protocol = [NSString stringWithFormat:@"%@vid=%@&mid=%@&columnId=%d&from=channel&channelId=%@",kProtocolVideo,self.videoPlayer.playingVideoModel.vid,self.videoPlayer.playingVideoModel.messageId,self.videoPlayer.playingVideoModel.columnId,self.videoPlayer.playingVideoModel.channelId];
    
    [mDic setObject:protocol forKey:@"url"];
    [mDic setObject:self.subId?:@"" forKey:kSubId];
    [mDic setObject:@"video" forKey:@"contentType"];
    [mDic setObject:[NSString stringWithFormat:@"mid=%@",self.videoPlayer.playingVideoModel.messageId] forKey:@"referString"];
    NSString* sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeVedio];//SNShareSourceTypeSpecial
    [mDic setObject:sourceType forKey:@"sourceType"];
    [mDic setObject:@"video" forKey:@"shareLogType"];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    NSString * protocolUrl = [NSString stringWithFormat:@"%@vid=%@&mid=%@&columnId=%d&from=channel&channelId=%@",kProtocolVideo,self.videoPlayer.playingVideoModel.vid,self.videoPlayer.playingVideoModel.messageId,self.videoPlayer.playingVideoModel.columnId,self.videoPlayer.playingVideoModel.channelId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [_actionMenuController.contextDic setObject:self.subId?:@"" forKey:kSubId];
    [_actionMenuController.contextDic setObject:@"video" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"mid=%@",self.videoPlayer.playingVideoModel.messageId] forKey:@"referString"];

    _actionMenuController.shareLogType = @"video";
    _actionMenuController.delegate = self;
    _actionMenuController.disableLikeBtn = NO;
    _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    _actionMenuController.sourceType = 14;
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
    SNVideoFavourite *videoFavourite = [[SNVideoFavourite alloc] init];
    videoFavourite.type = MYFAVOURITE_REFER_VIDEO;
    videoFavourite.contentLevelFirstID = @"100";//相关推荐没有channelID,默认视频的channelID传100
    videoFavourite.contentLevelSecondID = self.videoPlayer.playingVideoModel.messageId;
    videoFavourite.link2 = self.videoPlayer.playingVideoModel.link2;
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:videoFavourite];
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
    SNVideoFavourite *videoFavourite = [[SNVideoFavourite alloc] init];
    videoFavourite.type = MYFAVOURITE_REFER_VIDEO;
    videoFavourite.contentLevelFirstID = @"100";//相关推荐没有channelID,默认视频的channelID传100
    videoFavourite.contentLevelSecondID = self.videoPlayer.playingVideoModel.messageId;
    videoFavourite.title = self.videoPlayer.playingVideoModel.title;
    videoFavourite.link2 = self.videoPlayer.playingVideoModel.link2;
    if ([self.videoPlayer isFullScreen] && ![SNUserManager isLogin])
    {
        [self.videoPlayer exitFullScreen];
        double delayInSeconds = .6f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:videoFavourite corpusDict:dict];
        });
    }
    else
    {
        [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:videoFavourite corpusDict:dict];
    }
}

- (void)handleViewControllerPopup:(NSNotification *)notification {
//    [self.videoPlayer stop];
}

- (void)handleDidReceiveNotification:(id)sender {
//    if (self.videoPlayer.isPlaying) {
//        [self.videoPlayer pause];
//    }
}

- (void)handleShareWithCommentControllerDidDismissNotification:(NSNotification *)notification {
//    if (!self.videoPlayer.isPlaying) {
//        [self.videoPlayer playCurrentVideo];
//    }
}

#pragma mark - UITableView datasource & delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kVideoDetailCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
        return self.offlinePlayVideos.count;
    }
    else {
        return self.recommendModel.videos.count + (self.recommendModel.hasMore ? 1 : 0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *videos = nil;
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
        videos = self.offlinePlayVideos;
    }
    else {
        videos = self.recommendModel.videos;
    }
    
    if (indexPath.row < videos.count) {
        static NSString *cellIdty = @"videoCellIdty";
        SNVideoDetailCell *videoCell = [tableView dequeueReusableCellWithIdentifier:cellIdty];
        if (!videoCell) {
            videoCell = [[SNVideoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdty];
        }
        videoCell.delegate = self;
        videoCell.video = [videos objectAtIndex:indexPath.row];
        
        return videoCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectRowAtIndexPath:indexPath];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *videos = nil;
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
        videos = self.offlinePlayVideos;
    }
    else {
        videos = self.recommendModel.videos;
    }
    
    if (indexPath.row < videos.count) {
        self.videoPlayer.isPlayingRecommendList = YES;
        _shareButton.enabled = YES;
        [self.videoPlayer initPlaylist:videos initPlayingIndex:indexPath.row];
        [self.videoPlayer playCurrentVideo];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - SNVideoDetailRecommendModel

- (void)videoRecommendModelDidStartLoad:(SNVideoDetailRecommendModel *)recModel {
    if (recModel == self.recommendModel && self.recommendModel.videos.count == 0) {
        _loadingView.status = SNTripletsLoadingStatusLoading;
    }
}

- (void)videoRecommendModelDidFailLoadWithError:(NSError*)error model:(SNVideoDetailRecommendModel *)recModel {
    if (recModel.videos.count > 0) {
        _loadingView.status = SNTripletsLoadingStatusStopped;
    } else {
        _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
    }
}

- (void)handleRecommendModelDidFinishLoad:(NSNotification *)notification {
    if (notification.object == self.recommendModel) {
        _loadingView.status = SNTripletsLoadingStatusStopped;
        _emptyNoticeView.hidden = YES;
        NSDictionary *resultDic = notification.userInfo;
        int resultCode = [resultDic intValueForKey:@"result" defaultValue:-1];

            if (resultCode == 0) {
                [self.recommendVideosTableView reloadData];
                
                if (self.recommendModel.videos.count == 0) {
                    _loadingView.status = SNTripletsLoadingStatusEmpty;
                    _emptyNoticeView.hidden = NO;
                }
                
                //[self.moreCell showLoading:NO];
                //[self.moreCell setHasNoMore:!self.recommendModel.hasMore];
                
    
                
                if ([[resultDic objectForKey:@"isMore"] boolValue]) {
                    NSArray *moreData = [resultDic arrayValueForKey:@"moreData" defaultValue:nil];
                    if (self.videoPlayer.isPlayingRecommendList) {
                        [self.videoPlayer appendPlaylist:moreData];
                    }
                    [self.videoPlayer appendRecommendVideos:moreData];
                }
                else {
                    [self.videoPlayer replaceAllRecommendVieos:self.recommendModel.videos];
                }
            }
            else {
                _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
            }
        
    }
}

#pragma mark - SNVideosDelegate

- (void)videosDidFinishLoad {
    if (self.videosTimelineModel.moreDataArray.count > 0) {
        
        //===如果更多timeline数据不在timelineVideosOfChannel里则加到timelineVideosOfChannel里(尤其指不是从视频timeline进入播放页的)，以便在将要播下一个视频时加载对应的相关视频
        if (!(self.timelineVideosOfChannel)) {
            self.timelineVideosOfChannel = [NSMutableArray array];
        }
        NSMutableArray *tempArray = [NSMutableArray array];
        for (SNVideoData *moreItem in self.videosTimelineModel.moreDataArray) {
            BOOL existedInTimelineVideosOfChannel = NO;
            for (SNVideoData *tempItem in self.timelineVideosOfChannel) {
                if ([moreItem.vid isEqualToString:tempItem.vid]) {
                    existedInTimelineVideosOfChannel = YES;
                    break;
                }
            }
            if (!existedInTimelineVideosOfChannel) {
                [tempArray addObject:moreItem];
            }
        }
        if (tempArray.count > 0) {
            [self.timelineVideosOfChannel addObjectsFromArray:tempArray];
        }
        //===
        
        [self.videoPlayer appendPlaylist:self.videosTimelineModel.moreDataArray];
    }
}

- (void)videosDidFailLoadWithError:(NSError *)error {
    SNDebugLog(@"%@-%@ : error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
}

- (void)videosDidCancelLoad {
    // do nothing
    SNDebugLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - SNVideoDetailModel

- (void)handleVideoDetailModelDidFinishLoad:(NSNotification *)notification {
    if (notification.object == self.videoDetailModel) {
        self.currentVideo = self.videoDetailModel.videoDetailItem;
        _shareButton.enabled = !!(self.currentVideo);
        if (self.currentVideo) {
            SNVideoData *tempPlayerVideo = self.currentVideo;
            if (!!tempPlayerVideo) {
                self.videoPlayer.moviePlayer.view.frame = self.videoPlayer.bounds;
                [self.videoPlayer initPlaylist:@[tempPlayerVideo] initPlayingIndex:0];
                
                [self.videoPlayer playCurrentVideo];
            }
        }
        
        [self loadChannelTimelineVideosIfNeeded];
    }
}

- (void)handleVideoDetailModelShareContentDidFinishLoad:(NSNotification *)notification {
    if (notification.object == self.videoDetailModel) {
//        _shareButton.enabled = !!self.videoDetailModel.shareContent; // 不再通过接口来请求 从currentVideo数据中获取
    }
}

#pragma mark - Load VideoTimeline Videos
- (void)loadChannelTimelineVideosIfNeeded {
    /**
     * 如果没有从外部Timeline传入videosTimelineModel(即videosTimelineModel为空)且有播放页视频数据(即currentVideo不为空)
     * 则开始加载第一页video timeline数据
     */
    if (!(self.videosTimelineModel) && !!(self.currentVideo) && self.currentVideo.channelId.length > 0) {
        _videosTimelineModel = [[SNVideosModel alloc] initWithChannelId:self.currentVideo.channelId];
        _videosTimelineModel.delegateForDetail = self;
        [_videosTimelineModel refresh];
    }
}

#pragma mark - SNNavigationController - Override
- (BOOL)shouldRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer withTouch:(UITouch *)touch {
    UIView *touchView = touch.view;
    SNDebugLog(@"==============Touch view is %@", NSStringFromClass(touchView.class));
    return !([touchView isKindOfClass:[WSMVSlider class]]);
}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer {
    return (self.videoPlayer.playingIndex == 0);
}

#pragma mark - WSMVVideoPlayerViewDelegate

- (void)thereIsNoPreVideo:(WSMVVideoPlayerView *)playerView {
    if ([playerView isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"alreadFirstVideo", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        //非全屏下没有前一个时不提示，直接返回timeline.
    }
}

- (void)willPlayPreVideo:(SNVideoData *)video {
    NSLogInfo(@"Ready to load pre video's recommend videos");
    // 用户没有点过相关推荐的视频  加载当前视频的相关推荐
    if (!self.videoPlayer.isPlayingRecommendList) {
        [self switchRecommendVideosWithMid:video.messageId];
    }
}

- (void)thereisNoNextVideo:(WSMVVideoPlayerView *)playerView {
    if ([playerView isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"alreadLastVideo", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"alreadLastVideo", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

- (void)willPlayNextVideo:(SNVideoData *)video {
    NSLogInfo(@"Ready to load next video's recommend videos");
    // 用户没有点过相关推荐的视频  加载当前视频的相关推荐
    if (!self.videoPlayer.isPlayingRecommendList) {
        [self switchRecommendVideosWithMid:video.messageId];
    }
}

#pragma mark -
- (void)willPlayVideo:(SNVideoData *)video {
    //播放timeline流
    if (!(self.videoPlayer.isPlayingRecommendList)) {
        for (SNVideoData *vItem in self.videosTimelineModel.dataArray) {
            if ([vItem.messageId isEqualToString:video.messageId]) {//将要播放的video是timeline流中的其中一个视频
                self.currentVideo = vItem;
                break;
            }
        }
    }
    //播放相关流
    else {
        // 在相关推荐中 高亮显示当前正在播放的视频
        NSArray *videos = nil;
        if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
            videos = self.offlinePlayVideos;
        }
        else {
            videos = self.recommendModel.videos;
        }
        for (SNVideoData *vItem in videos) {
            if ([vItem.messageId isEqualToString:video.messageId]) {
                self.currentVideo = vItem; // 替换当前播放的视频model
                break;
            }
        }
    }
    
    [self.recommendVideosTableView reloadData];
}

- (void)didPlayVideo:(SNVideoData *)video {
}

#pragma mark -
- (NSArray *)recommendVideosOfVideoModel:(SNVideoData *)playingVideoModel more:(BOOL)more {
    if (!more) {
        return self.recommendModel.videos;
    }
    // 加载更多
    else {
        [self loadMoreRecommendVideos];
        return nil;
    }
}

- (void)needMoreRecommendIntoPlaylist {
    [self loadMoreRecommendVideos];
}

- (void)needMoreTimelineIntoPlaylist {
    if (self.videosTimelineModel && !self.videosTimelineModel.hasNoMore) {
        [self.videosTimelineModel loadMore];
    }
}

//进入全屏视频分享
- (void)willShareVideo:(SNVideoData *)video fromPlayer:(WSMVVideoPlayerView *)player {
    
#if 1 //wangshun share test 这好像不走了
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    _actionMenuController.delegate = self;
    
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    NSString * protocolUrl = [NSString stringWithFormat:@"%@vid=%@&mid=%@&columnId=%d&from=channel&channelId=%@",kProtocolVideo,self.videoPlayer.playingVideoModel.vid,self.videoPlayer.playingVideoModel.messageId,self.videoPlayer.playingVideoModel.columnId,self.videoPlayer.playingVideoModel.channelId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [_actionMenuController.contextDic setObject:self.subId?:@"" forKey:kSubId];
    [_actionMenuController.contextDic setObject:@"video" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"mid=%@",self.videoPlayer.playingVideoModel.messageId] forKey:@"referString"];
    _actionMenuController.shareLogType = @"video";
    
    _actionMenuController.disableLikeBtn = NO;
    _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    _actionMenuController.sourceType = 14;
    [_actionMenuController showActionMenuFromLandscapeView:player];

}

- (void)toWapPageOf:(SNVideoData *)video {
    SNDebugLog(@"To html5 player page.");
    
    NSString *_url = video.wapUrl;
//    if (![[_url lowercaseString] hasPrefix:@"http://"]) {
//        _url = [@"http://" stringByAppendingString:_url];
//    }
    if(![SNAPI isWebURL:_url]){
        _url = [[SNAPI rootSchemeUrl:_url] stringByAppendingString:_url];
    }
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:_url forKey:@"address"];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

#pragma mark - 2G3G提示
- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style forPlayerView:(WSMVVideoPlayerView *)playerView {
    if (style == WSMV2G3GAlertStyle_Block) {
        [playerView pause];
        SNDebugLog(@"Will show 2G3G alert with blockUI.");
        
        // 全屏状态下 先退出全屏
        if (playerView.isFullScreen) {
            [playerView exitFullScreen];
            double delayInSeconds = .5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self showNetworkWarningAciontSheetForPlayer:playerView];
            });
        }
        // 竖屏状态下直接弹出流量提醒
        else {
            [self showNetworkWarningAciontSheetForPlayer:playerView];
        }
    }
    else if (style == WSMV2G3GAlertStyle_VideoPlayingToast) {
        SNDebugLog(@"Will show 2G3G alert with toastUI.");
        
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
    }
    else if (style == WSMV2G3GAlertStyle_NetChangedTo2G3GToast) {
        SNDebugLog(@"Toast for network changed to 2G/3G.");
        
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
        }
    }
    else if (style == WSMV2G3GAlertStyle_NotReachable) {
        [playerView pause];
        if ([playerView isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeWarning];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
    else {
        SNDebugLog(@"Needn't show 2G3G alert UI currently.");
    }
    
    // 如果网络恢复了 并且相关推荐还没有加载出来  重新加载
    if ([SNUtility getApplicationDelegate].isNetworkReachable && _loadingView && self.recommendModel.videos.count == 0) {
        [self.recommendModel loadRecommendVideosFromServer];
    }
    
    // 如果网络恢复了 并且当前视频对象没有数据  重新加载
    if ([SNUtility getApplicationDelegate].isNetworkReachable && !(self.currentVideo)) {
        [self.videoDetailModel refreshVideoDetail];
    }
}

- (void)showNetworkWarningAciontSheetForPlayer:(WSMVVideoPlayerView *)playerView {

    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"2g3g_actionsheet_info_content", nil) cancelButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_cancel", nil) otherButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_play", nil)];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = NO;
        [self onBack:nil];
    }otherButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = YES;
        [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
        [playerView playCurrentVideo];
    }];
    
}

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SNDebugLog(@"Tapped actionSheet at buttonIndex %d", buttonIndex);
    
    WSMVVideoPlayerView *playerView = [[actionSheet userInfo] objectForKey:kPlayerViewWithActionSheet];
    if (actionSheet.tag == kRechabilityChangedActionSheetTag) {
        if (buttonIndex == 0) {//取消
            playerView.playingVideoModel.hadEverAlert2G3G = NO;
            [self onBack:nil];
        }
        else if (buttonIndex == 1) {//播放
            playerView.playingVideoModel.hadEverAlert2G3G = YES;
            [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
            [playerView playCurrentVideo];
        }
    }
}

- (void)dismissActionSheetByTouchBgView:(SNActionSheet *)actionSheet {
    [self onBack:nil];
}

#pragma mark - Statistic
- (void)statVideoPV:(SNVideoData *)willPlayModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = willPlayModel.vid.length > 0 ? willPlayModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = self.channelId.length > 0 ? self.channelId : @"";
    _vStatModel.messageId =  willPlayModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    [[WSMVVideoStatisticManager sharedIntance] statVideoPV:_vStatModel];
}

- (void)statVideoVV:(SNVideoData *)finishedPlayModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = finishedPlayModel.vid.length > 0 ? finishedPlayModel.vid : @"";
    _vStatModel.subId = self.subIdForVideoStat;
    _vStatModel.newsId = @"";
    _vStatModel.channelId = self.channelId.length > 0 ? self.channelId : @"";
    _vStatModel.messageId = finishedPlayModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    _vStatModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + finishedPlayModel.playedTime;
    _vStatModel.totalTimeInSeconds = finishedPlayModel.totalTime;
    _vStatModel.siteId = finishedPlayModel.siteInfo.siteId;
    _vStatModel.columnId = [NSString stringWithFormat:@"%d", finishedPlayModel.columnId];
    
    SHMedia *shMedia = [self.videoPlayer getMoviePlayer].currentPlayMedia;
    SHMediaSourceType movieSourceType = shMedia.sourceType;
    if (movieSourceType == SHLocalDownload) {
        _vStatModel.offline = kWSMVStatVV_Offline_YES;
    }
    else {
        _vStatModel.offline = kWSMVStatVV_Offline_NO;
    }
    
    [[WSMVVideoStatisticManager sharedIntance] statVideoVV:_vStatModel inVideoPlayer:videoPlayerView];
}

//累计连播数据以便在调起播放器页不再使用播放器时统计连播
- (void)cacheVideoSV:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_statModel = [[WSMVVideoStatisticModel alloc] init];
    _statModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _statModel.newsId = @"";
    _statModel.messageId = videoModel.messageId;
    _statModel.refer = [self videoStatRefer];
    _statModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + videoModel.playedTime;
    [[WSMVVideoStatisticManager sharedIntance] cacheVideoSV:_statModel];
}

- (void)statVideoAV:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = self.channelId.length > 0 ? self.channelId : @"";
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    [[WSMVVideoStatisticManager sharedIntance] statVideoPlayerActions:_vStatModel actionsData:videoPlayerView.playerActionsStatData];
}

- (void)statFFL:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView succeededToLoad:(BOOL)succeededToLoad {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = self.channelId.length > 0 ? self.channelId : @"";
    _vStatModel.messageId =  videoModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    _vStatModel.succeededToFFL = succeededToLoad;
    _vStatModel.siteId = videoModel.siteInfo.siteId;
    [[WSMVVideoStatisticManager sharedIntance] statFFL:_vStatModel];
}

- (VideoStatRefer)videoStatRefer {
    if (self.subIdForVideoStat.length > 0) {
        return VideoStatRefer_Pub;
    }
    else if (self.rollingNewsVideoPosition == SNRollingNewsVideoPosition_RecommVideoLink2) {
        return VideoStatRefer_RecommVideoInRollingNews;
    }
    else if (self.rollingNewsVideoPosition == SNRollingNewsVideoPosition_NormalVideoLink2) {
        return VideoStatRefer_RollingNews;
    }
    else  {
        return VideoStatRefer_VideoTab;
    }
}

#pragma mark - SNActionMenuControllerDelegate

- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    if (self.videoPlayer.playingVideoModel.vid.length > 0) {
        [dicInfo setObject:self.videoPlayer.playingVideoModel.vid forKey:@"vid"];
    }
    
    if (self.currentVideo.messageId.length > 0) {
        [dicInfo setObject:self.currentVideo.messageId forKey:@"mid"];
    }
    
    if (self.currentVideo.share.content) {
        [dicInfo setObject:self.currentVideo.share.content forKey:kShareInfoKeyContent];
    }

    // generate share read content
    SNTimelineOriginContentObject *shareRead = [[SNTimelineOriginContentObject alloc] init];
    shareRead.title = self.currentVideo.title;
    shareRead.abstract = self.currentVideo.abstract;
    shareRead.sourceType = SNShareSourceTypeVedio;
    shareRead.link = self.currentVideo.share.h5Url;
    shareRead.ugcWordLimit = self.currentVideo.share.ugcWordLimit;
    
    if (self.currentVideo.poster) {
        shareRead.picsArray = [NSMutableArray arrayWithObject:self.currentVideo.poster];
//        shareRead.picUrl = self.currentVideo.poster;
        shareRead.subId = nil;
        
        [dicInfo setObject:self.currentVideo.poster forKey:kShareInfoKeyImageUrl];
    }
    
    if (shareRead) {
        [dicInfo setObject:shareRead forKey:kShareInfoKeyShareRead];
    }
    
    if (self.currentVideo.share.h5Url.length > 0) {
        [dicInfo setObject:self.currentVideo.share.h5Url forKey:kShareInfoKeyMediaUrl];
    }
    
    //log
    if ([self.currentVideo.messageId length] > 0) {
        [dicInfo setObject:self.currentVideo.messageId forKey:kShareInfoKeyNewsId];
    }
    if ([self.currentVideo.share.content length] > 0) {
        [dicInfo setObject:self.currentVideo.share.content forKey:kShareInfoKeyShareContent];
    }
    if (self.subIdForVideoStat.length > 0) {
        [dicInfo setObject:self.subIdForVideoStat forKey:kShareInfoLogKeySubId];
    }
    
    //mail title
    if (self.currentVideo.title.length > 0) {
        [dicInfo setObject:self.currentVideo.title forKey:kShareInfoKeyTitle];
    }
    
    return dicInfo;
}

#pragma mark - SNVideoDetailCellDelegate
- (NSString *)playingMessageId {
    return self.currentVideo.messageId;
}

- (void)didTapCellThumbnailInCell:(SNVideoDetailCell *)cell {
    NSIndexPath *indexPath = [self.recommendVideosTableView indexPathForCell:cell];
    [self didSelectRowAtIndexPath:indexPath];
}

#pragma mark - private
- (void)addNotificationObservers {
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleRecommendModelDidFinishLoad:)
                                                 name:kSNVideoDetialRecommendModelDidFinishLoadNotification
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleVideoDetailModelDidFinishLoad:)
                                                 name:kSNVideoDetailDidFinishLoadNotification
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleVideoDetailModelShareContentDidFinishLoad:)
                                                 name:kSNVideoDetailShareContentDidFinishLoadNotification
                                               object:nil];
    // 收到推送
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleDidReceiveNotification:)
                                                 name:kNotifyDidReceive
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleShareWithCommentControllerDidDismissNotification:)
                                                 name:kShareWithCommentControllerDidDismissNotification
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleViewControllerPopup:)
                                                 name:kStopAudioNotification
                                               object:nil];
}

- (void)createLoadingView {
    if (!_loadingView) {
        CGFloat top = _sectionSelectView.top;
        CGFloat height = self.view.height-top;
        _loadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0,
                                                                               top,
                                                                               self.view.width,
                                                                               height)];
        _loadingView.delegate = self;
        [self.view insertSubview:_loadingView belowSubview:_sectionSelectView];
    }
}

- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    [self.recommendModel loadRecommendVideosFromServer];
}

//从当前视频流里面 找到某个视频  通过messageId刷新相关推荐
- (void)switchRecommendVideosWithMid:(NSString *)mid {
    for (SNVideoData *currentVideo in self.timelineVideosOfChannel) {
        if ([currentVideo.messageId isEqualToString:mid]) {
            self.recommendModel = [SNVideoDetailRecommendModel videoRecommendModelWithMid:currentVideo.messageId];
            self.recommendModel.delegate = self;
            
            [self.recommendModel loadRecommendVideosFromServer];
            [self.recommendVideosTableView reloadData];
            break;
        }
    }
}

- (void)loadMoreRecommendVideos {
    if (self.recommendModel.hasMore) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            [self.recommendModel loadRecommendVideosMoreFromServer];
            //[self.moreCell showLoading:YES];
        }
        else {
            //[self.moreCell showLoading:NO];
            //[self.moreCell setPromtLabelText:NSLocalizedString(@"network error", @"")];
        }
    }
    else {
        //[self.moreCell showLoading:NO];
        //[self.moreCell setHasNoMore:YES];
    }
}

#pragma mark - About offlineplay
- (void)refreshRecommendVideosOfOfflinePlay {
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
        _loadingView.status = SNTripletsLoadingStatusStopped;

        //[self.moreCell showLoading:NO];
        //[self.moreCell setHasNoMore:YES];
        
        if (self.offlinePlayVideos.count == 0) {
            _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        } else {
            [self.videoPlayer replaceAllRecommendVieos:self.offlinePlayVideos];
        }
        
        [self.recommendVideosTableView reloadData];
    }
}

@end
