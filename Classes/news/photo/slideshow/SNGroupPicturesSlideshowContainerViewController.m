//
//  SNGroupPicturesSlideshowContainerViewController.m
//  sohunews
//
//  Created by Gao Yongyue on 14-2-14.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNGroupPicturesSlideshowContainerViewController.h"
#import "SNGroupPicturesSlideshowViewController.h"
#import "SNConst+PicturesSlideshowViewController.h"
#import "SNPhotoSlideshow.h"
#import "SNPhotoSlideshowRecommendView.h"
#import "SNSubInfoView.h"
#import "SNDBManager.h"
#import "SNSlideshowFooterView.h"
#import "SNPhotoConfigs.h"

#import "SNPhotoGalleryPlainSlideshowController.h"
#import "SNPhotoGallerySlideshowController.h"

#import "SNAdDataCarrier.h"
#import "SNRollingNewsPublicManager.h"

#define kDefaultContainerCount 3

@interface SNGroupPicturesSlideshowContainerViewController ()<UIScrollViewDelegate ,SNPhotoSlideshowDelegate, SNGroupPicturesSlideshowViewControllerDelegate, SNPhotoSlideshowRecommendViewDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *_scrollView;
    SNSubInfoView *_headerView;
    SNSlideshowFooterView *_footerView;
    NSInteger _currentGroupIndex; //_currentIndex=0,第一组;_currentIndex=1,为中间的组;_currentIndex=2:为最后一组
}
@property (nonatomic, strong)NSString *previousNewsID;
@property (nonatomic, strong)NSString *nextNewsID;
@property (nonatomic, strong)NSMutableArray *groupPicturesSlideshowDataSourceContainer;      //数据的容器
@property (nonatomic, strong)NSMutableArray *groupPicturesSlideshowViewControllerContainer;  //controller的容器
@property (nonatomic, strong)NSMutableArray *recommendIdArray;
@end

@implementation SNGroupPicturesSlideshowContainerViewController

- (id)initWithCurrentSlideshows:(SNPhotoSlideshow *)slideshows index:(int)index delegate:(id<SNGroupPicturesSlideshowContainerViewControllerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _currentSlideshowIndex = index;
        _delegate = delegate;
        if (!slideshows.photos || [slideshows.photos count] == 0)
        {
            //重新去请求数据
            SNPhotoSlideshow *preparedSlideshows = [[SNPhotoSlideshow alloc] initWithTermId:slideshows.termId newsId:slideshows.newsId channelId:slideshows.channelId isOnlineMode:slideshows.isOnlineMode];
            preparedSlideshows.typeId = slideshows.typeId;
            preparedSlideshows.type = slideshows.type;
            preparedSlideshows.galleryLoadType = GalleryLoadTypeNone;
            preparedSlideshows.slideshowDelegate = self;
            _currentSlideshows = preparedSlideshows;
            [preparedSlideshows load:TTURLRequestCachePolicyDefault more:NO];
        }
        else
        {
            _currentSlideshows = slideshows;
        }
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"]) {
        [SNNotificationManager postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"whiteStyle"}];
        [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
    }
    else {
        [SNNotificationManager postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"blackStyle"}];
        [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-kMultiPicturePadding/2, 0.f, kAppScreenWidth + kMultiPicturePadding, kAppScreenHeight)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:_scrollView];
    
    _groupPicturesSlideshowDataSourceContainer = [[NSMutableArray alloc] initWithCapacity:3];
    _groupPicturesSlideshowViewControllerContainer = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self reloadGroupPicturesSlideshows:_currentSlideshows];
    
    _footerView = [[SNSlideshowFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, 113.f) pictureInfo:_currentSlideshows.photos[_currentSlideshowIndex]];
    _footerView.bottom = self.view.height;
    __weak typeof(&*self) blockSelf = self;
    [_footerView setBackButtonActionBlock:^{
        //返回操作
        [blockSelf closeSNGroupPicturesSlideshowContainerViewController];
        [SNNotificationManager postNotificationName:kSliderShowViewClosedNotification object:nil];
    } commentButtonActionBlock:^{
        //发表评论操作
        [[blockSelf currentGroupPicturesSlideshowViewController] commentAction];
    } downloadButtonActionBlock:^{
        //下载图片操作
        [[blockSelf currentGroupPicturesSlideshowViewController] downloadAction];
    } shareButtonActionBlock:^{
        //分享操作
        [[blockSelf currentGroupPicturesSlideshowViewController] shareAction];
    } commentCount:@"0"];
    [self.view addSubview:_footerView];
    
    [self refreshStatusbar];
    //添加点击手势
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapRecognizedGesture:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapRecognizedGesture:)];
    doubleTapGestureRecognizer.delegate = self;
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
    
    [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    UISwipeGestureRecognizer *recognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGroupPicturesSwipeGestureUpOrDown:)];
    [recognizerUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizerUp];
    //2017-02-08 wangchuanwen 添加下滑手势 update begin
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGroupPicturesSwipeGestureUpOrDown:)];
    [recognizerDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizerDown];
     [SNNotificationManager addObserver:self selector:@selector(closeSNGroupPicturesSlideshowContainerViewController) name:GallerySliderPicturesNotification object:nil];
    //2017-02-08 wangchuanwen update end
    if (![SNUtility getApplicationDelegate].isNetworkReachable)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

