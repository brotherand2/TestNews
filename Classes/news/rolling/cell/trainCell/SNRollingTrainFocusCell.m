//
//  SNRollingTrainFocusCell.m
//  sohunews
//
//  Created by HuangZhen on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainFocusCell.h"
#import "SNRollingTrainCollectionView.h"
#import "SMPageControl.h"
#import "NSTimer+SNBlocksSupport.h"
#import "SNNewsAd+analytics.h"
#import "SNCommonNewsDatasource.h"
#import "SNCommonNewsController.h"
#import "SNRollingNewsConst.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNRollingTrainCellConst.h"
#import "SNTrainClickLabel.h"
#import "SNSubRollingNewsModel.h"
#import "SNNewsFullscreenManager.h"

@interface SNRollingTrainFocusCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIImageView * twoNewsBackground;
@property (nonatomic, strong) UIView * segmentLine;
@property (nonatomic, strong) UIView * bottomLine;

@property (nonatomic, strong) SMPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) SNRollingTrainCollectionView * focusCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * focusCollectionViewLayout;
@property (nonatomic, strong) NSMutableArray * focusCollectionData;

@property (nonatomic, strong) NSArray * twoNewsArray;

@property (nonatomic, strong) SNRollingTrainImageTextCell * tempCell;
@property (nonatomic, strong) SNRollingTrainImageTextCell * rightTempCell;
@property (nonatomic, strong) SNRollingTrainImageTextCell * leftTempCell;

@property (nonatomic, assign) BOOL isDraggingTableView;

@end

@implementation SNRollingTrainFocusCell

static CGFloat rowCellHeight = 0.0;
static CGFloat rowCellOffsetHeight = 0.0;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if ([object isKindOfClass:[SNRollingNewsTableItem class]]) {
        SNRollingNewsTableItem * item = (SNRollingNewsTableItem *)object;
        [self calculateCellHeight:item];
    }
    return rowCellHeight;
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    NSArray * titleArray =  [[self class] getTowTopNews:item.news.newsItemArray];
    CGFloat space = kTwoEditNewsSpaceHeight;
    CGFloat topSpace = kTwoEditNewsSpaceTop;
    CGFloat btnWidth = kTwoEditNewsWidth;
    CGFloat offset = topSpace;
    UIFont * textFont = [SNTrainCellHelper fullscreenEditNewsTitleFont];
    for (SNRollingNews * itemNews in titleArray) {
        if ([itemNews isKindOfClass:[SNRollingNews class]]) {
            NSString * btnTitle = itemNews.title;
            if (btnTitle.length > 0) {
                CGFloat buttonHeight = [SNTrainCellHelper getLabelHeightWithText:btnTitle width:btnWidth font:textFont];
                if (buttonHeight > textFont.lineHeight * 2) {
                    buttonHeight = textFont.lineHeight * 2;
                }
                offset += buttonHeight;
            }
        }
    }
    if (titleArray.count > 0) {
        offset += (titleArray.count - 1)*space;
        offset += topSpace;
        rowCellOffsetHeight = offset;
    }else{
        rowCellOffsetHeight = 0;
    }
    if (item.news.newsFocusArray.count > 0) {
        rowCellHeight = kTrainCellImageHeight + rowCellOffsetHeight;
    }else{
        rowCellHeight = rowCellOffsetHeight;
    }
    if (rowCellHeight > 0) {
        item.cellHeight = rowCellHeight;
        CGFloat far = rowCellHeight - 2*kLeftSpace - kSmallTrainCellHeight;
        CGFloat distance = far - kDefaultNavBarHeight + 14;//14是火车卡片上边距
        if (distance > 0) {
            [SNNewsFullscreenManager manager].trainAnimationDistance = distance;
        }
    }
}

