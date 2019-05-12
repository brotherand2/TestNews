//
//  SNRollingPageViewCell.m
//  sohunews
//
//  Created by wangyy on 16/1/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingPageViewCell.h"
#import "UIFont+Theme.h"
#import "SNCellImageView.h"
#import "SNCommonNewsController.h"
#import "SNRollingNewsConst.h"
#import "SNCommonNewsDatasource.h"
#import "SNNewsAd+analytics.h"
#import "SNUserManager.h"
#import "SNNewsReport.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNConsts.h"

@interface SNRollingPageViewCell ()

@property (nonatomic, strong) NSTimer *myTimer;

@end

static CGFloat rowCellHeight = 0.0;

@implementation SNRollingPageViewCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kCellHeight);
    }
    return rowCellHeight + 5;
}

- (void)dealloc {
    [self.scrollView removeAllSubviews];
    self.scrollView = nil;
    self.pageControl = nil;
    self.newsTitle = nil;
    self.videoIcon = nil;
    self.adIcon = nil;
    self.adTitle = nil;
    self.rollingPageArray = nil;
    [self.myTimer invalidate];
    self.myTimer = nil;
    
    [SNNotificationManager removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self addScrollView];
        [self addTitleMarkView];
        [self addFocusContentView];
        [self addPageControl];

        [SNNotificationManager addObserver:self selector:@selector(removeTimer) name:UIApplicationWillResignActiveNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(addTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
        //启动页结束后，开启timer
        [SNNotificationManager addObserver:self selector:@selector(dealTimer) name:kIs3DTouchShowKeyboard object:nil];
        
        //切换频道或进入正文，启停定时器
        [SNNotificationManager addObserver:self selector:@selector(dealTimer:) name:kStopPageTimerNotification object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(showFirstPageNewItem) name:kShowFirstPageNotification object:nil];
    }
    return self;
}

- (void)addDefaultBGView {
    UIImageView *bgGroundView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:kThemeImgPlaceholder5]];
    bgGroundView.frame = CGRectMake(0, 0, kCellWidth, kFocusImageHeight);
    [self.contentView addSubview:bgGroundView];
}

- (void)addScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kFocusImageHeight)];
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
    [self.contentView addSubview:self.scrollView];
    
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNews)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
}

- (void)addFocusContentView {
    UIFont *titleFont = [SNUtility getNewsTitleFont];
    CGFloat fontSize = [SNUtility getNewsTitleFontSize];
    self.newsTitle = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT,0,kAppScreenWidth - 2*CONTENT_LEFT,fontSize + 1)];
    self.newsTitle.backgroundColor = [UIColor clearColor];
    self.newsTitle.textColor = [UIColor whiteColor];
    self.newsTitle.font = titleFont;
    self.newsTitle.bottom = kFocusImageHeight - 14;
    [self.contentView addSubview:self.newsTitle];
    
    UIImage *videoImage = [UIImage imageNamed:@"icohome_focus_videosmall_v5.png"];
    int videoBottom = kFocusImageHeight - VIDEO_ICON_WIDTH - 14;
    self.videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT,videoBottom,VIDEO_ICON_WIDTH, VIDEO_ICON_WIDTH)];
    self.videoIcon.image = videoImage;
    self.videoIcon.centerY = self.newsTitle.centerY;
    self.videoIcon.alpha = themeImageAlphaValue();
    self.videoIcon.hidden = YES;
    [self addSubview:self.videoIcon];

    self.adIcon = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, [[SNDevice sharedInstance] isPlus] ? videoBottom + 2 : videoBottom + 3, 29, 14)];
    self.adIcon.image = [UIImage themeImageNamed:@"icohome_ad_Label_v5.png"];
    self.adIcon.hidden = YES;
    self.adIcon.centerY = self.newsTitle.centerY;
    [self addSubview:self.adIcon];
    
    self.adTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 14)];
    self.adTitle.font = [UIFont systemFontOfSize:kThemeFontSizeA];
    self.adTitle.backgroundColor = [UIColor clearColor];
    self.adTitle.textColor = [UIColor whiteColor];
    self.adTitle.textAlignment = NSTextAlignmentCenter;
    [self.adIcon addSubview:self.adTitle];
}