- (void)refreshStatusbarWithLightContent:(BOOL)lightContentStyle
{
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:lightContentStyle];
}

- (void)refreshStatusbar
{
    [SNNotificationManager postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"blackStyle"}];
    [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
}

- (void)closeSNGroupPicturesSlideshowContainerViewController
{
    if ([self.delegate isKindOfClass:[SNPhotoGalleryPlainSlideshowController class]])
    {
        SNPhotoGalleryPlainSlideshowController *_photoGalleryPlainSlideshowController = (SNPhotoGalleryPlainSlideshowController *)(self.delegate);
        [_photoGalleryPlainSlideshowController.flipboardNavigationController popViewControllerAnimated:YES];
    }
    else if ([self.delegate isKindOfClass:[SNPhotoGallerySlideshowController class]])
    {
        SNPhotoGallerySlideshowController *_photoGallerySlideshowController = (SNPhotoGallerySlideshowController *)(self.delegate);
        [_photoGallerySlideshowController photoViewDidClose];
    }
    //[self refreshStatusbarWithLightContent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [SNNotificationManager postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"whiteStyle"}];
        [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
    }
}

- (UIImage *)currentImage
{
    return [[self currentGroupPicturesSlideshowViewController] currentImage];
}

- (BOOL)isRecommendViewOrAdView
{
    if (![_currentSlideshows isKindOfClass:[SNPhotoSlideshow class]]) {
        _currentSlideshows = nil;
        return NO;
    }
    return [self currentSlideshowIndex] >= _currentSlideshows.photos.count;
}

- (SNGroupPicturesSlideshowViewController *)currentGroupPicturesSlideshowViewController
{
    return (SNGroupPicturesSlideshowViewController *)_groupPicturesSlideshowViewControllerContainer[_currentGroupIndex];
}

- (NSInteger)currentSlideshowIndex
{
    return [self currentGroupPicturesSlideshowViewController].slideshowIndex;
}

- (NSString *)getPreviousGroupPicturesNewsID
{
    NSString *previousGroupPicturesNewsID = nil;
    if (_gallerySourceType == GallerySourceTypeGroupPhoto || _gallerySourceType == GallerySourceTypeNewsPaper)//新闻流里的组图
    {
        if (_gallerySourceType == GallerySourceTypeNewsPaper && !self.allItems)
        {
            previousGroupPicturesNewsID = _currentSlideshows.photoList.preId.length > 0 ? _currentSlideshows.photoList.preId : nil;
        }
        else
        {
            NSInteger index = [self.allItems indexOfObject:_currentSlideshows.newsId];
            if (index != NSNotFound && index > 0 && index < self.allItems.count)
            {
                previousGroupPicturesNewsID = self.allItems[index - 1];
            }
        }
    }
    else if (_gallerySourceType == GallerySourceTypeRecommend)//来源于推荐
    {
        NSInteger index = [_recommendIdArray indexOfObject:_currentSlideshows.newsId];
        if (index != NSNotFound && index > 0 && index < [_recommendIdArray count])
        {
            previousGroupPicturesNewsID = _recommendIdArray[index - 1];
        }
        return previousGroupPicturesNewsID;
    }
    return previousGroupPicturesNewsID;
}

- (NSString *)getNextGroupPicturesNewsIDWithCurrentSlideshow:(SNPhotoSlideshow *)slideshow
{
    if (!slideshow) {
        return nil;
    }
    
    NSString *nextGroupPicturesNewsID = nil;
    if (_gallerySourceType == GallerySourceTypeGroupPhoto || _gallerySourceType == GallerySourceTypeNewsPaper)
    {
        if (_gallerySourceType == GallerySourceTypeNewsPaper && !self.allItems)
        {
//            if(slideshow.photoList.nextId.length == 0)
//            {
//                NSMutableDictionary* dic = [SNUtility parseProtocolUrl:slideshow.photoList.nextNewsLink2 schema:kProtocolPhoto];
//                NSString *nextId = dic[kNewsId];
//                nextGroupPicturesNewsID = (nextId.length > 0) ? nextId : nil;
//            }
//            else
//            {
//                nextGroupPicturesNewsID = slideshow.photoList.nextId;
//            }
            nextGroupPicturesNewsID = [slideshow.photoList.nextId length] > 0 ? slideshow.photoList.nextId : nil;
        }
        else if(self.allItems && [self.allItems count])
        {
            NSInteger index = [self.allItems indexOfObject:slideshow.newsId];
            if (index != NSNotFound && index >= 0 && index < self.allItems.count - 1)
            {
                nextGroupPicturesNewsID = self.allItems[index + 1];
            }
        }
    }
    else if ( _gallerySourceType == GallerySourceTypeRecommend)//来源于推荐
    {
        NSString *nextGid = slideshow.nextGid;
        NSUInteger index = [_recommendIdArray indexOfObject:nextGid];
        if (nextGid && NSNotFound == index)
        {
            [_recommendIdArray addObject:nextGid];
        }
        return nextGid;
    }
    return nextGroupPicturesNewsID;
}

