//
//  SNPicturesSlideshowViewController.m
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPicturesSlideshowViewController.h"
#import "SNSlideshowView.h"
#import "SNSlideshowFooterView.h"
#import "SNSubInfoView.h"
#import "SNDBManager.h"
#import "SNPhotoSlideshow.h"
#import "SNConst+PicturesSlideshowViewController.h"

@interface SNPicturesSlideshowViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *_scrollView;                    //承载多图的容器
    SNSubInfoView *_headerView;                   
    SNSlideshowFooterView *_footerView;
    
    NSMutableArray *_slideShowViews;
    
    id pushReceivedNotificationObserver;
    id downloaderWillShowNotificationObserver;
}

@end

@implementation SNPicturesSlideshowViewController

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow
{
    return [self initWithSlideshows:slideshow index:0];
}

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow index:(int)index
{
    self = [super init];
    if (self)
    {
        _slideshowIndex = index;
        _slideshows = [slideshow retain];
        _slideShowViews = [[NSMutableArray alloc] init];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.f)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"blackStyle"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.view.frame = CGRectMake(0.f, 0.f, kAppScreenWidth, kAppScreenHeight);
    self.view.backgroundColor = [UIColor blackColor];

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-kMultiPicturePadding/2, 0.f, kAppScreenWidth + kMultiPicturePadding, kAppScreenHeight)];
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.delegate = self;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.contentSize = CGSizeMake([_slideshows.photos count] * (kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
    [_scrollView setContentOffset:CGPointMake(_slideshowIndex*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
	[self.view addSubview:_scrollView];
    [_scrollView release];

    [_slideshows.photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         SNSlideshowView *slideshowView = [[SNSlideshowView alloc] initWithFrame:CGRectMake(idx * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight)];
        if ([obj isKindOfClass:[SNPhoto class]])
        {
            slideshowView.picture = obj;
        }
        else if ([obj isKindOfClass:[NSDictionary class]])
        {
            slideshowView.adImage = obj[@"image"];
        }
        
        [_scrollView addSubview:slideshowView];
        [_slideShowViews addObject:slideshowView];
        [slideshowView release];
    }];

    [self displaySlideshowViewAtIndex:_slideshowIndex];
    
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_slideshows.subId];
    if (subObj)
    {
        _headerView = [[SNSubInfoView alloc] initWithSubInfoViewType:SNSubInfoViewTypeGallery];
        _headerView.refer = REFER_GROUPPHOTOLIST;
        _headerView.top = 5 + kSystemBarHeight;
        _headerView.left = 5;
        _headerView.subObj = subObj;
        [self.view addSubview:_headerView];
        [_headerView release];
    }
    
    _footerView = [[SNSlideshowFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, 113.f) pictureInfo:_slideshows.photos[_slideshowIndex]];
    _footerView.bottom = self.view.height;
    __block typeof(&*self) blockSelf = self;
    [_footerView setBackButtonActionBlock:^{
        //返回操作
        [blockSelf closeSNPicturesSlideshowViewController];
    } commentListButtonActionBlock:^{
        //查看评论列表操作
        if (blockSelf->_delegate && [blockSelf->_delegate respondsToSelector:@selector(photoViewWantShowCommentList)])
        {
            [blockSelf->_delegate photoViewWantShowCommentList];
        }
    } commentButtonActionBlock:^{
        //发表评论操作
        if (blockSelf->_delegate && [blockSelf->_delegate respondsToSelector:@selector(photoViewComment)])
        {
            [blockSelf->_delegate performSelector:@selector(photoViewComment)];
        }
    } downloadButtonActionBlock:^{
        //下载图片操作
        UIImage *saveImage = [[blockSelf slideshowViewAtIndex:blockSelf->_slideshowIndex] image];
        UIImageWriteToSavedPhotosAlbum(saveImage, blockSelf,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } shareButtonActionBlock:^{
        //分享操作
        if (blockSelf->_delegate && [blockSelf->_delegate respondsToSelector:@selector(photoViewWillShare:)])
        {
            [blockSelf->_delegate photoViewWillShare:blockSelf->_slideshowIndex];
        }
    } commentCount:[_delegate photoViewWantsCommentNumber]];
    [self.view addSubview:_footerView];
    [_footerView release];
    
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
    
    pushReceivedNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotifyDidReceive object:nil queue:nil usingBlock:^(NSNotification *note) {
        [[NSNotificationCenter defaultCenter] removeObserver:blockSelf->pushReceivedNotificationObserver], blockSelf->pushReceivedNotificationObserver = nil;
        //关闭此页面
        [blockSelf closeSNPicturesSlideshowViewController];
    }];
    downloaderWillShowNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationWillOpenDownloader object:nil queue:nil usingBlock:^(NSNotification *note) {
        [[NSNotificationCenter defaultCenter] removeObserver:blockSelf->downloaderWillShowNotificationObserver], blockSelf->downloaderWillShowNotificationObserver = nil;
        //关闭此页面
        [blockSelf closeSNPicturesSlideshowViewController];
    }];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:pushReceivedNotificationObserver], pushReceivedNotificationObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:downloaderWillShowNotificationObserver], downloaderWillShowNotificationObserver = nil;
}