- (void)addPageControl {
    self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(kAppScreenWidth - 42, kCellHeight - 23, 28, 15)];

    self.pageControl.indicatorMargin = 3.0f;
    self.pageControl.indicatorDiameter = 3.0f;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.centerY = self.newsTitle.centerY;
    [self.contentView addSubview:self.pageControl];
    
    self.pageControl.backgroundColor = [UIColor clearColor];
    
    [self.pageControl setPageIndicatorImage:[UIImage imageNamed:@"icohome_smadot_v5.png"]];
    [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"icohome_bigdot_v5.png"]];
}

- (void)addTitleMarkView {
    self.titleMarkView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"news_headline_titlemark.png"]];
    self.titleMarkView.frame = CGRectMake(0, kFocusImageHeight - 42, kAppScreenWidth, 42);
    [self.contentView addSubview:self.titleMarkView];
}

- (void)addTimer {
    if (![self.item.news.channelId isEqualToString:[SNUtility sharedUtility].currentChannelId]) {
        return;
    }
    if (self.myTimer != nil) {
        return;
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(showNexPageNews) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    self.myTimer = timer;
}

- (void)removeTimer {
    if (self.myTimer == nil) {
        return;
    }
    
    [self.myTimer invalidate];
    self.myTimer = nil;
}

- (void)dealTimer {
    [self removeTimer];
    [self addTimer];
}

- (void)dealTimer:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *channelId = [userInfo objectForKey:@"stopChannelId"];
    if ([channelId isEqualToString:self.item.news.channelId]) {
        BOOL stopflag = [[userInfo objectForKey:@"stopFlag"] boolValue];
        if (stopflag) {
            [self removeTimer];
        } else {
            [self addTimer];
        }
    }
}

#pragma mark 滚动停止事件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _currentImageIndex = page;
    self.pageControl.currentPage = (page - 1);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int pageCount = self.rollingPageArray.count;
    if (_currentImageIndex == 0) {
        [scrollView setContentOffset:CGPointMake((pageCount - 2) * kCellWidth, 0)];
    }
    if (_currentImageIndex == (pageCount - 1)) {
        [_scrollView setContentOffset:CGPointMake(kCellWidth, 0)];
    }
    int titleIndex = _currentImageIndex - 1;
    if (titleIndex == pageCount) {
        titleIndex = 0;
    }
    if (titleIndex < 0) {
        titleIndex = pageCount - 1;
    }
   
    SNRollingNews *newsItem = [self.item.news.newsFocusArray objectAtIndex:titleIndex];
   
    self.videoIcon.hidden = ![self hasVideo:newsItem.hasVideo];
    CGFloat offsetValue = [self hasVideo:newsItem.hasVideo] ? VIDEO_ICON_WIDTH + 7 : 0;
    if ([newsItem.newsType isEqualToString:kNewsTypeAd]) {
        [newsItem.newsAd reportAdOneDisplay:newsItem];
        if (newsItem.iconText && newsItem.iconText.length > 0) {
            self.adIcon.hidden = NO;
            self.adTitle.text = newsItem.iconText;
            CGSize titleSize = [self.adTitle.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
            self.adIcon.width = titleSize.width + 6;
            self.adTitle.width = titleSize.width + 6;
            
            offsetValue = 5 + self.adIcon.width;
        }
    } else {
        self.adIcon.hidden = YES;
        [SNStatisticsInfoAdaptor cacheTimelineNewsShowBusinessStatisticsInfo:newsItem];
    }
    
    CGRect frame = self.newsTitle.frame;
    frame.size.width = kAppScreenWidth - 3*CONTENT_LEFT - (self.pageControl.frame.size.width - 3) - offsetValue;
    frame.origin.x = CONTENT_LEFT + offsetValue;
    self.newsTitle.frame = frame;
    self.newsTitle.text= [NSString stringWithFormat:@"%@", newsItem.title];
    
    [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:_currentImageIndex channelId:self.item.news.channelId];
}

