//
//  SNPhotoGalleryPlainSlideshowController.m
//  sohunews
//
//  Created by Cong Dan on 5/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDBManager.h"
#import "SNPhotoGalleryPlainSlideshowController.h"
#import "SNRollingNewsTableController.h"
#import <Three20UICommon/SNNavigationController.h>

@implementation SNPhotoGalleryPlainSlideshowController

@synthesize delegateController;
@synthesize gallery = _gallery, allItems;
@synthesize currentNewsId;
@synthesize queryDic = _queryDic;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        
        self.hidesBottomBarWhenPushed = YES;
        
        self.termId = [query objectForKey:kTermId];
        NSString *channelId = [query objectForKey:kChannelId];
        NSString *onlineMode  = [query objectForKey:kNewsMode];
        _isOnlineMode = [onlineMode isEqualToString:kNewsOnline];
        self.currentNewsId = [query objectForKey:kNewsId];
        self.allItems = [query objectForKey:kNewsList];
        self.delegateController = [query objectForKey:kController];
        NSNumber *sourceTypeNumber = [query objectForKey:kGallerySourceType];
        _gallerySourceType = [sourceTypeNumber intValue];
        
        NSString *__myFavouriteRefer = [query objectForKey:kMyFavouriteRefer];
        
        _myFavouriteRefer = (!!__myFavouriteRefer && ![@"" isEqualToString:__myFavouriteRefer]) ? [__myFavouriteRefer intValue] : MYFAVOURITE_REFER_NONE;
        
        _pubDate = [[query objectForKey:kPubDate] retain];
        SNDebugLog(@"termId=%@ channelId=%@ newsId=%@ newsList=%d", _termId, channelId, self.currentNewsId, self.allItems.count);
        
        if (!_termId && !channelId) {
            self.termId = kDftGroupGalleryTermId;
        }
        SNPhotoSlideshow *slideshow = [[[SNPhotoSlideshow alloc] initWithTermId:self.termId newsId:self.currentNewsId channelId:channelId isOnlineMode:_isOnlineMode] autorelease];
        
        SNDebugLog(@"INFO: slideshow mode is [%@]", slideshow);
        
        slideshow.type = [query objectForKey:kType];
        slideshow.typeId = [query objectForKey:kTypeId];
        _loadFromRecommend = NO;
        _firstTimeFinishLoad = YES;
        [self showPhotoSlideshow:slideshow isPreLoad:NO];
        
        if (!_logo) {
            _logo = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"app_logo_gray.png"] scaledImage]];
            _logo.center = self.view.center;
            _logo.top = self.view.center.y - 44 + 6;
            //[self.view addSubview:_logo];
        }
        //[self.view bringSubviewToFront:_logo];
        _logo.hidden = NO;
        
        self.queryDic = query;
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return article_full_pic;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.gallery && _isViewReleased) {
        [self showPhotoSlideshow:self.gallery isPreLoad:NO];
    }
    self.view.backgroundColor = [UIColor blackColor];//防止内存低时view透明，看到桌面。。。
    _isViewReleased = NO;
}

- (void)viewDidUnload
{
    TT_RELEASE_SAFELY(_logo);

    _groupPicturesSlideshowContainerViewController.delegate = nil;
    [_groupPicturesSlideshowContainerViewController release], _groupPicturesSlideshowContainerViewController = nil;
    _isViewReleased = YES;
    [super viewDidUnload];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (recommendIds) {
        TT_RELEASE_SAFELY(recommendIds);
    }
    
    if (_pubDate) {
        TT_RELEASE_SAFELY(_pubDate);
    }
    
    TT_RELEASE_SAFELY(_logo);
    _groupPicturesSlideshowContainerViewController.delegate = nil;
    [_groupPicturesSlideshowContainerViewController release], _groupPicturesSlideshowContainerViewController = nil;
    TT_RELEASE_SAFELY(_gallery);
    TT_RELEASE_SAFELY(currentNewsId);
    TT_RELEASE_SAFELY(allItems);
    TT_RELEASE_SAFELY(_termId);
    
	[super dealloc];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

#pragma mark SNGroupPicturesSlideshowViewControllerDelegate
- (void)photoViewDidClose
{
    [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:YES]; 
}

- (void)slideshowDidShow
{
    [_groupPicturesSlideshowContainerViewController.view removeFromSuperview];
    _index = 0;
    self.gallery.galleryLoadType = GalleryLoadTypeNone;

    _groupPicturesSlideshowContainerViewController = [[SNGroupPicturesSlideshowContainerViewController alloc] initWithCurrentSlideshows:self.gallery index:_index delegate:self];
    self.groupPicturesSlideshowContainerViewController.myFavouriteRefer = _myFavouriteRefer;
    self.groupPicturesSlideshowContainerViewController.allItems = self.allItems;
    self.groupPicturesSlideshowContainerViewController.gallerySourceType = _gallerySourceType;
    self.groupPicturesSlideshowContainerViewController.termId = self.termId;
    [self.view addSubview:self.groupPicturesSlideshowContainerViewController.view];
    self.groupPicturesSlideshowContainerViewController.view.top = 0.f;
    self.groupPicturesSlideshowContainerViewController.view.alpha = 1;
}

- (void)showPhotoSlideshow:(SNPhotoSlideshow *)slideshow
                 isPreLoad:(BOOL)isPreLoad
{
    self.gallery = slideshow;
    
    if (self.groupPicturesSlideshowContainerViewController)
    {
        if (isPreLoad)
        {
            [self slideshowDidShow];
        }
        else
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(slideshowDidShow)];
            [UIView setAnimationDuration:TT_TRANSITION_DURATION];
            
            self.groupPicturesSlideshowContainerViewController.view.alpha = 0;
            
            [UIView commitAnimations];
        }
    }
    else
    {
        self.gallery.galleryLoadType = GalleryLoadTypeNone;
        _groupPicturesSlideshowContainerViewController = [[SNGroupPicturesSlideshowContainerViewController alloc] initWithCurrentSlideshows:self.gallery index:_index delegate:self];
        self.groupPicturesSlideshowContainerViewController.myFavouriteRefer = _myFavouriteRefer;
        self.groupPicturesSlideshowContainerViewController.allItems = self.allItems;
        self.groupPicturesSlideshowContainerViewController.gallerySourceType = _gallerySourceType;
        self.groupPicturesSlideshowContainerViewController.termId = self.termId;
        [self.view addSubview:self.groupPicturesSlideshowContainerViewController.view];
        self.groupPicturesSlideshowContainerViewController.view.top = 0.f;
    }
}