- (void)closeSNPicturesSlideshowViewController
{
    //关闭此页面
    if (_delegate && [_delegate respondsToSelector:@selector(photoViewDidClose)])
    {
        _scrollView.delegate = nil;
        [_delegate photoViewDidClose];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.f)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"whiteStyle"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
    }
}

//加载当前index的图片
- (void)displaySlideshowViewAtIndex:(int)index
{
    SNSlideshowView *slideshowView = [self slideshowViewAtIndex:index];
    if(slideshowView && !slideshowView.prepared)
    {
        slideshowView.prepared = YES;
        [slideshowView loadImage];
    }
    
    [self prepareNeighborSlideshowViewAtIndex:index];
}

//准备加载当前index的前一张和后一张图片
- (void)prepareNeighborSlideshowViewAtIndex:(int)index
{
    if(index == 0)
    {
        [self willDisplaySlideshowViewAtIndex:index + 1];
    }
    else if(index == [_slideShowViews count] - 1)
    {
        [self willDisplaySlideshowViewAtIndex:index - 1];
    }
    else
    {
        [self willDisplaySlideshowViewAtIndex:index - 1];
        [self willDisplaySlideshowViewAtIndex:index + 1];
    }
}

//加载即将展现的图片，并重新设置image的scale
- (void)willDisplaySlideshowViewAtIndex:(int)index
{
    SNSlideshowView *slideshowView = [self slideshowViewAtIndex:index];
    if(slideshowView && !slideshowView.prepared)
    {
        slideshowView.prepared = YES;
        [slideshowView loadImage];
    }
    
    [slideshowView resetImageScale];
}

//释放不用的image
- (void)willDismissSlideshowViewAtIndex:(int)index
{
    SNSlideshowView *slideshowView = [self slideshowViewAtIndex:index];
    if(slideshowView && slideshowView.prepared)
    {
        [slideshowView prepareForReuse];
        slideshowView.prepared = NO;
    }
}

- (SNSlideshowView *)slideshowViewAtIndex:(int)index
{
    SNSlideshowView *slideshowView = nil;
    if(index >= 0 && index < [_slideShowViews count])
    {
        slideshowView = _slideShowViews[index];
    }
    return slideshowView;
}

- (void)viewDidUnload
{
    [self removeObserver];
    [_slideshows release], _slideshows = nil;
    [_slideShowViews release], _slideShowViews = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeObserver];

    [_slideshows release], _slideshows = nil;
    [_slideShowViews release], _slideShowViews = nil;
    [super dealloc];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    if(index < 0)
    {
        index = 0;
    }
	if(index > [_slideShowViews count] - 1)
    {
        index = [_slideShowViews count] - 1;
    }
    [self prepareNeighborSlideshowViewAtIndex:index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
	_slideshowIndex = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    if ([_slideshows.photos[_slideshowIndex] isKindOfClass:[NSDictionary class]])
    {
        // sdk广告曝光统计
        SNAdDataCarrier *adData = _slideshows.photos[_slideshowIndex][@"adData"];
        [adData reportForDisplayTrack];
        
        [_footerView showAdButtons];
        if (_headerView)
        {
            _headerView.hidden = YES;
        }
    }
    else
    {
        [_footerView showAllButtons];
        if (_headerView)
        {
            _headerView.hidden = NO;
        }
        [_footerView updateAbstract:_slideshows.photos[_slideshowIndex]];
    }
    
    if(_slideshowIndex > 1)
    {
        [self willDismissSlideshowViewAtIndex:_slideshowIndex - 2];
    }
    if(_slideshowIndex < [_slideShowViews count] - 2)
    {
        [self willDismissSlideshowViewAtIndex:_slideshowIndex + 2];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //实现第一张和最后一张图片左右滑动关闭大图的功能
    if (_scrollView.contentOffset.x < 0 || _scrollView.contentOffset.x > (_scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds)))
    {
        [self closeSNPicturesSlideshowViewController];
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
                _headerView.alpha = alpha;
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
        SNSlideshowView *slideshowView = (SNSlideshowView *)_slideShowViews[_slideshowIndex];
        [slideshowView setScrollViewZoom];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[SNSlideshowFooterView class]] || [touch.view isKindOfClass:[SNSubInfoView class]])
    {
        return NO;
    }
    return YES;
}

#pragma mark - UIdownloadimagebutton
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	SNDebugLog(@"照片失败%@", [error localizedDescription]);
	[[SNUtility getApplicationDelegate] image:image didFinishSavingWithError:error contextInfo:contextInfo];
}
@end