- (void)prepareNeighborGroupPicturesAtIndex:(NSInteger)index
{
    if (![self.currentSlideshows isKindOfClass:[SNPhotoSlideshow class]]) {
        return;
    }
    self.previousNewsID = [self getPreviousGroupPicturesNewsID];
    self.nextNewsID = [self getNextGroupPicturesNewsIDWithCurrentSlideshow:_currentSlideshows];
    if (_previousNewsID)
    {
        [self prepareGroupPicturesInfo:_previousNewsID type:GalleryLoadTypePrev];
    }
    if (_nextNewsID)
    {
        [self prepareGroupPicturesInfo:_nextNewsID type:GalleryLoadTypeNext];
    }
    if (_currentGroupIndex == 0 && [_groupPicturesSlideshowViewControllerContainer count] == 3 && self.allItems)
    {
        NSInteger index = [self.allItems indexOfObject:_currentSlideshows.newsId];
        if (index + 2 < [self.allItems count])
        {
            SNPhotoSlideshow *preparedSlideshow = [self preparedSlideshowWithNewsID:self.allItems[index + 2] type:GalleryLoadTypeNext];
            _groupPicturesSlideshowDataSourceContainer[2] = preparedSlideshow;
            [preparedSlideshow load:TTURLRequestCachePolicyDefault more:NO];
        }
    }
    else if (_currentGroupIndex == 2 && [_groupPicturesSlideshowViewControllerContainer count] == 3 && self.allItems)
    {
        NSInteger index = [self.allItems indexOfObject:_currentSlideshows.newsId];
        if (index - 2 < [self.allItems count] && index - 2 >= 0)
        {
            SNPhotoSlideshow *preparedSlideshow = [self preparedSlideshowWithNewsID:self.allItems[index - 2] type:GalleryLoadTypePrev];
            _groupPicturesSlideshowDataSourceContainer[0] = preparedSlideshow;
            [preparedSlideshow load:TTURLRequestCachePolicyDefault more:NO];
        }
    }
}

- (void)prepareGroupPicturesInfo:(NSString *)newsID type:(GalleryLoadType)type
{
    if (!newsID || ![newsID length])
    {
        return;
    }
    SNPhotoSlideshow *preparedSlideshow = [self preparedSlideshowWithNewsID:newsID type:type];
    if (type == GalleryLoadTypePrev && _currentGroupIndex > 0 && (_currentGroupIndex - 1) < [_groupPicturesSlideshowDataSourceContainer count])
    {
        _groupPicturesSlideshowDataSourceContainer[_currentGroupIndex - 1] = preparedSlideshow;
    }
    else if (type == GalleryLoadTypeNext)
    {
        _groupPicturesSlideshowDataSourceContainer[_currentGroupIndex + 1] = preparedSlideshow;
    }
    [preparedSlideshow load:TTURLRequestCachePolicyDefault more:NO];
}

- (SNPhotoSlideshow *)preparedSlideshowWithNewsID:(NSString *)newsID type:(GalleryLoadType)type
{
    SNPhotoSlideshow *preparedSlideshows = [[SNPhotoSlideshow alloc] initWithTermId:self.termId newsId:newsID channelId:_currentSlideshows.channelId isOnlineMode:_currentSlideshows.isOnlineMode];
    preparedSlideshows.typeId = _currentSlideshows.typeId;
    preparedSlideshows.type = _currentSlideshows.type;
    preparedSlideshows.galleryLoadType = type;
    preparedSlideshows.slideshowDelegate = self;
    
    return preparedSlideshows;
}

- (void)prepareSubInfoHeaderView
{
    //所属刊物
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_currentSlideshows.subId];
    if (subObj && _headerView)
    {
        _headerView.subObj = subObj;
    }
    else if (subObj)
    {
        _headerView = [[SNSubInfoView alloc] initWithSubInfoViewType:SNSubInfoViewTypeGallery];
        _headerView.newsId = self.currentSlideshows.newsId ? : @"0";
        _headerView.refer = REFER_GROUPPHOTOLIST;
        _headerView.top = 5 + kSystemBarHeight;
        _headerView.left = 10;
        _headerView.subObj = subObj;
        [self.view addSubview:_headerView];
    }
    else if (_headerView)
    {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
}

