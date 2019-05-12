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

#import "SNPhotoGalleryPlainSlideshowController.h"
#import "SNPhotoGallerySlideshowController.h"

@interface SNGroupPicturesSlideshowContainerViewController ()<UIScrollViewDelegate ,SNPhotoSlideshowDelegate, SNGroupPicturesSlideshowViewControllerDelegate, SNPhotoSlideshowRecommendViewDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *_scrollView;
    SNSubInfoView *_headerView;
    SNSlideshowFooterView *_footerView;
    int _currentGroupIndex; //_currentIndex=0,第一组;_currentIndex=1,为中间的组;_currentIndex=2:为最后一组
}
@property (nonatomic, retain)NSString *previousNewsID;
@property (nonatomic, retain)NSString *nextNewsID;
@property (nonatomic, retain)NSMutableArray *groupPicturesSlideshowDataSourceContainer;      //数据的容器
@property (nonatomic, retain)NSMutableArray *groupPicturesSlideshowViewControllerContainer;  //controller的容器
@property (nonatomic, retain)NSMutableArray *recommendIdArray;
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
            _currentSlideshows = [preparedSlideshows retain];
            [preparedSlideshows load:TTURLRequestCachePolicyDefault more:NO];
            [preparedSlideshows release];
        }
        else
        {
            _currentSlideshows = [slideshows retain];
        }
    }
    return self;
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
    [_scrollView release];
    
    _groupPicturesSlideshowDataSourceContainer = [[NSMutableArray alloc] initWithCapacity:3];
    _groupPicturesSlideshowViewControllerContainer = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self reloadGroupPicturesSlideshows:_currentSlideshows];
    
    _footerView = [[SNSlideshowFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, 113.f) pictureInfo:_currentSlideshows.photos[_currentSlideshowIndex]];
    _footerView.bottom = self.view.height;
    __block typeof(&*self) blockSelf = self;
    [_footerView setBackButtonActionBlock:^{
        //返回操作
        [blockSelf closeSNGroupPicturesSlideshowContainerViewController];
    } commentListButtonActionBlock:^{
        //查看评论列表操作
        [[blockSelf currentGroupPicturesSlideshowViewController] showCommentListAction];
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
    [_footerView release];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.f)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"blackStyle"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
    }
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
    [tapGestureRecognizer release];
    [doubleTapGestureRecognizer release];
    
    if (![[SNUtility getApplicationDelegate] checkNetworkStatus])
    {
        [SNNotificationCenter showMessage:@"网络连接失败"];
    }
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"whiteStyle"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
    }
}

- (UIImage *)currentImage
{
    return [[self currentGroupPicturesSlideshowViewController] currentImage];
}

- (BOOL)isRecommendViewOrAdView
{
    return [self currentSlideshowIndex] >= _currentSlideshows.photos.count;
}

- (SNGroupPicturesSlideshowViewController *)currentGroupPicturesSlideshowViewController
{
    return (SNGroupPicturesSlideshowViewController *)_groupPicturesSlideshowViewControllerContainer[_currentGroupIndex];
}

- (int)currentSlideshowIndex
{
    return [self currentGroupPicturesSlideshowViewController].slideshowIndex;
}

- (NSString *)getPreviousGroupPicturesNewsID
{
    NSString *previousGroupPicturesNewsID = nil;
    if (_gallerySourceType == GallerySourceTypeGroupPhoto)//新闻流里的组图
    {
        int index = [self.allItems indexOfObject:_currentSlideshows.newsId];
        if (index != NSNotFound && index > 0 && index < self.allItems.count)
        {
            previousGroupPicturesNewsID = self.allItems[index - 1];
        }
    }
    else if (_gallerySourceType == GallerySourceTypeRecommend)//来源于推荐
    {
        int index = [_recommendIdArray indexOfObject:_currentSlideshows.newsId];
        if (index != NSNotFound && index > 0 && index < [_recommendIdArray count])
        {
            previousGroupPicturesNewsID = _recommendIdArray[index - 1];
        }
        return previousGroupPicturesNewsID;
    }
    else if (_gallerySourceType == GallerySourceTypeNewsPaper)
    {
        previousGroupPicturesNewsID = _currentSlideshows.photoList.preId.length > 0 ? _currentSlideshows.photoList.preId : nil;
    }
    return previousGroupPicturesNewsID;
}

- (NSString *)getNextGroupPicturesNewsID
{
    NSString *nextGroupPicturesNewsID = nil;
    if (_gallerySourceType == GallerySourceTypeGroupPhoto)
    {
        int index = [self.allItems indexOfObject:_currentSlideshows.newsId];
        if (index != NSNotFound && index >= 0 && index < self.allItems.count - 1)
        {
            nextGroupPicturesNewsID = self.allItems[index + 1];
        }
    }
    else if ( _gallerySourceType == GallerySourceTypeRecommend)//来源于推荐
    {
        NSString *nextGid = _currentSlideshows.nextGid;
        NSUInteger index = [_recommendIdArray indexOfObject:nextGid];
        if (nextGid && NSNotFound == index)
        {
            [_recommendIdArray addObject:nextGid];
        }
        return nextGid;
    }
    else if (_gallerySourceType == GallerySourceTypeNewsPaper)
    {
        if(_currentSlideshows.photoList.nextId.length == 0)
        {
            NSMutableDictionary* dic = [SNUtility parseProtocolUrl:_currentSlideshows.photoList.nextNewsLink2 schema:kProtocolPhoto];
            NSString *nextId = dic[kNewsId];
            nextGroupPicturesNewsID = (nextId.length > 0) ? nextId : nil;
        }
        else
        {
            nextGroupPicturesNewsID = _currentSlideshows.photoList.nextId;
        }
    }
    return nextGroupPicturesNewsID;
}