- (void)dealloc {
    [self stopTimer];
    [SNNotificationManager removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self buildCollectionView];
        [SNNotificationManager addObserver:self selector:@selector(stopTimer) name:UIApplicationWillResignActiveNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(startTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
        //启动页结束后，开启timer
        [SNNotificationManager addObserver:self selector:@selector(startTimer) name:kIs3DTouchShowKeyboard object:nil];
        //切换频道或进入正文，启停定时器
        [SNNotificationManager addObserver:self selector:@selector(dealTimer:) name:kStopPageTimerNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(showFirstPageNewItem) name:kShowFirstPageNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(fullscreenThemeDidFetched) name:kFullscreenThemeDidFetchedkNotification object:nil];

        self.currentIndex = 1;
    }
    return self;
}

- (void)fullscreenThemeDidFetched {
    [self updateContentView];
}

- (void)dealTimer:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *channelId = [userInfo objectForKey:@"stopChannelId"];
    if ([channelId isEqualToString:self.item.news.channelId]) {
        BOOL stopflag = [[userInfo objectForKey:@"stopFlag"] boolValue];
        if (stopflag) {
            [self stopTimer];
        } else {
            [self startTimer];
        }
    }
}

- (void)showFirstPageNewItem {
    if (!self.focusCollectionView.hidden && self.focusCollectionData.count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        if (indexPath.row < self.focusCollectionData.count) {
            [self.focusCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            SNRollingNews * news = self.focusCollectionData[indexPath.row];
            [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:0 channelId:news.channelId];
        }
    }
}

#pragma mark --
#pragma mark - buildUI
- (void)buildTwoNewsView {
    [self.twoNewsBackground removeFromSuperview];
    self.twoNewsBackground = nil;
    if (!self.twoNewsBackground) {
        self.twoNewsBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 80)];
        self.twoNewsBackground.userInteractionEnabled = YES;
//        [self insertSubview:self.twoNewsBackground belowSubview:self.focusCollectionView];
        [self insertSubview:self.twoNewsBackground atIndex:1];//ios7 insert不管用？先用这个方法吧
    }
    if (!self.segmentLine) {
        self.segmentLine = [[UIView alloc] initWithFrame:CGRectMake(kLeftSpace, kTrainCellImageHeight, kAppScreenWidth-2*kLeftSpace, 0.5)];
        [self addSubview:self.segmentLine];
    }
    if (!self.bottomLine) {
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 4)];
        [self addBottomLineMask];
        self.bottomLine.hidden = YES;
        [self addSubview:self.bottomLine];
    }
    
    self.twoNewsBackground.backgroundColor = [SNTrainCellHelper focusBackgroundColor];
    self.segmentLine.backgroundColor = [SNTrainCellHelper segmentLineColor];
    self.segmentLine.alpha = [SNTrainCellHelper segmentLineAlpha];

    CGFloat leftSpace = kLeftSpace * 2;
    CGFloat topSpace = kTwoEditNewsSpaceTop;
    CGFloat space = kTwoEditNewsSpaceHeight;
    CGFloat btnWidth = kTwoEditNewsWidth;
    NSArray * titleArray = self.twoNewsArray;
    CGFloat focusHeight = 0;
    CGFloat cellOffsetHeight = 0;
    if (item.news.newsFocusArray.count > 0) {
        focusHeight = kTrainCellImageHeight;
        cellOffsetHeight = self.item.cellHeight - kTrainCellImageHeight;
    }else{
        cellOffsetHeight = self.item.cellHeight;
        focusHeight = 0;
    }
    CGFloat offset = topSpace + focusHeight;
    
    for (SNRollingNews * itemNews in titleArray) {
        if ([itemNews isKindOfClass:[SNRollingNews class]]) {
            [self reportTwoNewsShow:itemNews];
            NSString *btnTitle = itemNews.title;
            if (btnTitle.length > 0) {
                UIFont * textFont = [SNTrainCellHelper fullscreenEditNewsTitleFont];
                CGRect frame = CGRectMake(leftSpace, offset, btnWidth, 1);
                SNTrainClickLabel * newsButton = [[SNTrainClickLabel alloc] initWithFrame:frame];
                newsButton.font = textFont;
                newsButton.lineBreakMode = NSLineBreakByTruncatingTail;
                newsButton.numberOfLines = 2;
                if (itemNews.isRead) {
                    newsButton.textColor = [SNTrainCellHelper newsWordClickedColour];
                }else{
                    newsButton.textColor = [SNTrainCellHelper editNewsTitleColor];
                }
                NSMutableAttributedString * newsTitle = [[NSMutableAttributedString alloc] initWithString:btnTitle];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                [paragraphStyle setLineSpacing:2.5f];
                [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
                [newsTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [newsTitle length])];
                newsButton.attributedText = newsTitle;
                CGSize titleSize = [newsButton sizeThatFits:CGSizeMake(btnWidth, MAXFLOAT)];
                newsButton.height = titleSize.height;
                
                __weak SNRollingTrainFocusCell *weakSelf = self;
                newsButton.clickBlock = ^{
                    SNRollingTrainFocusCell *strongSelf = weakSelf;
                    itemNews.isRead = YES;
                    [strongSelf reportTwoNewsClk:itemNews];
                    [strongSelf openNews:itemNews isFocus:NO];
                };
                [self.twoNewsBackground addSubview:newsButton];
                offset = newsButton.bottom + space;
                
                UIView * bullets = [[UIView alloc] initWithFrame:CGRectMake(kLeftSpace, 0, 5, 5)];
                bullets.backgroundColor = [SNTrainCellHelper bulletsColor];
                bullets.alpha = [SNTrainCellHelper bulletsAlpha];
                bullets.layer.cornerRadius = bullets.width/2.f;
                NSInteger lineNum = newsButton.height/newsButton.font.ttLineHeight;
                if (lineNum > 1) {
                    bullets.centerY = newsButton.top + newsButton.height/4.f;
                }else{
                    bullets.centerY = newsButton.centerY;
                }
                [self.twoNewsBackground addSubview:bullets];
            }
        }
    }
    
    self.twoNewsBackground.height = focusHeight + cellOffsetHeight;
    if (rowCellHeight > 0) {
        self.bottomLine.alpha = [SNTrainCellHelper whiteThemeBottomLineAlpha];
        self.bottomLine.top = self.twoNewsBackground.height;
        self.bottomLine.hidden = [[SNThemeManager sharedThemeManager] isNightTheme];
    }
}