- (void)updateTheme {
    [super updateTheme];

    _pageControl.alpha = themeImageAlphaValue();
    _newsTitle.alpha = themeImageAlphaValue();
    self.videoIcon.alpha = themeImageAlphaValue();
    self.adTitle.alpha = themeImageAlphaValue();
    self.adIcon.alpha = themeImageAlphaValue();
    for (UIView *subView in _scrollView.subviews) {
        if ([subView isKindOfClass:[SNCellImageView class]]) {
            SNCellImageView *focusImage = (SNCellImageView *)subView;
            [focusImage updateTheme];
            [focusImage updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder5]];
        }
    }
}

- (void)updateImage {
    [_scrollView removeAllSubviews];
    [self.pageImageViews removeAllObjects];
    for (int i = 0; i < self.rollingPageArray.count; i++) {
        SNCellImageView *focusImage = [[SNCellImageView alloc] initWithFrame:CGRectMake(i * kCellWidth, 0, kCellWidth, kFocusImageHeight)];
        SNRollingNews *newsItem = [self.rollingPageArray objectAtIndex:i];
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newsItem.picUrl];
        UIImage *defaultImage = nil;
        if (cacheImage) {
            defaultImage = cacheImage;
        } else {
            defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
        }
        [focusImage updateImageWithUrl:newsItem.picUrl
                          defaultImage:defaultImage showVideo:NO];
        [_scrollView addSubview:focusImage];
        [self.pageImageViews addObject:focusImage];
    }
}

