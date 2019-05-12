//
//  SNRollingTrainCardsCell.m
//  sohunews
//
//  Created by Huang Zhen on 2017/11/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainCardsCell.h"
#import "SNRollingTrainCollectionView.h"
#import "SNRollingTrainCellConst.h"
#import "NSTimer+SNBlocksSupport.h"
#import "SNNewsAd+analytics.h"
#import "SNCommonNewsDatasource.h"
#import "SNCommonNewsController.h"
#import "SNRollingNewsConst.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNTrainLoadMoreViewCell.h"
#import "SNSubRollingNewsModel.h"
#import "SNRollingNewsViewController.h"

@interface SNRollingTrainCardsCell ()<UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout>
{
    CGFloat _offsetValue;
    BOOL _isLoadingMore;
    NSInteger _curIndex;
}
@property (nonatomic, strong) UIImageView * editorLogo;
@property (nonatomic, strong) UILabel * editorLabel;
@property (nonatomic, strong) SNTrainLoadMoreViewCell * loadMoreView;

@property (nonatomic, strong) SNRollingTrainCollectionView * trainCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * trainCollectionViewLayout;
@property (nonatomic, strong) NSMutableArray * trainCollectionData;
@property (nonatomic, strong) NSIndexPath * selectedIndexPath;
@end

@implementation SNRollingTrainCardsCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kSmallTrainCellHeight+2*kLeftSpace;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self buildCollectionView];
        _offsetValue = 0;
        _curIndex = 0;
        [SNNotificationManager addObserver:self selector:@selector(updateTrainViewPosition:) name:kRollingNewsTrainViewPositionChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kRollingNewsTrainViewPositionChangedNotification object:nil];
    if (self.trainCollectionView) {
        self.trainCollectionView.delegate = nil;
        self.trainCollectionView = nil;
    }
}

- (void)updateTrainViewPosition:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    if (dic.count > 0) {
        NSString *newsId = [dic valueForKey:kNewsId];
        NSString *channelId = [dic valueForKey:kChannelId];
        NSString *trainID = [dic valueForKey:kTrainId];
        NSInteger trainIndex = [[dic valueForKey:kTrainIndex] integerValue];
        if ([trainID isEqualToString:self.item.news.trainCardId]) {
            [self setCollectionViewContentOffsetWithIndex:trainIndex animated:NO];
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (_isLoadingMore) {
        [self.loadMoreView stopLoading];
        _isLoadingMore = NO;
    }
}

- (void)buildEditLabel {
    if (!self.editorLabel) {
        CGRect logoRect = CGRectMake(kLeftSpace+kCardLeftSpace, kLeftSpace+kCardLeftSpace, kLeftSpace, kLeftSpace);
        self.editorLogo = [[UIImageView alloc] initWithFrame:logoRect];
        self.editorLogo.backgroundColor = [UIColor clearColor];
        //阴影颜色
        self.editorLogo.layer.shadowColor = [UIColor blackColor].CGColor;
        //阴影偏移  x，y为正表示向右下偏移
        self.editorLogo.layer.shadowOffset = CGSizeMake(0, 1);
        //阴影透明度
        self.editorLogo.layer.shadowOpacity = 0.4;
        //阴影宽度
        self.editorLogo.layer.shadowRadius = 6.0;
        [self addSubview:self.editorLogo];
        CGRect labelRect = CGRectMake(self.editorLogo.right + 7, kLeftSpace, kLeftSpace, kLeftSpace);
        self.editorLabel = [[UILabel alloc] initWithFrame:labelRect];
        self.editorLabel.text = @"搜狐编辑部";
        //阴影颜色
        self.editorLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        //阴影偏移  x，y为正表示向右下偏移
        self.editorLabel.layer.shadowOffset = CGSizeMake(0, 1);
        //阴影透明度
        self.editorLabel.layer.shadowOpacity = 0.4;
        //阴影宽度
        self.editorLabel.layer.shadowRadius = 6.0;
        [self addSubview:self.editorLabel];
    }
    self.editorLogo.image = [UIImage imageNamed:@"icohome_sohubjb_v5.png"];
    self.editorLabel.font = [SNTrainCellHelper trainCardCellEditLabelFont];//fullscreenEditNewsTitleFont 的中号字 固定不变
    self.editorLabel.textColor = [SNTrainCellHelper trainCellEditorLabelTitleColor];
    [self.editorLabel sizeToFit];
    self.editorLabel.centerY = self.editorLogo.centerY;
}

- (void)buildCollectionView {
    [self setupCollectionViewLayout];
    if (!_trainCollectionView) {
        CGRect frame = CGRectMake(0, 0, kCellWidth, kSmallTrainCellHeight + 28);
        self.trainCollectionView = [[SNRollingTrainCollectionView alloc] initWithFrame:frame collectionViewLayout:self.trainCollectionViewLayout];
        self.trainCollectionView.backgroundColor = [UIColor clearColor];
        self.trainCollectionView.delegate = self;
        self.trainCollectionView.dataSource = self;
        self.trainCollectionView.showsHorizontalScrollIndicator = NO;
        self.trainCollectionView.alwaysBounceVertical = NO;
        self.trainCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:self.trainCollectionView];
    }
}