- (void)prepareNeighborGroupPicturesAtIndex:(int)index
{
    self.previousNewsID = [self getPreviousGroupPicturesNewsID];
    self.nextNewsID = [self getNextGroupPicturesNewsID];
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
        int index = [self.allItems indexOfObject:_currentSlideshows.newsId];
        if (index + 2 < [self.allItems count])
        {
            SNPhotoSlideshow *preparedSlideshow = [self preparedSlideshowWithNewsID:self.allItems[index + 2] type:GalleryLoadTypeNext];
            _groupPicturesSlideshowDataSourceContainer[2] = preparedSlideshow;
            [preparedSlideshow load:TTURLRequestCachePolicyDefault more:NO];
        }
    }
    else if (_currentGroupIndex == 2 && [_groupPicturesSlideshowViewControllerContainer count] == 3 && self.allItems)
    {
        int index = [self.allItems indexOfObject:_currentSlideshows.newsId];
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
    if (type == GalleryLoadTypePrev)
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
    
    return [preparedSlideshows autorelease];
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
        _headerView.refer = REFER_GROUPPHOTOLIST;
        _headerView.top = 5 + kSystemBarHeight;
        _headerView.left = 5;
        _headerView.subObj = subObj;
        [self.view addSubview:_headerView];
        [_headerView release];
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
    int pageCount = 0;
    self.currentSlideshows = slideshows;
    self.previousNewsID = [self getPreviousGroupPicturesNewsID];
    self.nextNewsID = [self getNextGroupPicturesNewsID];
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
                pageCount = (_previousNewsID || _nextNewsID) ? 2 : 1;
            }
        }
    }
    
    for (int i = 0; i < pageCount; i++)
    {
        SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = [[SNGroupPicturesSlideshowViewController alloc] init];
        groupPicturesSlideshowViewController.delegate = self;
        groupPicturesSlideshowViewController.view.frame = CGRectMake(i * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight);
        groupPicturesSlideshowViewController.myFavouriteRefer = _myFavouriteRefer;
        [_scrollView addSubview:groupPicturesSlideshowViewController.view];
        _groupPicturesSlideshowViewControllerContainer[i] = groupPicturesSlideshowViewController;
        [groupPicturesSlideshowViewController release];
        
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
    [_previousNewsID release], _previousNewsID = nil;
    [_nextNewsID release], _nextNewsID = nil;
    [_currentSlideshows release], _currentSlideshows = nil;
    [_allItems release], _allItems = nil;
    [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SNPhotoSlideshow class]])
        {
            ((SNPhotoSlideshow *)obj).slideshowDelegate = nil;
        }
    }];
    [_groupPicturesSlideshowDataSourceContainer release], _groupPicturesSlideshowDataSourceContainer = nil;
    [_groupPicturesSlideshowViewControllerContainer release], _groupPicturesSlideshowViewControllerContainer = nil;
    [_recommendIdArray release], _recommendIdArray = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [_previousNewsID release], _previousNewsID = nil;
    [_nextNewsID release], _nextNewsID = nil;
    [_currentSlideshows release], _currentSlideshows = nil;
    [_allItems release], _allItems = nil;
    [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SNPhotoSlideshow class]])
        {
            ((SNPhotoSlideshow *)obj).slideshowDelegate = nil;
        }
    }];
    [_groupPicturesSlideshowDataSourceContainer release], _groupPicturesSlideshowDataSourceContainer = nil;
    [_groupPicturesSlideshowViewControllerContainer release], _groupPicturesSlideshowViewControllerContainer = nil;
    [_recommendIdArray release], _recommendIdArray = nil;
    [super dealloc];
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
    SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = _groupPicturesSlideshowViewControllerContainer[index];
    [groupPicturesSlideshowViewController loadPlaceholderView:_groupPicturesSlideshowDataSourceContainer[index]];
    [groupPicturesSlideshowViewController displayCurrentSlideshowView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _scrollView.scrollEnabled = YES;
    CGRect bounds = scrollView.bounds;
    int originalGroupIndex = _currentGroupIndex;
	_currentGroupIndex = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    if (originalGroupIndex == _currentGroupIndex)
    {
        return;
    }
    switch (_currentGroupIndex)
    {
        case 0:
        {
            //说明是滑到了前一个组图(原来index=1)
            self.currentSlideshows = _groupPicturesSlideshowDataSourceContainer[0];
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
            self.currentSlideshows = _groupPicturesSlideshowDataSourceContainer[1];
            if (originalGroupIndex == 0)
            {
                self.nextNewsID = [self getNextGroupPicturesNewsID];
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
            self.currentSlideshows = _groupPicturesSlideshowDataSourceContainer[2];
            self.nextNewsID = [self getNextGroupPicturesNewsID];
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
    if (_gallerySourceType != GallerySourceTypeRecommend && _delegate && [_delegate respondsToSelector:@selector(slideshowDidChangeWithTermId:newsId:)])
    {
        [_delegate slideshowDidChangeWithTermId:self.currentSlideshows.termId newsId:self.currentSlideshows.newsId];
    }
    [self prepareSubInfoHeaderView];
    [_footerView updateCommentCount:_currentSlideshows.commentNum];
    [self photoDidMoveToIndex:[self currentGroupPicturesSlideshowViewController].slideshowIndex slideshow:_currentSlideshows];
    if (![[SNUtility getApplicationDelegate] checkNetworkStatus])
    {
        [SNNotificationCenter showMessage:@"网络连接失败"];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _scrollView.scrollEnabled = NO;
    self.previousNewsID = [self getPreviousGroupPicturesNewsID];
    self.nextNewsID = [self getNextGroupPicturesNewsID];
    //滑动到第一组再向前滑动的时候，关闭
    if (!self.previousNewsID && _scrollView.contentOffset.x < 0)
    {
        [self closeSNGroupPicturesSlideshowContainerViewController];
    }
    //滑动到最后一组再向后滑动的时候，提示已经是最后一组了，不关闭
    if (!self.nextNewsID && _scrollView.contentOffset.x > (_scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds)))
    {
        [SNNotificationCenter showMessage:NSLocalizedString(@"AlreadyLastNews", @"Already last news")];
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
            [groupPicturesSlideshowViewController reloadViewsWithPictures:_groupPicturesSlideshowDataSourceContainer[currentPageCount] index:0 isRecommendView:YES];
            [groupPicturesSlideshowViewController release];
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
        int currentPageCount = _scrollView.contentSize.width/(kAppScreenWidth + kMultiPicturePadding);
        if (currentPageCount < 3 && (_gallerySourceType == GallerySourceTypeRecommend || _currentGroupIndex == currentPageCount - 1))
        {
            _scrollView.contentSize = CGSizeMake((currentPageCount + 1)*(kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
            
            SNGroupPicturesSlideshowViewController *groupPicturesSlideshowViewController = [[SNGroupPicturesSlideshowViewController alloc] init];
            groupPicturesSlideshowViewController.delegate = self;
            groupPicturesSlideshowViewController.view.frame = CGRectMake(currentPageCount * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight);
            groupPicturesSlideshowViewController.myFavouriteRefer = _myFavouriteRefer;
            _groupPicturesSlideshowViewControllerContainer[currentPageCount] = groupPicturesSlideshowViewController;
            [_scrollView addSubview:groupPicturesSlideshowViewController.view];
            [groupPicturesSlideshowViewController reloadViewsWithPictures:_groupPicturesSlideshowDataSourceContainer[currentPageCount] index:0 isRecommendView:NO];
            [groupPicturesSlideshowViewController release];
        }
        else
        {
            [_groupPicturesSlideshowDataSourceContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SNPhotoSlideshow *slideshow = (SNPhotoSlideshow *)obj;
                if ([slideshow isKindOfClass:[SNPhotoSlideshow class]] && [slideshowData.newsId isEqualToString:slideshow.newsId])
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
}

- (void)updateCommentCount:(NSString *)commentCount slideshow:(SNPhotoSlideshow *)slideshow
{
    [_footerView updateCommentCount:_currentSlideshows.commentNum];
}

- (void)photoDidMoveToIndex:(int)index slideshow:(SNPhotoSlideshow *)slideshow
{
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
        else if (index < _currentSlideshows.photos.count || index == 0)
        {
            _footerView.userInteractionEnabled = YES;
            CGFloat alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7f : 1.f;
            _headerView.alpha = (index == 0 && _footerView.alpha != 0) ? alpha : 0.f;  //只是每组组图的第一页显示所属刊物（header）,其它页面统一不显示
            [_footerView showAllButtons];
            [_footerView updateAbstract:_currentSlideshows.photos[index]];
        }
    }];

    if (_delegate && [_delegate respondsToSelector:@selector(photoDidMoveToIndex:)])
    {
        [_delegate photoDidMoveToIndex:index];
    }
}

- (BOOL)hasNextGroupWithCurrentNewsID:(NSString *)newsID
{
    NSString *nextGroupPicturesNewsID = nil;
    if (_gallerySourceType == GallerySourceTypeGroupPhoto)
    {
        int index = [self.allItems indexOfObject:newsID];
        if (index != NSNotFound && index >= 0 && index < self.allItems.count - 1)
        {
            nextGroupPicturesNewsID = self.allItems[index + 1];
        }
    }
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
    [_footerView updateCommentCount:@"0"];
    [slideShows load:TTURLRequestCachePolicyDefault more:NO];
    [slideShows release];
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

@end