- (void)updateContentView {
    [super updateContentView];
    [self updateTheme];
    moreButton.hidden = YES;
    self.videoIcon.hidden = YES;
    
    UIFont *titleFont = [SNUtility getNewsTitleFont];
    CGFloat fontSize = [SNUtility getNewsTitleFontSize];
    self.newsTitle.font = titleFont;
    self.newsTitle.height = fontSize+1;
    self.videoIcon.centerY = self.newsTitle.centerY;
    self.adIcon.centerY = self.newsTitle.centerY;

    int curPage = [[SNRollingNewsPublicManager sharedInstance] getFocusImageIndexWithChannelId:self.item.news.channelId];
    
    self.rollingPageArray = [NSMutableArray arrayWithArray:self.item.news.newsFocusArray];
    int pageCount = self.item.news.newsFocusArray.count;
    if (!self.pageImageViews) {
        self.pageImageViews = [NSMutableArray arrayWithCapacity:pageCount];
    }
    [self.pageImageViews removeAllObjects];
    [_scrollView removeAllSubviews];

    if (pageCount == 1) {
        SNCellImageView *focusImage = [[SNCellImageView alloc]initWithFrame:CGRectMake(0, 0, kCellWidth, kFocusImageHeight)];
        SNRollingNews *newsItem = [self.item.news.newsFocusArray objectAtIndex:0];
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newsItem.picUrl];
        UIImage *defaultImage = nil;
        if (cacheImage) {
            defaultImage = cacheImage;
        } else {
            defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
        }
        [focusImage updateImageWithUrl:newsItem.picUrl defaultImage:defaultImage showVideo:NO];
        [_scrollView addSubview:focusImage];
        [self.pageImageViews addObject:focusImage];
        
        self.newsTitle.text = [NSString stringWithFormat:@"%@", newsItem.title];
        CGRect frame = self.newsTitle.frame;
        frame.size.width = kAppScreenWidth - 2*CONTENT_LEFT;
        frame.origin.x = CONTENT_LEFT;
        self.newsTitle.frame = frame;
        self.pageControl.numberOfPages = 1;
        self.adIcon.hidden = YES;
        self.scrollView.contentSize = CGSizeMake(kCellWidth, kFocusImageHeight);
        return;
    }
    
    SNRollingNews *newsItem = [self.item.news.newsFocusArray objectAtIndex:(pageCount - 1)];
    if (newsItem) {
        [self.rollingPageArray insertObject:newsItem atIndex:0];
    }
    
    if ([self.item.news.newsFocusArray count] > 0) {
        newsItem = [self.item.news.newsFocusArray objectAtIndex:0];
        [self.rollingPageArray addObject:newsItem];
    }
   
    pageCount = self.rollingPageArray.count;
    _scrollView.contentSize = CGSizeMake(kCellWidth * pageCount, kFocusImageHeight);

    for (int i = 0; i < pageCount; i++) {
        SNCellImageView *focusImage = [[SNCellImageView alloc]initWithFrame:CGRectMake(i*kCellWidth, 0, kCellWidth, kFocusImageHeight)];
        SNRollingNews *newsItem = [self.rollingPageArray objectAtIndex:i];
        
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newsItem.picUrl];
        UIImage *defaultImage = nil;
        if (cacheImage) {
            defaultImage = cacheImage;
        } else {
            defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
        }
        
        [focusImage updateImageWithUrl:newsItem.picUrl defaultImage:defaultImage showVideo:NO];
        
        [_scrollView addSubview:focusImage];
        [self.pageImageViews addObject:focusImage];
    }
    if (curPage != 0) {
        [_scrollView setContentOffset:CGPointMake(kCellWidth * curPage, 0)];
    } else {
        [_scrollView setContentOffset:CGPointMake(kCellWidth, 0)];
    }

    self.pageControl.numberOfPages = pageCount - 2;
    CGRect frame = self.pageControl.frame;
    int pageWidth = pageCount * 7;
    frame.size.width = pageWidth + 3;
    frame.origin.x = kAppScreenWidth - pageWidth - CONTENT_LEFT;
    self.pageControl.frame = frame;
    self.pageControl.currentPage = curPage == 0 ? curPage : (curPage - 1);
    
    int newsIndex= curPage == 0 ? curPage + 1 : curPage;
    if (newsIndex >= self.rollingPageArray.count) {
        newsIndex = self.rollingPageArray.count - 1;
    }
    SNRollingNews *curNewsItem = nil;
    if ([self.rollingPageArray count] > 0) {
       curNewsItem = [self.rollingPageArray objectAtIndex:newsIndex];
    }
    self.videoIcon.hidden = ![self hasVideo:curNewsItem.hasVideo];
    CGFloat offsetValue = [self hasVideo:curNewsItem.hasVideo] ? VIDEO_ICON_WIDTH + 7 : 0;
    if ([curNewsItem.newsType isEqualToString:kNewsTypeAd]) {
        if (curNewsItem.iconText && curNewsItem.iconText.length > 0) {
            self.adIcon.hidden = NO;
            self.adTitle.text = curNewsItem.iconText;
            CGSize titleSize = [self.adTitle.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
            self.adIcon.width = titleSize.width + 6;
            self.adTitle.width = titleSize.width + 6;
            
            offsetValue = 5 + self.adIcon.width;
        }
    } else {
        self.adIcon.hidden = YES;
    }
    
    frame = self.newsTitle.frame;
    frame.size.width = kAppScreenWidth - 3 * CONTENT_LEFT - pageWidth - offsetValue;
    frame.origin.x = CONTENT_LEFT + offsetValue;
    self.newsTitle.frame = frame;

    self.newsTitle.text = [NSString stringWithFormat:@"%@", curNewsItem.title];
    
    [self removeTimer];
    [self addTimer];
}