- (void)addBottomLineMask {
    UIColor * color = [UIColor blackColor];
    self.bottomLine.backgroundColor = color;
    UIColor *color1 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.05];
    UIColor *color2 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.0];
    NSArray *colors = [NSArray arrayWithObjects:(id)color1.CGColor, color2.CGColor, nil];
    NSArray *locations = [NSArray arrayWithObjects:@(0.0),@(1.0), nil];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    gradientLayer.frame = self.bottomLine.bounds;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint   = CGPointMake(0, 1);
    self.bottomLine.layer.mask = gradientLayer;
}

- (void)buildCollectionView {
    [self setupCollectionViewLayout];
    if (!_focusCollectionView) {
        CGRect frame = CGRectMake(0, 0, kCellWidth, kTrainCellImageHeight);
        self.focusCollectionView = [[SNRollingTrainCollectionView alloc] initWithFrame:frame collectionViewLayout:self.focusCollectionViewLayout];
        self.focusCollectionView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        self.focusCollectionView.delegate = self;
        self.focusCollectionView.dataSource = self;
        self.focusCollectionView.pagingEnabled = YES;
        self.focusCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.focusCollectionView];
    }
}

- (void)addPageControl {
    if (!_pageControl) {
        CGRect rect = CGRectMake(kAppScreenWidth - 42, kTrainCellImageHeight - 23, 28, 15);
        self.pageControl = [[SMPageControl alloc] initWithFrame:rect];
        self.pageControl.indicatorMargin = 3.0f;
        self.pageControl.indicatorDiameter = 3.0f;
        self.pageControl.hidesForSinglePage = YES;
        [self addSubview:self.pageControl];
        self.pageControl.backgroundColor = [UIColor clearColor];
        [self.pageControl setPageIndicatorImage:[UIImage imageNamed:@"icohome_carousel_v5.png"]];
        [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"icohome_carouselpress_v5.png"]];
        self.pageControl.currentPage = 0;
    }
}