- (void)setupCollectionViewLayout {
    if (!self.trainCollectionViewLayout) {
        CGFloat space = kCardLeftSpace/2.f;
        CGFloat marginLeft = kLeftSpace;
        self.trainCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        self.trainCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.trainCollectionViewLayout.sectionInset = UIEdgeInsetsMake(marginLeft, marginLeft, marginLeft, marginLeft);
        self.trainCollectionViewLayout.minimumLineSpacing = space;
        self.trainCollectionViewLayout.minimumInteritemSpacing = space;
        CGFloat footerSizeWidth = kAppScreenWidth - 2*kLeftSpace - kSmallTrainCellWidth;
        self.trainCollectionViewLayout.footerReferenceSize = CGSizeMake(footerSizeWidth, kSmallTrainCellHeight);
    }
}

- (void)openNews:(SNRollingNews *)news withTrainIndex:(NSInteger)trainIndex {
    [SNUtility shouldUseSpreadAnimation:YES];
    
    //订阅流广告点击统计
    if (self.item.subscribeAdObject && [news.newsType isEqualToString:kNewsTypeAd]) {
        [self reportPopularizeClick];
    }
    
    // 广告点击曝光
    if ([news.newsType isEqualToString:kNewsTypeAd]) {
        [news.newsAd reportAdClick:news];
    } else {
        //火车卡片clk埋点
        [self reportADotGif:news];
    }
    
    [item.controller cacheCellIndexPath:self];
    if (news.newsType != nil &&
        [SNCommonNewsController supportContinuation:news.newsType]) {
        NSMutableDictionary *dic = nil;
        if (item.dataSource) {
            //更新火车卡片连续阅读内容的数量
            for (SNRollingNewsTableItem *newsItem in
                 item.dataSource.allList) {
                if (newsItem.cellType == SNRollingNewsCellTypeTrainCard) {
                    if ([newsItem.news.trainCardId isEqualToString:self.item.news.trainCardId]) {
                        if (newsItem.news.newsItemArray.count != self.trainCollectionData.count) {
                            newsItem.news.newsItemArray = self.trainCollectionData;
                        }
                        break;
                    }
                }
            }
            dic = [item.dataSource getContentDictionary:news];
        }
        
        NSMutableDictionary *pDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:kContinuityPhoto]];
        [pDic setObject:[NSNumber numberWithInteger:trainIndex] forKey:kTrainIndex];
        [pDic setObject:news.trainCardId forKey:kTrainId];
        
        [dic setObject:pDic forKey:kContinuityPhoto];
        //newsfrom=5/6由recomInfo确定，isRecom后期会作废
        [dic setObject:kChannelEditionNews forKey:kNewsFrom];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    } else if(news.link.length > 0) {
        if ([news.link startWith:kProtocolVideo]) {
            //二代协议视频: video://
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
    NSString *paramStr = [NSString stringWithFormat:@"_act=card_news&_tp=clk&channelid=%@&newsid=%@",newsItem.channelId, newsItem.newsId];
    [SNNewsReport reportADotGif:paramStr];
}

- (void)reportCardsItemShow {
    if (self.item.news.reportState == AdReportStateNo) {
        NSString *paramStr = [NSString stringWithFormat:@"_act=card_item&_tp=pv&channelid=%@",self.item.news.channelId];
        [SNNewsReport reportADotGif:paramStr];
        self.item.news.reportState = AdReportStateLoad;
    }
}

#pragma mark --
#pragma mark - 视频自动播放
- (BOOL)isVideoCellVisible {
    NSArray * visibleCells = [self.trainCollectionView visibleCells];
    for (UICollectionViewCell * cell in visibleCells) {
        if ([cell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
            CGRect frame = [cell convertRect:cell.bounds toView:nil];
            if (frame.origin.x >= 0 && frame.origin.x + frame.size.width <= kAppScreenWidth) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)isVideoCellPlaying {
    NSArray * visibleCells = [self.trainCollectionView visibleCells];
    for (UICollectionViewCell * cell in visibleCells) {
        if ([cell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
            return [(SNRollingTrainPGCVideoCell *)cell isPlaying];
        }
    }
    return NO;
}

//视频跟UITableView同步
- (void)transformVideoIntoTableView {
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
        SNRollingNewsViewController *rollingController = (SNRollingNewsViewController *)[[TTNavigator navigator] topViewController];
        [[rollingController getCurrentTableController].dragDelegate transformationAutoPlayTop:((TTTableView *)[rollingController getCurrentTableController].tableView)];
    }
}

//开始播放视频
- (void)autoPlayVideo {
    [self reportCardsItemShow];
    NSArray * visibleCells = [self.trainCollectionView visibleCells];
    for (UICollectionViewCell * cell in visibleCells) {
        if ([cell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
            CGRect frame = [cell convertRect:cell.bounds toView:nil];
            if (frame.origin.x >= 0 && frame.origin.x + frame.size.width <= kAppScreenWidth) {
                [(SNRollingTrainPGCVideoCell *)cell autoPlay];
            }
        }
    }
}

//停止播放视频
- (void)stopVideo {
    NSArray * visibleCells = [self.trainCollectionView visibleCells];
    for (UICollectionViewCell * cell in visibleCells) {
        if ([cell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
            CGRect frame = [cell convertRect:cell.bounds toView:nil];
            if (frame.origin.x >= 0 && frame.origin.x + frame.size.width <= kAppScreenWidth) {
                [(SNRollingTrainPGCVideoCell *)cell stopPlay];
            }
        }
    }
}

#pragma mark --
#pragma mark - 数据/UI
- (void)updateTrainCardTheme {
    [self buildEditLabel];
    if (self.item.news.isCardsFromFocus) {
        [self.trainCollectionView setContentOffset:CGPointMake([SNNewsFullscreenManager manager].rollingFocusAnchor, 0)];
        CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
        _curIndex = [SNNewsFullscreenManager manager].rollingFocusAnchor/(pageWidth);
        self.item.news.trainCellIndex = _curIndex;
    }else{
        [self.trainCollectionView setContentOffset:CGPointMake(self.item.news.trainCellContentOffsetX, 0)];
        _curIndex = self.item.news.trainCellIndex;
        _offsetValue = self.item.news.trainCellContentOffsetX;
    }
//    SNDebugLog(@"############################# update curindex: %d",_curIndex);

}

- (void)updateTrainCardData {
    if (!self.trainCollectionData) {
        self.trainCollectionData = [NSMutableArray array];
    }
    [self.trainCollectionData removeAllObjects];
    if (self.item.news.newsFocusArray.count > 0) {
        [self.trainCollectionData addObjectsFromArray:self.item.news.newsFocusArray];
        [self.trainCollectionData addObjectsFromArray:self.item.news.newsItemArray];
    }else{
        [self.trainCollectionData addObjectsFromArray:self.item.news.newsItemArray];
    }
}

- (void)updateData {
    [self updateTrainCardData];
    [self resetLoadMoreViewSize];
    [self.trainCollectionView reloadData];
    [self collectionViewCellDisplaying];
}

- (void)updateContentView {
    [super updateContentView];
    [self updateTheme];
    [self updateData];
}

- (void)updateTheme {
    [super updateTheme];
    [self updateTrainCardTheme];
}

- (void)updateImage {
    [self resetLoadMoreViewSize];
    [self.trainCollectionView reloadData];
}

- (void)resetLoadMoreViewSize {
    CGFloat lastCardWidth = kSmallTrainCellWidth;
    BOOL lastIsPGC = NO;
    if (self.trainCollectionData.count > 0) {
        SNRollingNews * lastNews = self.trainCollectionData.lastObject;
        if (lastNews && [lastNews isKindOfClass:[SNRollingNews class]]) {
            if ([self isPGCNews:lastNews]) {
                lastIsPGC = YES;
            }
        }
    }
    [self.loadMoreView resetSizeWithPgc:lastIsPGC];
    
}

- (BOOL)isPGCNews:(SNRollingNews *)news {
    NSInteger templateType = news.templateType.integerValue;
    return templateType == 34 || templateType == 37;
}

- (void)setCollectionViewContentOffsetWithIndex:(NSInteger)index animated:(BOOL)animated {
    if (index >= 0 && index < self.trainCollectionData.count && index != _curIndex) {
//        CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
//        CGFloat offset = kLeftSpace - kCardLeftSpace/2.f + index * pageWidth;
//        if (index == 0) {
//            offset = 0;
//        }
//        SNDebugLog(@"#############################setCollectionViewContentOffset curindex: %d",_curIndex);
        _curIndex = index;
        self.item.news.trainCellIndex = _curIndex;
        [self.trainCollectionView setContentOffset:CGPointMake([self offsetXWithIndex:index], 0) animated:animated];
    }
}

- (void)loadMoreCardsData {
    //卡片横滑加载更多
    if (!_isLoadingMore && !self.item.news.trainDataAllDidLoad) {
        _isLoadingMore = YES;
        [self.loadMoreView startLoading];
        SNRollingNewsModel * model = self.item.dataSource.newsModel;
        if ([model isKindOfClass:[SNSubRollingNewsModel class]]) {
            [(SNSubRollingNewsModel *)model loadMoreTrainNews:self.item.news.trainCardId
                                                     trainPos:self.item.news.trainPos
                                                      success:^(id responseObject) {
                [self.loadMoreView stopLoading];
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    NSArray * array = (NSArray *)responseObject;
                    if (array.count > 0) {
                        [self.trainCollectionData addObjectsFromArray:array];
                        [self resetLoadMoreViewSize];
                        [self.trainCollectionView reloadData];
                    }else{
                        self.item.news.trainDataAllDidLoad = YES;
                        [self.loadMoreView allFinishedLoad];
                    }
                }
                _isLoadingMore = NO;
            } failure:^(NSError *error) {
                [self.loadMoreView stopLoading];
                _isLoadingMore = NO;
            }];
        }
    }
}

- (void)collectionViewCellDisplaying {
    CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
    int index = self.trainCollectionView.contentOffset.x/(pageWidth);
    if (index >= 0 && index < self.trainCollectionData.count) {
        NSArray * visibleCells = [self.trainCollectionView visibleCells];
        for (UICollectionViewCell * cell in visibleCells) {
            if ([cell isKindOfClass:[SNRollingTrainCollectionBaseCell class]]) {
                CGRect frame = [cell convertRect:cell.bounds toView:nil];
                SNRollingTrainCollectionBaseCell * baseCell = (SNRollingTrainCollectionBaseCell *)cell;
                if (frame.origin.x >= 0 && frame.origin.x + frame.size.width <= kAppScreenWidth) {
                    //代表整个卡片展示出来 按照目前的UI设计，当前屏幕内至多只会存在一个完整的cell
                    [baseCell cellFullDisplaying];
                    if ([baseCell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
                        //如果不是PGC视频需要进入UITableView判断
                        [self transformVideoIntoTableView];
                    }
                } else {
                    [baseCell cellIsDisplaying];
                    if ([baseCell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
                        //如果不是PGC视频需要进入UITableView判断
                        [self transformVideoIntoTableView];
                    }
                }
            }
        }
    }
}

//- (NSInteger)indexWithOffsetX:(CGFloat)offsetX {
//    NSInteger i = 0;
//    if (offsetX >= 0) {
//        CGFloat stepOffsetX = 0.0;
//        CGFloat errorf = 5;
//        CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
//        CGFloat videoPageWidth = (kSmallTrainPGCCellWidth+kCardLeftSpace/2.f);
//        for (SNRollingNews * news in self.trainCollectionData) {
//            if ([news isKindOfClass:[SNRollingNews class]]) {
//                CGFloat diff = offsetX - stepOffsetX;
//                BOOL isPGC = [self isPGCNews:news];
//                CGFloat pageW = isPGC ? videoPageWidth : pageWidth;
//                if (diff < pageW) {
//                    return i;
//                }
//                if (offsetX <= stepOffsetX + errorf
//                    && offsetX >= stepOffsetX - errorf) {
//                    //在可接受误差范围内即可
//                    return i;
//                }
//                stepOffsetX += pageW;
//                i++;
//            }
//        }
//    }
//    if (i >= self.trainCollectionData.count) {
//        i = self.trainCollectionData.count - 1;
//    }
//    return i;
//}

- (CGFloat)offsetXWithIndex:(NSInteger)index {
    if (index < 0) {
        index = 0;
    }
    if (index >= self.trainCollectionData.count) {
        index = (self.trainCollectionData.count - 1);
    }
    CGFloat offsetX = 0.0;
    NSInteger i = 0;
    CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
    CGFloat videoPageWidth = (kSmallTrainPGCCellWidth+kCardLeftSpace/2.f);
    for (SNRollingNews * news in self.trainCollectionData) {
        if ([news isKindOfClass:[SNRollingNews class]]) {
            if (i == index) {
                return offsetX;
            }
            if ([self isPGCNews:news]) {
                offsetX += videoPageWidth;
            }else{
                offsetX += pageWidth;
            }
            i++;
        }
    }
    return offsetX;
}

#pragma mark --
#pragma mark - UICollectionView UIScrollViewDeleagte
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat curOffsetX = [self offsetXWithIndex:_curIndex];
    CGFloat targetOffsetX = curOffsetX;
    CGFloat abs_diff = fabsf(offsetX - curOffsetX);
    CGFloat diff = offsetX - curOffsetX;
    NSInteger curIndex = _curIndex;
//    CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
//    CGFloat videoPageWidth = (kSmallTrainPGCCellWidth+kCardLeftSpace/2.f);
//    SNRollingNews * curNews = [self.trainCollectionData objectAtIndex:_curIndex];
//    BOOL isPGC = [self isPGCNews:curNews];
//    CGFloat t = isPGC ? videoPageWidth/2.f : pageWidth/2.f;
    CGFloat t = 25;
    if (velocity.x == 0) {
        if (diff >= 0) {//scroll right
            if (abs_diff > t) {
                //大于临界值，滚动到下一个page
                curIndex +=1;
                //计算下一个page的offset
                targetOffsetX = [self offsetXWithIndex:curIndex];
            }else{
                //小于临界值，滚动还原当前page
            }
        } else {//scroll left
            if (abs_diff > t) {
                //大于临界值，滚动到上一个page
                curIndex -=1;
                //计算上一个page的offset
                targetOffsetX = [self offsetXWithIndex:curIndex];
            }else{
                //小于临界值，滚动还原当前page
            }
        }
    }else if (velocity.x > 0) {
        //滚动到下一个page
        curIndex +=1;
        //计算下一个page的offset
        targetOffsetX = [self offsetXWithIndex:curIndex];
    }else{
//        velocity.x < 0
        //滚动到上一个page
        curIndex -=1;
        //计算上一个page的offset
        targetOffsetX = [self offsetXWithIndex:curIndex];
    }
//    NSLog(@"vvvvvvvvvvvvvvvvvvvvvvvv : %f",velocity.x);
    *targetContentOffset = CGPointMake(targetOffsetX, 0);
    if (curIndex < 0) {
        curIndex = 0;
    }
    if (curIndex >= self.trainCollectionData.count) {
        curIndex = (self.trainCollectionData.count - 1);
    }
    _curIndex = curIndex;
    self.item.news.trainCellIndex = _curIndex;
//    SNDebugLog(@"############################# curindex: %d",_curIndex);
//    CGFloat pageWidth = (kSmallTrainCellWidth+kCardLeftSpace/2.f);
//    CGFloat videoPageWidth = (kSmallTrainPGCCellWidth+kCardLeftSpace/2.f);
//
//    int index = scrollView.contentOffset.x/(pageWidth);
//    if (index < 0 || index >= self.trainCollectionData.count) {
//        return;
//    }
//    if (velocity.x >= 0) {
//        if (velocity.x == 0) {
//            CGFloat diff = scrollView.contentOffset.x - index * pageWidth;
//            if (diff > pageWidth/2.f) {
//                index += 1;
//            }
//        }else{
//            if (scrollView.contentOffset.x - index * pageWidth > 20 && index < self.trainCollectionData.count - 1) {
//                index += 1;
//            }
//        }
//    }
//    CGFloat offset =  index * pageWidth;
//    if (index == 0) {
//        offset = 0;
//    }
//    *targetContentOffset = CGPointMake(offset, 0);
//    _curIndex = index;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.frame.size.width*2)) {
        //倒数第三个卡片，开始loadmore
        [self loadMoreCardsData];
    }
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _offsetValue = scrollView.contentOffset.x;
    //cell复用记录锚点
    self.item.news.isCardsFromFocus = NO;
    self.item.news.trainCellContentOffsetX = _offsetValue;
    [self collectionViewCellDisplaying];
}

#pragma mark --
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.trainCollectionData.count) {
        [self setClickCellOriginWith:indexPath];
        
        SNRollingNews * selectedNews = [self.trainCollectionData objectAtIndex:indexPath.row];
        if ([self isPGCNews:selectedNews]) {
            
        }else{
            [self openNews:selectedNews withTrainIndex:indexPath.row];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SNRollingTrainCollectionBaseCell class]]) {
        SNRollingTrainCollectionBaseCell * baseCell = (SNRollingTrainCollectionBaseCell *)cell;
        [baseCell cellDidEndDisplaying];
        if ([baseCell isKindOfClass:[SNRollingTrainPGCVideoCell class]]) {
            //如果不是PGC视频需要进入UITableView判断
            [self transformVideoIntoTableView];
        }
    }
}

#pragma mark --
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.trainCollectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNRollingNews * item = nil;
    SNRollingTrainImageTextCell * cell = nil;
    if (indexPath.row < self.trainCollectionData.count) {
        item = [self.trainCollectionData objectAtIndex:indexPath.row];
    }
    switch (item.templateType.integerValue) {
        //SNRollingNewsCellTypeNewsVideo
        case 34:
        case 37:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSNRollingTrainPGCVideoCellIdentifier forIndexPath:indexPath];
            cell.type = SNTrainCellTypeCards;
            break;
        }
        default:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSNRollingTrainImageTextCellIdentifier forIndexPath:indexPath];
            cell.type = SNTrainCellTypeCards;
            break;
        }
    }
    [cell setItem:item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSNTrainLoadMoreViewCellIdentifier forIndexPath:indexPath];
        if ([view isKindOfClass:[SNTrainLoadMoreViewCell class]]) {
            self.loadMoreView = (SNTrainLoadMoreViewCell *)view;
            if (self.trainCollectionData.count > 0 && _isLoadingMore) {
                [self.loadMoreView startLoading];
            }else{
                if (self.item.news.trainDataAllDidLoad) {
                    [self.loadMoreView allFinishedLoad];
                }else{
                    [self.loadMoreView stopLoading];
                }
            }
        }
        return view;
    }
    return nil;
}