- (void)openNews {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSpreadAnimationStartKey]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setDouble:100.0 forKey:kRememberCellOriginYInScreen];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNUtility shouldUseSpreadAnimation:YES];
    int pageCount = self.rollingPageArray.count;
    int newsIndex = _currentImageIndex;
    if (newsIndex == pageCount) {
        newsIndex = 0;
    }
    //防止数组越界 by cuiliangliang
    if (pageCount == 0) {
        return;
    }
    if (newsIndex > pageCount) {
        newsIndex = pageCount - 1;
    }

    if (newsIndex < 0) {
        newsIndex = pageCount - 1;
    }
    
    SNRollingNews *newsItem = [self.rollingPageArray objectAtIndex:newsIndex];
    //订阅流广告点击统计
    if (self.item.subscribeAdObject && [newsItem.newsType isEqualToString:kNewsTypeAd]) {
        [self reportPopularizeClick];
    }
    
    // 广告点击曝光
    if ([newsItem.newsType isEqualToString:kNewsTypeAd]) {
        [newsItem.newsAd reportAdClick:newsItem];
    } else {
        //焦点图PV埋点
        [self reportADotGif:newsItem];
    }
    
    [item.controller cacheCellIndexPath:self];
    if(newsItem.newsType!=nil && [SNCommonNewsController supportContinuation:newsItem.newsType]) {
        NSMutableDictionary *dic = nil;
        if (item.dataSource) {
            dic = [item.dataSource getContentDictionary:newsItem];
        }
        [dic setObject:kChannelEditionNews forKey:kNewsFrom];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    } else if(newsItem.link.length > 0) {
        if ([newsItem.link startWith:kProtocolVideo]) {//二代协议视频: video://
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            //判断此视频是否已离线，已离线则把视频对象进行离线播放
            SNVideoData *offlinePlayVideo = [self getDownloadVideoIfNeededWithLink2:newsItem.link];
            if (!!offlinePlayVideo) {
                query[kDataKey_TimelineVideo] = offlinePlayVideo;
            }
            query[kRollingNewsVideoPosition] = @(SNRollingNewsVideoPosition_NormalVideoLink2);
            [SNUtility openProtocolUrl:newsItem.link context:query];
        } else if ([newsItem.newsType isEqualToString:kNewsTypeAd]) {
            NSString *link = newsItem.link;
            //if(1){
            if (newsItem.newsAd.predownload && item.news.newsAd.predownload.length > 0) {
                link = [link stringByAppendingString:[NSString stringWithFormat:@"predownload:%@", newsItem.newsAd.predownload]];
                [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:FullScreenADWebViewType], kUniversalWebViewType, nil]];
            } else {
                //link = @"sohunews://pr/http://kfc.normcore.com/talk/index.html?v=8"; //测试changeSohuLinkToProtocol用的 可能出现的效果是广告唰一下又pop了 然后进一个正文页
                //link = @"http://h5.goufangdaxue.com/dasoujia/fangy/dysy.jsp";//测试网页能不能打电话用的
                //link = @"landscape://url=https://jinshuju.net/f/LTEXwQ"; //测试广告横屏的
                //link = @"http://svn.go.sohu.com/pmis/factory/sandbox/2017/yilingrun/index.html";
                [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
            }
        } else {
            //要闻-轮播图的广告可能走这里
            [SNUtility openProtocolUrl:newsItem.link];
        }
    }
    
    //设置数据库已读
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if (channel != nil && newsId != nil)
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
    //内存已读
    self.item.news.isRead = YES;
}

- (void)reportPopularizeClick {
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info {
    if (self.item.subscribeAdObject.adId.length > 0) {
        info.adIDArray = @[self.item.subscribeAdObject.adId];
    }
    info.objLabel = SNStatInfoUseTypeOutTimelinePopularize;
    info.objType = kObjTypeOfRecommendPosionInMySubBanner;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
}

- (SNVideoData *)getDownloadVideoIfNeededWithLink2:(NSString *)link2 {
    NSString *vid = [[SNUtility parseLinkParams:link2] stringValueForKey:@"vid" defaultValue:nil];
    SNVideoDataDownload *downloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:vid];
    SNVideoData *offlinePlayVideo = [[SNDBManager currentDataBase] getOfflinePlayVideoByVid:vid];
    NSString *localVideoRelativePath = downloadVideo.localRelativePath;
    if (localVideoRelativePath.length > 0) {
        NSString *localVideoAbsolutePath = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:localVideoRelativePath];
        offlinePlayVideo.sources = [NSMutableArray arrayWithObject:localVideoAbsolutePath];
    }
    return offlinePlayVideo;
}

- (void)reportADotGif:(SNRollingNews *)newsItem {
    NSString *paramStr = [NSString stringWithFormat:@"_act=focus&_tp=pv&channelid=%@&newsid=%@&position=%@",newsItem.channelId, newsItem.newsId,newsItem.position];
    [SNNewsReport reportADotGif:paramStr];
}

- (BOOL)hasVideo:(NSString *)video {
    return [video isEqualToString:@"1"];
}