- (void)startTimer {
    if (!self.timer
        && self.item.news.newsFocusArray.count > 1
        && self.item.cellType == SNRollingNewsCellTypeFullScreenFocus
        && self.focusCollectionView.hidden == NO) {
        
        __weak SNRollingTrainFocusCell * weakSelf = self;
        self.timer = [NSTimer sn_timerWithTimeInterval:4 repeats:YES block:^() {
            SNRollingTrainFocusCell * strongSelf = weakSelf;
            [strongSelf showNextImage];
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)showNextImage {
    NSInteger currentIndex = self.currentIndex + 1;
    currentIndex = (currentIndex == self.focusCollectionData.count) ? 1 : currentIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    [self scrollToIndexPath:indexPath animated:YES];
//    SNDebugLog(@"SNRollingTrainCell FocusTimer Runing! %d",currentIndex);
    NSInteger index = self.currentIndex;
    if (index < self.item.news.newsFocusArray.count) {
        SNRollingNews * news = [self.item.news.newsFocusArray objectAtIndex:index];
        [self reportNewsDidShow:news];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex == _currentIndex) {
        return;
    }
    _currentIndex = currentIndex;
    
    if (_currentIndex < self.item.news.newsFocusArray.count + 1)
    {
        NSInteger index = _currentIndex > 0 ? _currentIndex - 1 : 0;
        self.pageControl.currentPage = index;
    }
    
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if (self.focusCollectionData.count > indexPath.row)
    {
        [self.focusCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    }
}

- (void)setupCollectionViewLayout {
    if (!self.focusCollectionViewLayout) {
        self.focusCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        self.focusCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.focusCollectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.focusCollectionViewLayout.minimumLineSpacing = 0;
        self.focusCollectionViewLayout.minimumInteritemSpacing = 0;
    }
}

- (void)openNews:(SNRollingNews *)news isFocus:(BOOL)isFocus{
    if (isFocus) {
        [SNUserDefaults setDouble:100.0 forKey:kRememberCellOriginYInScreen];
    }
    else {
        [SNUserDefaults setDouble:180.0 forKey:kRememberCellOriginYInScreen];
    }
    [SNUtility shouldUseSpreadAnimation:YES];
    
    if (isFocus) {
        //订阅流广告点击统计
        if (self.item.subscribeAdObject && [news.newsType isEqualToString:kNewsTypeAd]) {
            [self reportPopularizeClick];
        }
        
        // 广告点击曝光
        if ([news.newsType isEqualToString:kNewsTypeAd]) {
            [news.newsAd reportAdClick:news];
        } else {
            //焦点图PV埋点
            [self reportADotGif:news];
        }
    }
    
    [item.controller cacheCellIndexPath:self];
    if(news.newsType!=nil && [SNCommonNewsController supportContinuation:news.newsType]) {
        NSMutableDictionary *dic = nil;
        if (item.dataSource) {
            dic = [item.dataSource getContentDictionary:news];
        }
        //newsfrom=5/6由recomInfo确定，isRecom后期会作废
        [dic setObject:kChannelEditionNews forKey:kNewsFrom];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    } else if(news.link.length > 0) {
        if ([news.link startWith:kProtocolVideo]) {//二代协议视频: video://
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            //判断此视频是否已离线，已离线则把视频对象进行离线播放
            SNVideoData *offlinePlayVideo = [self getDownloadVideoIfNeededWithLink2:news.link];
            if (!!offlinePlayVideo) {
                query[kDataKey_TimelineVideo] = offlinePlayVideo;
            }
            query[kRollingNewsVideoPosition] = @(SNRollingNewsVideoPosition_NormalVideoLink2);
            [SNUtility openProtocolUrl:news.link context:query];
        } else if ([news.newsType isEqualToString:kNewsTypeAd]) {
            NSString *link = news.link;
            if (news.newsAd.predownload && item.news.newsAd.predownload.length > 0) {
                link = [link stringByAppendingString:[NSString stringWithFormat:@"predownload:%@", news.newsAd.predownload]];
                [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:FullScreenADWebViewType], kUniversalWebViewType, nil]];
            } else {
                //link = @"sohunews://pr/http://kfc.normcore.com/talk/index.html?v=8"; //测试changeSohuLinkToProtocol用的 可能出现的效果是广告唰一下又pop了 然后进一个正文页
                //link = @"http://h5.goufangdaxue.com/dasoujia/fangy/dysy.jsp";//测试网页能不能打电话用的
                //link = @"landscape://url=https://jinshuju.net/f/LTEXwQ"; //测试广告横屏的
                [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
            }
        } else {
            //要闻-轮播图的广告可能走这里
            [SNUtility openProtocolUrl:news.link];
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

#pragma mark --
#pragma mark - 统计
- (void)reportNewsDidShow:(SNRollingNews *)news {
    if ([news.newsType isEqualToString:kNewsTypeAd]) {
        [news.newsAd reportAdOneDisplay:news];
    } else {
        [self reportADotGif:news];
        [SNStatisticsInfoAdaptor cacheTimelineNewsShowBusinessStatisticsInfo:news];
    }
    [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:self.currentIndex channelId:self.item.news.channelId];
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
    if (newsItem.reportState == AdReportStateNo) {
        NSString *paramStr = [NSString stringWithFormat:@"_act=focus&_tp=pv&channelid=%@&newsid=%@&position=%@",newsItem.channelId, newsItem.newsId,newsItem.position];
        [SNNewsReport reportADotGif:paramStr];
        newsItem.reportState = AdReportStateLoad;
    }
}

- (void)reportTwoNewsShow:(SNRollingNews *)news {
    if (news.reportState == AdReportStateNo) {
        NSString *paramStr = [NSString stringWithFormat:@"_act=edit_office&_tp=pv&channelid=%@&newsid=%@",news.channelId, news.newsId];
        [SNNewsReport reportADotGif:paramStr];
        news.reportState = AdReportStateLoad;
    }
}

- (void)reportTwoNewsClk:(SNRollingNews *)news {
    NSString *paramStr = [NSString stringWithFormat:@"_act=edit_office&_tp=clk&channelid=%@&newsid=%@",news.channelId, news.newsId];
    [SNNewsReport reportADotGif:paramStr];
}

#pragma mark --
#pragma mark - 数据/UI
- (void)updateFullscreenFocusTheme {
    [self removeTempCells];
    self.focusCollectionView.hidden = NO;
    self.focusCollectionView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    moreButton.hidden = YES;
    self.twoNewsArray = [[self class] getTowTopNews:self.item.news.newsItemArray];
    NSArray *topTopNews = self.twoNewsArray;
    if (topTopNews.count > 0) {
        [self buildTwoNewsView];
        self.twoNewsBackground.hidden = NO;
        self.segmentLine.hidden = NO;

    }else{
        self.twoNewsBackground.hidden = YES;
        self.segmentLine.hidden = YES;
    }
    
    NSInteger focusCount = self.item.news.newsFocusArray.count;
    if (focusCount > 1) {
        [self addPageControl];
        self.pageControl.hidden = NO;
        self.pageControl.alpha = themeImageAlphaValue();
        self.pageControl.width = focusCount * 8;
        self.pageControl.numberOfPages = focusCount;
        self.pageControl.right = kCellWidth - 10;
        [self startTimer];
    }else{
        self.pageControl.hidden = YES;
        [self stopTimer];
    }
}

- (void)updateFullscreenFocusData {
    if (self.item.news.newsFocusArray.count <= 0) {
        return;
    }
    if (!self.focusCollectionData) {
        self.focusCollectionData = [NSMutableArray array];
    }
    [self.focusCollectionData removeAllObjects];
    if (self.item.news.newsFocusArray.count == 1) {
        [self.focusCollectionData addObjectsFromArray:self.item.news.newsFocusArray];
        self.pageControl.hidden = YES;
    }else{
        if (self.item.news.newsFocusArray.count <= 0) {
            self.focusCollectionView.hidden = YES;
            return;
        }
        //为了无限轮播效果，先制造假数据
        [self.focusCollectionData addObjectsFromArray:self.item.news.newsFocusArray];
        SNRollingNews * firstNews = [self.item.news.newsFocusArray firstObject];
        SNRollingNews * lastNews = [self.item.news.newsFocusArray lastObject];
        [self.focusCollectionData insertObject:lastNews atIndex:0];
        [self.focusCollectionData addObject:firstNews];
        self.pageControl.hidden = NO;
    }
}

- (void)updateData {
    SNRollingNewsCellType cellType = self.item.cellType;
    switch (cellType) {
        case SNRollingNewsCellTypeFullScreenFocus:
        {
            [self updateFullscreenFocusData];
            [self.focusCollectionView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            if (indexPath.row < self.focusCollectionData.count && indexPath.row >= 0) {
                [self.focusCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                self.currentIndex = 1;
                if (self.item.news.newsFocusArray.count > 0) {
                    SNRollingNews * news = [self.item.news.newsFocusArray objectAtIndex:0];
                    [self reportNewsDidShow:news];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)updateContentView {
    self.clipsToBounds = NO;
    [super updateContentView];
    [self updateTheme];
    [self updateData];
}

- (void)updateTheme {
    [super updateTheme];
    //根据cell类型 展现全屏焦点图或者火车卡片UI
    SNRollingNewsCellType cellType = self.item.cellType;
    switch (cellType) {
        case SNRollingNewsCellTypeFullScreenFocus:
        {
            [self updateFullscreenFocusTheme];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark --
#pragma mark - tableview 滚动
- (void)tableViewWillBeginDragging:(UITableView *)tableView {
    [self stopTimer];
    _isDraggingTableView = YES;
}

- (void)tableViewDidEndDraging:(UITableView *)tableView {
    _isDraggingTableView = NO;
    if (![SNNewsFullscreenManager needTrainAnimation]) {
        return;
    }
    CGFloat offsetY = tableView.contentOffset.y;
    CGFloat far = [SNNewsFullscreenManager manager].trainAnimationDistance;
    CGFloat ratio = MAX(0, offsetY/far);
    ratio = MIN(1, ratio);
    if (ratio > 0 && ratio < 1) {
        [tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)tableViewDidEndScroll:(UITableView *)tableView {
//    CGFloat offsetY = tableView.contentOffset.y;
//    if (offsetY <= kTrainCellImageHeight && self.item.cellType == SNRollingNewsCellTypeFullScreenFocus) {
//        [self startTimer];
//    }
}

- (void)tableViewDidScroll:(UITableView *)tableView {
    if (![SNNewsFullscreenManager needTrainAnimation] || ![SNNewsFullscreenManager manager].isFullscreenMode) {
        return;
    }
    CGFloat far = [SNNewsFullscreenManager manager].trainAnimationDistance;
    CGFloat offsetY = tableView.contentOffset.y;
    CGFloat ratio = MAX(0, offsetY/far);
    ratio = MIN(1, ratio);
    
    //动画开始变换
    if (!self.tempCell) {
        self.clipsToBounds = YES;
        SNRollingNews * tempNews = [self tempNewsWithIndex:self.currentIndex];
        SNRollingNews * rightTempNews = [self tempNewsWithIndex:self.currentIndex + 1];
        SNRollingNews * leftTempNews = [self tempNewsWithIndex:self.currentIndex - 1];
        self.focusCollectionView.hidden = YES;
        [self addTempCell];
        [self.tempCell setItem:tempNews];

        if (leftTempNews) {
            [self addLeftTempCell];
            [self.leftTempCell setItem:leftTempNews];
        }
        if (rightTempNews) {
            [self addRightTempCell];
            [self.rightTempCell setItem:rightTempNews];
        }
        self.pageControl.hidden = YES;
    }
    //动态改变cell高度方案
    //    [tableView beginUpdates];
    //    focusCellHeight = kTrainCellImageHeight + 80 * (1-ratio);
    //    rowCellHeight = kCellHeight + 80 * (1-ratio);
    //    [tableView endUpdates];
    //渐变透明消失
    CGFloat alpha = 1 - (1 * ratio);
    UIColor * twoNewsBackgroundColor = [SNTrainCellHelper focusBackgroundColor];
    self.twoNewsBackground.backgroundColor = [UIColor colorWithRed:twoNewsBackgroundColor.red
                                                             green:twoNewsBackgroundColor.green
                                                              blue:twoNewsBackgroundColor.blue
                                                             alpha:alpha];
//    self.twoNewsBackground.alpha = alpha;
    self.twoNewsBackground.top = MAX(0, offsetY*0.7);
    for (UIView * subview in self.twoNewsBackground.subviews) {
        subview.alpha = alpha;
    }
    CGFloat fastAlpha = 1 - (4 * ratio);
    fastAlpha = MAX(0, fastAlpha);
    self.bottomLine.alpha = fastAlpha*[SNTrainCellHelper whiteThemeBottomLineAlpha];
    self.segmentLine.alpha = fastAlpha*[SNTrainCellHelper segmentLineAlpha];
    
    //图片frame
    CGFloat t_width = kSmallTrainCellWidth;
    CGFloat t_height = kSmallTrainCellHeight;
    CGFloat t_top = rowCellHeight - t_height - kLeftSpace;
    CGFloat t_left = kLeftSpace;
    CGFloat top = (t_top - 0)*ratio;
    CGFloat left = (t_left - 0)*ratio;
    CGFloat width = kCellWidth - fabsf(t_width - kCellWidth)*ratio;
    CGFloat height = kTrainCellImageHeight - fabs(t_height - kTrainCellImageHeight)*ratio;
    
    
    self.tempCell.frame = CGRectMake(left, top, width, height);
//    CGFloat r_top = top + height/2.f - _rightTempCell.height/2.f + (50*(1-ratio));//50是为了给一个右侧和中间的cell的视觉差效果
    CGFloat r_space = kLeftSpace - (kLeftSpace - kCardLeftSpace/2.f)*ratio;
    self.rightTempCell.frame = CGRectMake(self.tempCell.right + r_space, top, width, height);
    self.leftTempCell.frame = CGRectMake(self.tempCell.left - r_space -_leftTempCell.width , top, width, height);
    
    [self.tempCell transitionWithRatio:ratio];
    [self.rightTempCell zoomWithRatio:ratio];
    [self.leftTempCell zoomWithRatio:ratio];
    
    if (ratio == 0) {
        //动画取消
        self.focusCollectionView.hidden = NO;
        self.segmentLine.alpha = [SNTrainCellHelper segmentLineAlpha];
        self.clipsToBounds = NO;
        if (self.focusCollectionData.count > 1) {
            self.pageControl.hidden = NO;
        }
        [self removeTempCells];
        if (!_isDraggingTableView) {
            [self startTimer];
        }
    }
    NSInteger index = self.currentIndex - 1;
    if (ratio == 1) {
        //动画变换完成
        if (self.item.cellType == SNRollingNewsCellTypeFullScreenFocus) {
//            [self removeTempCells];
//                CGFloat offsetX = index * kSmallTrainCellWidth + kCardLeftSpace/2.f*(index-1) + kLeftSpace;
            CGFloat offsetX = index * (kSmallTrainCellWidth+kCardLeftSpace/2.f);
            [SNNewsFullscreenManager manager].rollingFocusAnchor = offsetX;
            [SNNewsFullscreenManager setNeedTrainAnimation:NO];
            self.item.news.isCardsFromFocus = YES;
            
            [SNNotificationManager postNotificationName:kSNFullscreenModeFinishedNotification object:nil];
            SNRollingNewsModel * model = self.item.dataSource.newsModel;
            if ([model isKindOfClass:[SNSubRollingNewsModel class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(SNSubRollingNewsModel *)model updateFocusToTrainCard];
                });
            }
        }
    }
}

#pragma mark --
#pragma mark - Fullscreen Aniamtion
- (SNRollingNews *)tempNewsWithIndex:(NSInteger)index {
    if (index < self.focusCollectionData.count) {
        if (index == 0) {//第0个位置为最后一帧的占位。不应取出
            return nil;
        }
        if (index == self.focusCollectionData.count - 1) {
            return [self getMoreFirstNews];
        }
        return [self.focusCollectionData objectAtIndex:index];
    }else if (self.focusCollectionData.count == 1) {//只有一张焦点图的情况
        if (index == 1) {
            return self.focusCollectionData.firstObject;
        }else if (index == 2) {
            return  [self getMoreFirstNews];
        }
    }
    return nil;
}

- (SNRollingNews *)getMoreFirstNews {
    //最后一个位置为第一帧的占位，不应取出，应给出火车中首位置的news
    NSInteger count = self.twoNewsArray.count;
    if (count > 0) {
        return self.twoNewsArray.firstObject;
    }else if (count == 0) {
        return self.item.news.newsItemArray.firstObject;
    }
    return nil;
}

- (void)addTempCell {
    if (!_tempCell) {
        CGRect frame = CGRectMake(0, 0, kCellWidth, kTrainCellImageHeight);
        self.tempCell = [[SNRollingTrainImageTextCell alloc] initWithFrame:frame];
        self.tempCell.type = SNTrainCellTypeFocus;
        self.tempCell.layer.cornerRadius = kTrainCardCornerRadius;
        [self addSubview:_tempCell];
    }
}

- (void)addRightTempCell {
    if (!_rightTempCell) {
        CGFloat t_width = kCellWidth;
        CGFloat t_height = kTrainCellImageHeight;
        CGRect frame = CGRectMake(kCellWidth + kLeftSpace, 0, t_width, t_height);
        self.rightTempCell = [[SNRollingTrainImageTextCell alloc] initWithFrame:frame];
        self.rightTempCell.type = SNTrainCellTypeCards;
        [self addSubview:_rightTempCell];
    }
}

- (void)addLeftTempCell {
    if (!_leftTempCell) {
        CGFloat t_width = kCellWidth;
        CGFloat t_height = kTrainCellImageHeight;
        CGRect frame = CGRectMake(-t_width - kLeftSpace, 0, t_width, t_height);
        self.leftTempCell = [[SNRollingTrainImageTextCell alloc] initWithFrame:frame];
        self.leftTempCell.type = SNTrainCellTypeCards;
        [self addSubview:_leftTempCell];
    }
}

- (void)removeTempCells {
    [self.tempCell removeFromSuperview];
    self.tempCell = nil;
    [self.rightTempCell removeFromSuperview];
    self.rightTempCell = nil;
    [self.leftTempCell removeFromSuperview];
    self.leftTempCell = nil;
}

+ (NSMutableArray *)getTowTopNews:(NSArray *)itemArray{
    //如果全屏焦点图没有文字的话动画效果有问题
    //return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    for (SNRollingNews *news in itemArray) {
        if (![news isTowTopNews]) {
            break;
        }
        
        [array addObject:news];
    }
    
    return array;
}

#pragma mark --
#pragma mark - UICollectionView UIScrollViewDeleagte
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = self.frame.size.width;
    NSInteger index = (scrollView.contentOffset.x + width * 0.5) / width;

    //当滚动到最后一张图片时，继续滚向后动跳到第一张
    if (index == self.item.news.newsFocusArray.count + 1)
    {
        self.currentIndex = 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        return;
    }
    
    //当滚动到第一张图片时，继续向前滚动跳到最后一张
    if (scrollView.contentOffset.x < width * 0.5)
    {
        self.currentIndex = self.item.news.newsFocusArray.count;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        return;
    }
    self.currentIndex = index;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = self.currentIndex - 1;
    if (index < self.item.news.newsFocusArray.count) {
        SNRollingNews * news = [self.item.news.newsFocusArray objectAtIndex:index];
        [self reportNewsDidShow:news];
    }
}

#pragma mark --
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.focusCollectionData.count) {
        SNRollingNews * selectedNews = [self.focusCollectionData objectAtIndex:indexPath.row];
        [self openNews:selectedNews isFocus:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark --
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.focusCollectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNRollingNews * item = nil;
    if (indexPath.row < self.focusCollectionData.count) {
        item = [self.focusCollectionData objectAtIndex:indexPath.row];
    }
    SNRollingTrainImageTextCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSNRollingTrainImageTextCellIdentifier forIndexPath:indexPath];
    cell.type = SNTrainCellTypeFocus;
    [cell setItem:item];
    return cell;
}

#pragma mark --
#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width, collectionView.height);
}

@end