- (void)photoModelDidFailed:(SNPhotoSlideshow *)slideshow;
{
    _logo.hidden = YES;
    
    self.gallery = slideshow;
    self.gallery.firstPhotoOfNextGroup = nil;
    self.gallery.prevMoreRecommends = nil;
    self.gallery.lastPhotoOfPrevGroup = nil;
}

- (void)onSlideshowLoaded:(SNPhotoSlideshow *)slideshow
{
    _logo.hidden = YES;
    self.gallery = slideshow;
    
    if (_galleryTargetType != GalleryTargetTypeToPrev && ([self.gallery hasPrevMoreRecommends] || [self.gallery hasLastPhotoOfPrevGroup])) {
        _index = 1;
    } else if  (_galleryTargetType == GalleryTargetTypeToPrev) {
        if ([self.gallery hasFirstPhotoOfNextGroup]) {
            _index = self.gallery.numberOfPhotos - 2;
        } else {
            _index = self.gallery.numberOfPhotos - 1;
        }
    }
    
    //更新数据库
    if (self.gallery.type && self.gallery.typeId && [self.gallery.termId isEqualToString:kDftSingleGalleryTermId])
        [[SNDBManager currentDataBase] markPhotoItemAsReadByTypeId:self.gallery.typeId newsId:self.gallery.newsId type:self.gallery.type];
    //更新内存
    if (self.gallery.newsId && self.gallery.typeId && self.gallery.type && [self.gallery.termId isEqualToString:kDftSingleGalleryTermId]) {
        if (self.delegateController && [self.delegateController respondsToSelector:@selector(updatePhotoNewsReadStyle:)]) {
            if ([self.delegateController isKindOfClass:[SNPhotosTableController class]]) {
                SNPhotosTableController *photoController = (SNPhotosTableController *)self.delegateController;
                if (!photoController.isViewReleased) {
                    [self.delegateController updatePhotoNewsReadStyle:self.gallery.newsId];
                }
            } if ([self.delegateController isKindOfClass:[SNRollingNewsTableController class]]) {
                SNRollingNewsTableController *rollingNewsController = (SNRollingNewsTableController *)self.delegateController;
                if (!rollingNewsController.isViewReleased) {
                    [self.delegateController updatePhotoNewsReadStyle:self.gallery.newsId];
                }
            }
        }
    }
}

- (void)photoModelDidFinishLoad:(SNPhotoSlideshow *)slideshow
{
    [self performSelectorOnMainThread:@selector(onSlideshowLoaded:) withObject:slideshow waitUntilDone:NO];
    
    //没有缓存进入，提供加载预读的机会
    if (_gallerySourceType == GallerySourceTypeNewsPaper) {
    }
}

- (void)openSlideshowAtNewsId:(NSString *)newsId
{
    if (!newsId) {
        return;
    }
    _galleryTargetType = GalleryTargetTypeNone;
    
    self.currentNewsId = newsId;
    
    SNPhotoSlideshow *slideshow = [[[SNPhotoSlideshow alloc] initWithTermId:self.termId newsId:newsId channelId:self.gallery.channelId isOnlineMode:_isOnlineMode] autorelease];
    slideshow.typeId = self.gallery.typeId;
    slideshow.type = self.gallery.type;
    
    _loadFromRecommend = NO;
    
    [self showPhotoSlideshow:slideshow isPreLoad:NO];
}

#pragma mark - SNNavigationController
- (BOOL)needPanGesture
{
    return NO;
}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    return NO;
}


@end