- (void)showNexPageNews {
    if ([SNRollingNewsPublicManager sharedInstance].pageViewTimer == NO) {
        return;
    }

    _currentImageIndex = [[SNRollingNewsPublicManager sharedInstance] getFocusImageIndexWithChannelId:self.item.news.channelId];
    int pageCount = self.rollingPageArray.count;
    if (pageCount == 1 || pageCount == 0) {
        [self removeTimer];
        return;
    }
    
    
    if (_currentImageIndex == 0) {
        _currentImageIndex += 1;
    }
    BOOL animated = _currentImageIndex == (pageCount -2) ? NO : YES;
    _currentImageIndex = _currentImageIndex == (pageCount-2) ? 0 : _currentImageIndex;

    _currentImageIndex += 1;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:CGPointMake(_currentImageIndex*kCellWidth, 0) animated:animated];
    });
    
    //数组越界保护 by cuiliangliang
    if (self.item.news.newsFocusArray.count <= (_currentImageIndex - 1)) {
        return;
    }
    
    SNRollingNews *newsItem = [self.item.news.newsFocusArray objectAtIndex:_currentImageIndex - 1];
    
    self.videoIcon.hidden = ![self hasVideo:newsItem.hasVideo];
    CGFloat offsetValue = [self hasVideo:newsItem.hasVideo] ? VIDEO_ICON_WIDTH + 7 : 0;
    if ([newsItem.newsType isEqualToString:kNewsTypeAd]) {
        [newsItem.newsAd reportAdOneDisplay:newsItem];
        if (newsItem.iconText && newsItem.iconText.length > 0) {
            self.adIcon.hidden = NO;
            self.adTitle.text = newsItem.iconText;
            CGSize titleSize = [self.adTitle.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
            self.adIcon.width = titleSize.width + 6;
            self.adTitle.width = titleSize.width + 6;
            
            offsetValue = 5 + self.adIcon.width;
        }
    } else {
        self.adIcon.hidden = YES;
        [SNStatisticsInfoAdaptor cacheTimelineNewsShowBusinessStatisticsInfo:newsItem];
    }
    
    CGRect frame = self.newsTitle.frame;
    frame.size.width = kAppScreenWidth - 3*CONTENT_LEFT - (self.pageControl.frame.size.width - 3) - offsetValue;
    frame.origin.x = CONTENT_LEFT + offsetValue;
    self.newsTitle.frame = frame;
    self.newsTitle.text = [NSString stringWithFormat:@"%@", newsItem.title];
    
    [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:_currentImageIndex channelId:self.item.news.channelId];
}

- (void)showFirstPageNewItem {
    if (self.rollingPageArray.count <= 1) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:CGPointMake(kCellWidth, 0) animated:NO];
    });
    
    SNRollingNews *curNewsItem = nil;
    if ([self.rollingPageArray count] > 0) {
        curNewsItem =  [self.rollingPageArray objectAtIndex:1];
    }
    self.videoIcon.hidden = ![self hasVideo:curNewsItem.hasVideo];
    CGFloat offsetValue = [self hasVideo:curNewsItem.hasVideo] ? VIDEO_ICON_WIDTH + 7 : 0;
    if ([curNewsItem.newsType isEqualToString:kNewsTypeAd]) {
        if (curNewsItem.iconText && curNewsItem.iconText.length > 0) {
            self.adIcon.hidden = NO;
            self.adTitle.text = curNewsItem.iconText;
            CGSize titleSize = [self.adTitle.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
            self.adIcon.width = titleSize.width + 6;
            self.adTitle.width = titleSize.width + 6;
            
            offsetValue = 5 + self.adIcon.width;
        }
    } else {
        self.adIcon.hidden = YES;
    }
    
    CGRect frame = self.newsTitle.frame;
    frame.size.width = kAppScreenWidth - 3 * CONTENT_LEFT - (self.pageControl.frame.size.width - 3) - offsetValue;
    frame.origin.x = CONTENT_LEFT + offsetValue;
    self.newsTitle.frame = frame;

    self.newsTitle.text = [NSString stringWithFormat:@"%@", curNewsItem.title];
    
    self.pageControl.currentPage = 0;
    
    [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:0 channelId:curNewsItem.channelId];
}

@end