#pragma mark --
#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNRollingNews * item = nil;
    if (indexPath.row < self.trainCollectionData.count) {
        item = [self.trainCollectionData objectAtIndex:indexPath.row];
    }
    NSInteger templateType = item.templateType.integerValue;
    switch (templateType) {
        //SNRollingNewsCellTypeNewsVideo
        case 34:
        case 37:
        {
            //PGC视频模板16：9
            return CGSizeMake(kSmallTrainPGCCellWidth, kSmallTrainCellHeight);
            break;
        }
        default:
        {
            //普通图文模板3：2
            return CGSizeMake(kSmallTrainCellWidth, kSmallTrainCellHeight);
            break;
        }
    }
    return CGSizeMake(kSmallTrainCellWidth, kSmallTrainCellHeight);
}

- (void)setClickCellOriginWith:(NSIndexPath *)indexPath {
    //中间展开动画使用坐标
    if ([self.trainCollectionView respondsToSelector:@selector(cellForItemAtIndexPath:)]) {
        UICollectionViewCell *cell = [self.trainCollectionView cellForItemAtIndexPath:indexPath];
        CGRect rect = [self.trainCollectionView convertRect:cell.frame toView:self.trainCollectionView];
        CGRect rectInScreen = [self.trainCollectionView convertRect:rect toView:[UIApplication sharedApplication].keyWindow];
        [SNUserDefaults setDouble:rectInScreen.origin.y forKey:kRememberCellOriginYInScreen];
    }
}

@end