- (void)prepareForReuse
{
    _currentGroupIndex = 0;
    _currentSlideshowIndex = 0;
    [_scrollView removeAllSubviews];
    [_groupPicturesSlideshowViewControllerContainer removeAllObjects];
    
    [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SNPhotoSlideshow class]])
        {
            ((SNPhotoSlideshow *)obj).slideshowDelegate = nil;
        }
    }];
    [_groupPicturesSlideshowDataSourceContainer removeAllObjects];
}

- (void)reloadGroupPicturesSlideshows:(SNPhotoSlideshow *)slideshows
{
    NSInteger pageCount = 0;
    self.currentSlideshows = slideshows;
    self.previousNewsID = [self getPreviousGroupPicturesNewsID];
    self.nextNewsID = [self getNextGroupPicturesNewsIDWithCurrentSlideshow:_currentSlideshows];
    
    if (_gallerySourceType == GallerySourceTypeRecommend)
    {
        pageCount = 1;
    }
    else
    {
        pageCount = [self.allItems count] < 3 ? [self.allItems count] : 3;
        if (pageCount == 0)
        {
            if (_previousNewsID && _nextNewsID)
            {
                pageCount = 3;
            }
            else
            {
                //pageCount = (_previousNewsID || _nextNewsID) ? 2 : 1;
                pageCount = (_previousNewsID || _nextNewsID) ? 3 : 1;   //lijian 2015.01.29 这个问题找起来很困难，h5->娱乐头条->最后一组组图打开slide向前拉一屏幕 结果不能往后拉了
            }
        }
    }
    
    //_4.3.3_闪退：《欢乐网事》往期9.04日中的组图新闻，slide页滑到推荐组图，再左滑闪退-[SNGroupPicturesSlideshowContainerViewController ]修改这个bug
    //l383行 pageCount = (_previousNewsID || _nextNewsID) ? 3 : 1; 计算pageCount方式改变后（原来为？ 2： 1），scroll长度计算错误,默认始终创建左中右三个容器，但是实际scroll宽度根据pageCount计算
    for (int i = 0; i < kDefaultContainerCount; i++)
    {
        SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = [[SNGroupPicturesSlideshowViewController alloc] init];
        groupPicturesSlideshowViewController.delegate = self;
        groupPicturesSlideshowViewController.view.frame = CGRectMake(i * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight);
        groupPicturesSlideshowViewController.myFavouriteRefer = _myFavouriteRefer;
        [_scrollView addSubview:groupPicturesSlideshowViewController.view];
        _groupPicturesSlideshowViewControllerContainer[i] = groupPicturesSlideshowViewController;
        
        _groupPicturesSlideshowDataSourceContainer[i] = @"0";
    }

    if (_previousNewsID && _nextNewsID)
    {
        _currentGroupIndex = pageCount - 2;
    }
    else
    {
        _currentGroupIndex = _previousNewsID ? (pageCount - 1) : 0;
    }
    _currentGroupIndex = (pageCount == 1) ? 0 : _currentGroupIndex;
    _currentGroupIndex = (_currentGroupIndex < 0) ? 0 : _currentGroupIndex;
    
    _scrollView.contentSize = CGSizeMake(pageCount*(kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
    SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = [self currentGroupPicturesSlideshowViewController];
    [groupPicturesSlideshowViewController reloadViewsWithPictures:_currentSlideshows index:_currentSlideshowIndex isRecommendView:NO];
    [groupPicturesSlideshowViewController displayCurrentSlideshowView];
    _groupPicturesSlideshowDataSourceContainer[_currentGroupIndex] = _currentSlideshows;
    
    [self prepareSubInfoHeaderView];
    CGFloat alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7f : 1.f;
    _headerView.alpha = _currentSlideshowIndex == 0 ? alpha : 0.f;
    [_scrollView setContentOffset:CGPointMake(_currentGroupIndex*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
    [self prepareNeighborGroupPicturesAtIndex:_currentGroupIndex];
}

- (void)resizeGroupPicturesSlideshowViewControllerFrame
{
    [_groupPicturesSlideshowViewControllerContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = (SNGroupPicturesSlideshowViewController *)obj;
        groupPicturesSlideshowViewController.view.frame = CGRectMake(idx * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight);
    }];
}

- (void)viewDidUnload
{
    _previousNewsID = nil;
    _nextNewsID = nil;
    _currentSlideshows = nil;
    _allItems = nil;
    [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SNPhotoSlideshow class]])
        {
            ((SNPhotoSlideshow *)obj).slideshowDelegate = nil;
        }
    }];
    _groupPicturesSlideshowDataSourceContainer = nil;
    _groupPicturesSlideshowViewControllerContainer = nil;
    _recommendIdArray = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    _previousNewsID = nil;
    _nextNewsID = nil;
    _currentSlideshows = nil;
    _allItems = nil;
    [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SNPhotoSlideshow class]])
        {
            ((SNPhotoSlideshow *)obj).slideshowDelegate = nil;
        }
    }];
    _groupPicturesSlideshowDataSourceContainer = nil;
    _groupPicturesSlideshowViewControllerContainer = nil;
    _recommendIdArray = nil;
    
    [SNNotificationManager removeObserver:self name:GallerySliderPicturesNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    //最后一组图时，继续滑动闪退bug modify by wyy
    if (index >= [_groupPicturesSlideshowViewControllerContainer count]) {
        return;
    }
    SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = _groupPicturesSlideshowViewControllerContainer[index];
    [groupPicturesSlideshowViewController loadPlaceholderView:_groupPicturesSlideshowDataSourceContainer[index]];
    [groupPicturesSlideshowViewController displayCurrentSlideshowView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _scrollView.scrollEnabled = YES;
    CGRect bounds = scrollView.bounds;
    NSInteger originalGroupIndex = _currentGroupIndex;
	_currentGroupIndex = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    if (originalGroupIndex == _currentGroupIndex)
    {
        return;
    }
    
    BOOL isNextGroup = NO;
    
    switch (_currentGroupIndex)
    {
        case 0:
        {
            //说明是滑到了前一个组图(原来index=1)
            if ([_groupPicturesSlideshowDataSourceContainer[0] isKindOfClass:[SNPhotoSlideshow class]]) {
                self.currentSlideshows = _groupPicturesSlideshowDataSourceContainer[0];
            }
            else {
                self.currentSlideshows = nil;
            }
            
            self.previousNewsID = [self getPreviousGroupPicturesNewsID];
            if (self.previousNewsID)
            {
                _currentGroupIndex = 1;
                //缓冲前一组组图
                SNPhotoSlideshow *preSlideshow = [self preparedSlideshowWithNewsID:_previousNewsID type:GalleryLoadTypePrev];
                //重新整理_groupPicturesDataSourceContainer和_groupPicturesViewControllerContainer这两个参数
                self.groupPicturesSlideshowDataSourceContainer = [NSMutableArray arrayWithArray:@[preSlideshow, _groupPicturesSlideshowDataSourceContainer[0], _groupPicturesSlideshowDataSourceContainer[1]]];
                SNGroupPicturesSlideshowViewController *lastGroupPicturesSlideshowViewController = (SNGroupPicturesSlideshowViewController *)[_groupPicturesSlideshowViewControllerContainer lastObject];
                [lastGroupPicturesSlideshowViewController prepareForReuse];
                self.groupPicturesSlideshowViewControllerContainer = [NSMutableArray arrayWithArray:@[_groupPicturesSlideshowViewControllerContainer[2],_groupPicturesSlideshowViewControllerContainer[0],_groupPicturesSlideshowViewControllerContainer[1]]];
                [self resizeGroupPicturesSlideshowViewControllerFrame];
                [_scrollView setContentOffset:CGPointMake(_currentGroupIndex*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
                [preSlideshow load:TTURLRequestCachePolicyDefault more:NO];
            }
        }
            break;
        case 1:
        {
            //有可能是滑到了前一个组图（原来index=2）,也有可能是滑到了后一组组图（原来index=0）
            if ([_groupPicturesSlideshowDataSourceContainer[1] isKindOfClass:[SNPhotoSlideshow class]]) {
                self.currentSlideshows = _groupPicturesSlideshowDataSourceContainer[1];
            }
            else {
                self.currentSlideshows = nil;
            }
            
            if (originalGroupIndex == 0)
            {
                isNextGroup = YES;
                self.nextNewsID = [self getNextGroupPicturesNewsIDWithCurrentSlideshow:_currentSlideshows];
                [self prepareGroupPicturesInfo:self.nextNewsID type:GalleryLoadTypeNext];
            }
            else if (originalGroupIndex == 2)
            {
                self.previousNewsID = [self getPreviousGroupPicturesNewsID];
                [self prepareGroupPicturesInfo:self.previousNewsID type:GalleryLoadTypePrev];
            }
        }
            break;
        case 2:
        {
            //说明滑到了下一组组图(原来index=1)
            isNextGroup = YES;
            if ([_groupPicturesSlideshowDataSourceContainer[2] isKindOfClass:[SNPhotoSlideshow class]]) {
                self.currentSlideshows = _groupPicturesSlideshowDataSourceContainer[2];
            }
            else {
                self.currentSlideshows = nil;
            }
            self.nextNewsID = [self getNextGroupPicturesNewsIDWithCurrentSlideshow:_currentSlideshows];
            if (self.nextNewsID)
            {
                _currentGroupIndex = 1;
                //缓冲后一组组图
                SNPhotoSlideshow *nextSlideshow = [self preparedSlideshowWithNewsID:_nextNewsID type:GalleryLoadTypeNext];
                //重新整理_groupPicturesDataSourceContainer和_groupPicturesViewControllerContainer这两个参数
                self.groupPicturesSlideshowDataSourceContainer = [NSMutableArray arrayWithArray:@[_groupPicturesSlideshowDataSourceContainer[1], _groupPicturesSlideshowDataSourceContainer[2], nextSlideshow]];
                SNGroupPicturesSlideshowViewController *firstGroupPicturesSlideshowViewController = (SNGroupPicturesSlideshowViewController *)_groupPicturesSlideshowViewControllerContainer[0];
                [firstGroupPicturesSlideshowViewController prepareForReuse];
                self.groupPicturesSlideshowViewControllerContainer = [NSMutableArray arrayWithArray:@[_groupPicturesSlideshowViewControllerContainer[1],_groupPicturesSlideshowViewControllerContainer[2],_groupPicturesSlideshowViewControllerContainer[0]]];
                [self resizeGroupPicturesSlideshowViewControllerFrame];
                [_scrollView setContentOffset:CGPointMake(_currentGroupIndex*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
                [nextSlideshow load:TTURLRequestCachePolicyDefault more:NO];
            }
        }
            break;
        default:
            break;
    }
    [[self currentGroupPicturesSlideshowViewController] loadPlaceholderView:_currentSlideshows];
    [[self currentGroupPicturesSlideshowViewController] displayCurrentSlideshowView];
    //if (_gallerySourceType != GallerySourceTypeRecommend && _delegate && [_delegate respondsToSelector:@selector(slideshowDidChangeWithTermId:newsId:)])
    {
        if ([self.currentSlideshows isKindOfClass:[SNPhotoSlideshow class]]) {
            [_delegate slideshowDidChangeWithTermId:self.currentSlideshows.termId newsId:self.currentSlideshows.newsId slideToNextGroup:isNextGroup];
        }
    }
    [self prepareSubInfoHeaderView];
    [self photoDidMoveToIndex:[self currentGroupPicturesSlideshowViewController].slideshowIndex slideshow:_currentSlideshows];
    if (![SNUtility getApplicationDelegate].isNetworkReachable)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    
    //保存阅读状态
    [SNRollingNewsPublicManager saveReadNewsWithNewsId:self.currentSlideshows.newsId ChannelId:self.currentSlideshows.channelId];
    if ([self.currentSlideshows.channelId isEqualToString:@"47"]) {
        [SNNotificationManager postNotificationName:photoListSlideshowDidChange object:self.currentSlideshows.newsId];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _scrollView.scrollEnabled = NO;
    self.previousNewsID = [self getPreviousGroupPicturesNewsID];
    self.nextNewsID = [self getNextGroupPicturesNewsIDWithCurrentSlideshow:_currentSlideshows];
    //滑动到第一组再向前滑动的时候，关闭
    if (!self.previousNewsID && _scrollView.contentOffset.x < 0)
    {
        [self closeSNGroupPicturesSlideshowContainerViewController];
    }
    //滑动到最后一组再向后滑动的时候，提示已经是最后一组了，不关闭
    if (!self.nextNewsID && _scrollView.contentOffset.x > (_scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds)))
    {
        if(_supportContinuousReadingNext) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"AlreadyLastNews", @"Already last news") toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

#pragma mark - SNPhotoSlideshowDelegate
- (void)didFinishPreLoad:(GalleryLoadType)glType slideshow:(SNPhotoSlideshow *)slideshowData
{
    if (glType == GalleryLoadTypePrev)
    {
        int currentPageCount = _scrollView.contentSize.width/(kAppScreenWidth + kMultiPicturePadding);
        if (currentPageCount < 3 && (_gallerySourceType == GallerySourceTypeRecommend || _currentGroupIndex == 0))
        {
            _scrollView.contentSize = CGSizeMake((currentPageCount + 1)*(kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
            SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = [[SNGroupPicturesSlideshowViewController alloc] init];
            groupPicturesSlideshowViewController.delegate = self;
            groupPicturesSlideshowViewController.view.frame = CGRectMake(currentPageCount * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight);
            groupPicturesSlideshowViewController.myFavouriteRefer = _myFavouriteRefer;
            _groupPicturesSlideshowViewControllerContainer[currentPageCount] = groupPicturesSlideshowViewController;
            [_scrollView addSubview:groupPicturesSlideshowViewController.view];
            
            if (currentPageCount < _groupPicturesSlideshowDataSourceContainer.count) {
                [groupPicturesSlideshowViewController reloadViewsWithPictures:_groupPicturesSlideshowDataSourceContainer[currentPageCount] index:0 isRecommendView:YES];
            }
            
            //把前面的viewcontroller向后挪动
            [_groupPicturesSlideshowDataSourceContainer insertObject:_groupPicturesSlideshowDataSourceContainer[currentPageCount] atIndex:0];
            [_groupPicturesSlideshowViewControllerContainer insertObject:_groupPicturesSlideshowViewControllerContainer[currentPageCount] atIndex:0];
            [self resizeGroupPicturesSlideshowViewControllerFrame];
            //位移
            [_scrollView setContentOffset:CGPointMake(1*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
        }
        else
        {
            [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SNPhotoSlideshow *slideshow = (SNPhotoSlideshow *)obj;
                if ([slideshow isKindOfClass:[SNPhotoSlideshow class]] && [slideshowData.newsId isEqualToString:slideshow.newsId])
                {
                    SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = (SNGroupPicturesSlideshowViewController *)_groupPicturesSlideshowViewControllerContainer[idx];
                    [groupPicturesSlideshowViewController reloadViewsWithPictures:slideshowData index:0 isRecommendView:YES];
                }
            }];
        }
    }
    else if (glType == GalleryLoadTypeNext)
    {
        NSInteger currentPageCount = _scrollView.contentSize.width/(kAppScreenWidth + kMultiPicturePadding);
        
        if (currentPageCount < 3 && (_gallerySourceType == GallerySourceTypeRecommend || _currentGroupIndex == currentPageCount - 1))
        {
            _scrollView.contentSize = CGSizeMake((currentPageCount + 1)*(kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
            
            SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = [[SNGroupPicturesSlideshowViewController alloc] init];
            groupPicturesSlideshowViewController.delegate = self;
            groupPicturesSlideshowViewController.view.frame = CGRectMake(currentPageCount * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight);
            groupPicturesSlideshowViewController.myFavouriteRefer = _myFavouriteRefer;
            _groupPicturesSlideshowViewControllerContainer[currentPageCount] = groupPicturesSlideshowViewController;
            [_scrollView addSubview:groupPicturesSlideshowViewController.view];
            currentPageCount = MIN(currentPageCount, [_groupPicturesSlideshowDataSourceContainer count] - 1);
            [groupPicturesSlideshowViewController reloadViewsWithPictures:_groupPicturesSlideshowDataSourceContainer[currentPageCount] index:0 isRecommendView:NO];
        }
        else
        {
            [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SNPhotoSlideshow *slideshow = (SNPhotoSlideshow *)obj;
                if ([slideshow isKindOfClass:[SNPhotoSlideshow class]] &&
                    [slideshowData.newsId isEqualToString:slideshow.newsId] &&
                    [slideshowData.photos count] > 0)
                {
                    SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = (SNGroupPicturesSlideshowViewController *)_groupPicturesSlideshowViewControllerContainer[idx];
                    [groupPicturesSlideshowViewController reloadViewsWithPictures:slideshowData index:0 isRecommendView:NO];
                }
            }];
        }
    }
    else if (glType == GalleryLoadTypeNone)
    {
        //说明是当前的
        SNGroupPicturesSlideshowViewController *currentGroupPicturesSlideshowViewController = [self currentGroupPicturesSlideshowViewController];
        [currentGroupPicturesSlideshowViewController reloadViewsWithPictures:self.currentSlideshows index:_currentSlideshowIndex isRecommendView:NO];
        [currentGroupPicturesSlideshowViewController displayCurrentSlideshowView];
        [self prepareSubInfoHeaderView];
        _footerView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7f : 1.f;
        [self prepareNeighborGroupPicturesAtIndex:_currentGroupIndex];
    }
}

- (void)didFailedPreLoad:(GalleryLoadType)glType slideshow:(SNPhotoSlideshow *)slideshowData
{
    [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNPhotoSlideshow *slideshow = (SNPhotoSlideshow *)obj;
        if ([slideshow isKindOfClass:[SNPhotoSlideshow class]] && [slideshowData.newsId isEqualToString:slideshow.newsId])
        {
            SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = (SNGroupPicturesSlideshowViewController *)_groupPicturesSlideshowViewControllerContainer[idx];
            //显示点击加载的页面
            [groupPicturesSlideshowViewController showEmbededActivityIndicator];
        }
    }];
}

#pragma mark - SNGroupPicturesSlideshowViewControllerDelegate
- (void)reloadSlideshowInfo:(SNPhotoSlideshow *)slideshowData
{
    [slideshowData load:TTURLRequestCachePolicyDefault more:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowDidTapRetry)]) {
        [self.delegate slideshowDidTapRetry];
    }
}

//- (void)updateCommentCount:(NSString *)commentCount slideshow:(SNPhotoSlideshow *)slideshow
//{
//    [_footerView updateCommentCount:_currentSlideshows.commentNum];
//}

- (void)photoDidMoveToIndex:(NSInteger)index slideshow:(SNPhotoSlideshow *)slideshow
{
    if (![_currentSlideshows isKindOfClass:[SNPhotoSlideshow class]]) {
        _currentSlideshows = nil;
        return;
    }
    if (![slideshow isEqual:_currentSlideshows])
    {
        return;
    }
    [UIView animateWithDuration:.3f animations:^{
        if ([[self currentGroupPicturesSlideshowViewController] isRecommendView])
        {
            _headerView.alpha = 0.f;
            _footerView.userInteractionEnabled = NO;
            [_footerView hideAllButtons];
        }
        else if ([[self currentGroupPicturesSlideshowViewController] isAdView])
        {
            _headerView.alpha = 0.f;
            _footerView.userInteractionEnabled = YES;
            [_footerView showAdButtons];
        }
        else if (index < _currentSlideshows.photos.count || index == 0)//这里原有个等于0的特殊逻辑
        {
            _footerView.userInteractionEnabled = YES;
            CGFloat alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7f : 1.f;
            _headerView.alpha = (index == 0 && _footerView.alpha != 0) ? alpha : 0.f;  //只是每组组图的第一页显示所属刊物（header）,其它页面统一不显示
            [_footerView showAllButtons];
            [_footerView updateAbstract:_currentSlideshows.photos[index]];
        }
    }];
}

- (BOOL)hasNextGroupWithCurrentSlideshow:(SNPhotoSlideshow *)slideshow
{
    NSString *nextGroupPicturesNewsID = [self getNextGroupPicturesNewsIDWithCurrentSlideshow:slideshow];
    return (nextGroupPicturesNewsID && [nextGroupPicturesNewsID length]);
}

#pragma mark - SNPhotoSlideshowRecommendViewDelegate
- (void)photoDidRecommendAtNewsId:(NSString *)newsId
{
    if (!newsId)
    {
        return;
    }
    self.recommendIdArray = [NSMutableArray array];
    [self.recommendIdArray addObject:newsId];
    
    _gallerySourceType = GallerySourceTypeRecommend;
    self.termId = @"0"; //推荐组图没有termId,故为0
    SNPhotoSlideshow *slideShows = [[SNPhotoSlideshow alloc] initWithTermId:self.termId newsId:newsId channelId:nil isOnlineMode:YES];
    slideShows.typeId = _currentSlideshows.typeId;
    slideShows.type = _currentSlideshows.type;
    slideShows.galleryLoadType = GalleryLoadTypeNone;
    slideShows.slideshowDelegate = self;
    self.currentSlideshows = slideShows;
    [self prepareForReuse];
    [self reloadGroupPicturesSlideshows:slideShows];
    [self photoDidMoveToIndex:0 slideshow:_currentSlideshows];
//    [_footerView updateCommentCount:@"0"];
    [slideShows load:TTURLRequestCachePolicyDefault more:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(slideshowDidChangeWithGalleryId:)])
    {
        [_delegate slideshowDidChangeWithGalleryId:newsId];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (void)didTapRecognizedGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        CGFloat alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7f : 1.f;
        [UIView animateWithDuration:.3f animations:^{
            //显示简介&隐藏简介
            if (_footerView.alpha == 0.f)
            {
                //显示简介
                _footerView.alpha = alpha;
                _headerView.alpha = ([self currentGroupPicturesSlideshowViewController].slideshowIndex == 0) ? alpha : 0.f;
            }
            else
            {
                //隐藏简介
                _footerView.alpha = 0.f;
                _headerView.alpha = 0.f;
            }
        }];
    }
}

- (void)didDoubleTapRecognizedGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        [[self currentGroupPicturesSlideshowViewController] setSlideshowViewZoom];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[SNSlideshowFooterView class]] || [touch.view isKindOfClass:[SNSubInfoView class]] || [touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    return YES;
}

- (void)handleGroupPicturesSwipeGestureUpOrDown:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    [self closeSNGroupPicturesSlideshowContainerViewController];
    
    //2017-02-08 wangchuanwen update begin 添加上下滑动统计
    dispatch_async(dispatch_queue_create("slidePicsCount", DISPATCH_QUEUE_CONCURRENT), ^{
        
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            
            [SNNewsReport reportADotGif:@"_act=cc&fun=101&mode=1"];
        } else {
            [SNNewsReport reportADotGif:@"_act=cc&fun=101&mode=0"];
        }
    });
    //2017-02-08 wangchuanwen update end
}

- (void)refreshAd:(SNAdDataCarrier *)ad12238 ad13371:(SNAdDataCarrier *)ad13371 ad12233:(SNAdDataCarrier *)ad12233
{
    [self currentGroupPicturesSlideshowViewController].slideshows.sdkAd13371 = ad13371;
    [self currentGroupPicturesSlideshowViewController].slideshows.sdkAdLastPic = ad12233;
    [self currentGroupPicturesSlideshowViewController].slideshows.sdkAdLastRecommend = ad12238;
}

@end
