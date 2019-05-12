//
//  SNPhotoGallerySlideshowController.m
//  sohunews
//
//  Created by Dan on 12/16/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//
#define FADE_DURATION       0.2
#define kThumbnailHeight    46

#import "SNPhotoGallerySlideshowController.h"
#import "SNPhoto.h"
#import "SNDBManager.h"
#import "UIImage+MultiFormat.h"

@implementation SNPhotoGallerySlideshowController

@synthesize gallery = _gallery, delegate = _delegate, allItems;
@synthesize currentNewsId, newsModel = _newsModel;

@synthesize myFavouriteReferInSlideShow = _myFavouriteReferInSlideShow;

@synthesize pubDate = _pubDate;

@synthesize termId;

@synthesize gallerySourceType = _gallerySourceType;

- (id)initWithGallery:(SNPhotoSlideshow *)gallery {
	if (self=[super init]) {
		
		self.gallery = gallery;
        _loadFromRecommend = NO;
        self.currentNewsId = self.gallery.newsId;
	}
	return self;
}


- (UIImage *)getCurrentPhotoImage:(int)index
{
    if (index < 0 || index > self.gallery.numberOfPhotos - 1) {
        return nil;
    }
    
    if ([self.gallery hasPrevMoreRecommends] || [self.gallery hasLastPhotoOfPrevGroup]) {
        index -= 1;
    }
    if (index < 0) {
        index = 0;
    }
    // 特殊处理一下广告
    if ([self.gallery hasSdkAdData]) {
        index = MIN(index, self.gallery.photos.count - 1);
    }
    SNPhoto *photo = [self.gallery.photos objectAtIndex:index];
    NSString *urlPath = [photo URLForVersion:TTPhotoVersionLarge];
    //if cached image, load from filesystem directly
    
    UIImage* cache = nil;
    
    if ([urlPath hasPrefix:@"http"]) {
        cache = [[TTURLCache sharedCache] imageForURL:urlPath];
    } else {
        cache = [UIImage sd_imageWithData:[NSData dataWithContentsOfFile:urlPath]];
    }
    if (cache.imageOrientation!=UIImageOrientationUp) {
        cache=[cache transformWidth:cache.size.height height:cache.size.width rotate:NO];
    }
    return cache;
}

- (void)hide
{
    [self.view removeFromSuperview];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(slideshowDidDismiss:)])
    {
        [self.delegate slideshowDidDismiss:self];
    }
}

- (void)hideWithAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hide)];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.view.alpha = 0;
    
    [UIView commitAnimations];
}


- (void)showPhotoSlideshow:(SNPhotoSlideshow *)slideshow
{
    if (_groupPicturesSlideshowContainerViewController)
    {
        [_groupPicturesSlideshowContainerViewController.view removeFromSuperview];
        _index = 0;
    }
    
    self.gallery = slideshow;
    
    self.gallery.galleryLoadType = GalleryLoadTypeNone;
    _groupPicturesSlideshowContainerViewController = [[SNGroupPicturesSlideshowContainerViewController alloc] initWithCurrentSlideshows:slideshow index:_index delegate:self];
    _groupPicturesSlideshowContainerViewController.myFavouriteRefer = _myFavouriteReferInSlideShow;
    _groupPicturesSlideshowContainerViewController.allItems = self.allItems;
    _groupPicturesSlideshowContainerViewController.gallerySourceType = _gallerySourceType;
    _groupPicturesSlideshowContainerViewController.termId = self.termId;
    [self.view addSubview:_groupPicturesSlideshowContainerViewController.view];
    _groupPicturesSlideshowContainerViewController.view.top = 0.f;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowDidShow:)])
    {
        [self.delegate slideshowDidShow:self];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:kFadeInAnimation])
    {
		self.view.userInteractionEnabled = YES;
        [_containerView removeFromSuperview];
        [self showPhotoSlideshow:self.gallery];
	}
    else
    {
        [self hide];
	}
}

- (void)dismissAnimated:(BOOL)animated
{
    if (self.view)
    {
		if (animated)
        {
            if ([_groupPicturesSlideshowContainerViewController isRecommendViewOrAdView])
            {
                [self hideWithAnimation];
                return;
            }
            
            UIImage *originalImage = [_groupPicturesSlideshowContainerViewController currentImage];
            if (!originalImage)
            {
                [self hideWithAnimation];
                return;
            }
            
            CGFloat width = 0;
            CGFloat height = 0;
            if (originalImage.size.width != 0 && originalImage.size.height != 0)
            {
                if (originalImage.size.width <= [UIScreen mainScreen].bounds.size.width)
                {
                    width = originalImage.size.width;
                    height = originalImage.size.height;
                }
                else
                {
                    width = [UIScreen mainScreen].bounds.size.width;
                    height = originalImage.size.height *[UIScreen mainScreen].bounds.size.width/originalImage.size.width;
                }
                
            }
            
            float y = (height > [UIScreen mainScreen].bounds.size.height) ? 0 :((self.view.height-height)/2);
            _stageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TTScreenBounds().size.width, TTScreenBounds().size.height)];
            _stageView.clipsToBounds = YES;
            [self.view addSubview:_stageView];
            [_stageView release];
            
            
            UIImageView *currentImgView = [[UIImageView alloc] initWithImage:originalImage];
            NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
            currentImgView.alpha = [alpha floatValue];
            [_containerView release];
            _containerView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width -width)/2 , y, width, height)];
            [currentImgView setFrame:CGRectMake(0.f , 0.f, width, height)];
            
            [_containerView addSubview:currentImgView];
            [currentImgView release];
            _containerView.clipsToBounds = YES;
            [_stageView addSubview:_containerView];
            [_groupPicturesSlideshowContainerViewController.view removeFromSuperview];
            
			self.view.userInteractionEnabled = NO;
			[UIView beginAnimations:kFadeOutAnimation context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			
			[UIView setAnimationDuration:TT_TRANSITION_DURATION];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			
			self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            
            _index = [_groupPicturesSlideshowContainerViewController currentSlideshowIndex];
            if ([self.gallery hasPrevMoreRecommends] || [self.gallery hasLastPhotoOfPrevGroup])
            {
                _index -= 1;
            }
            CGRect rect = [self.delegate slideshowPhotoFrameShouldReturn:self photoIndex:_index];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowPhotoFrameShouldReturn:photoIndex:)])
            {
                if (CGRectEqualToRect(rect, CGRectZero))
                {
                    [_containerView setFrame:_initImgRect];
                }
                else
                {
                    [_containerView setFrame:rect];
                }
            }
            else
            {
                [_containerView setFrame:_initImgRect];
            }
            
            SNPhotoSlideshow *currentSlideshow = _groupPicturesSlideshowContainerViewController.currentSlideshows;
            PhotoItem *currentPhoto = currentSlideshow.photoList.gallerySubItems[_groupPicturesSlideshowContainerViewController.currentSlideshowIndex];
            if (currentPhoto.height == 0 || currentPhoto.width == 0)
            {
                CGRect frameFitScreen = [SNUtility calculateFrameToFitScreenBySize:originalImage.size
                                                                       defaultSize:CGSizeMake(kAppScreenWidth, kAppScreenHeight)];
                CGRect overflowRect   = [originalImage getOverflowRectByFillingRect:frameFitScreen byAnimation:kFadeOutAnimation];
                [currentImgView setFrame:CGRectMake(-kImageLeftMargin, overflowRect.origin.y, overflowRect.size.width, overflowRect.size.height)];
            }
            else
            {
                [currentImgView setFrame:CGRectMake(0.f, 0.f, _containerView.frame.size.width, _containerView.frame.size.height)];
            }
            
			[UIView commitAnimations];
            
		}
        else
        {
			[self.view removeFromSuperview];
			self.view = nil;
		}
	}
}

- (void)closeAction
{
    [self dismissAnimated:YES];
}

- (void)onSlideshowLoaded:(SNPhotoSlideshow *)slideshow
{
    self.gallery = slideshow;
    
    if (firstTime)
    {
        firstTime = NO;
        if ([self.gallery hasPrevMoreRecommends] || [self.gallery hasLastPhotoOfPrevGroup])
        {
            _index += 1;
        }
    }
    else if (_galleryTargetType != GalleryTargetTypeToPrev && ([self.gallery hasPrevMoreRecommends] || [self.gallery hasLastPhotoOfPrevGroup]))
    {
        _index = 1;
    }
    else if  (_galleryTargetType == GalleryTargetTypeToPrev)
    {
        if ([self.gallery hasFirstPhotoOfNextGroup])
        {
            _index = self.gallery.numberOfPhotos - 2;
        }
        else
        {
            _index = self.gallery.numberOfPhotos - 1;
        }
    }
    
    if (_loadFromRecommend && _delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:galleryId:)])
    {
        _loadFromRecommend = NO;
        [_delegate slideshowDidChange:self galleryId:slideshow.newsId];
    }
    else if (_loadFromAdjacentNews && _delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:termId:newsId:)])
    {
        _loadFromAdjacentNews = NO;
        [_delegate slideshowDidChange:self termId:slideshow.termId newsId:slideshow.newsId];
    }
    
    if (self.gallery.channelId && ![self.gallery.termId isEqualToString:kDftSingleGalleryTermId])
    {
        [self.newsModel setNewsAsRead:self.gallery.newsId];
    } 

}

#pragma mark SNGroupPicturesSlideshowViewControllerDelegate
- (void)photoDidMoveToIndex:(int)index
{
    if (_delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:photoIndex:)])
    {
        [_delegate slideshowDidChange:self photoIndex:index];
    }
}

- (void)photoViewDidClose
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowWillDismiss:)])
    {
        [self.delegate slideshowWillDismiss:self];
    }
    [self dismissAnimated:YES];
}


- (void)photoModelDidFinishLoad:(SNPhotoSlideshow *)slideshow
{
    [self performSelectorOnMainThread:@selector(onSlideshowLoaded:) withObject:slideshow waitUntilDone:NO];
}

- (void)photoModelDidFailed:(SNPhotoSlideshow *)slideshow;
{
//    self.gallery = slideshow;
//    
//    self.gallery.firstPhotoOfNextGroup = nil;
//    self.gallery.prevMoreRecommends = nil;
//    self.gallery.lastPhotoOfPrevGroup = nil;
////    [self.photoViewController reloadData];
//    [self.photoViewController jumpViewAtIndex:0];
}

- (void)reloadGallery
{
    if (_gallerySourceType == GallerySourceTypeGroupPhoto || _gallerySourceType == GallerySourceTypeNewsPaper)
    {
        [self openSlideshowAtNewsId:self.currentNewsId];
    }
}

#pragma mark public method
- (BOOL)showPhotoByIndex:(int)index fromRect:(CGRect)initRect inView:(UIView *)aView animated:(BOOL)animated
{
    firstTime = YES;
    
    if (nil == self.gallery || index < 0 || index >= self.gallery.photos.count)
    {
        SNDebugLog(@"invalid index = %d", index);
        return NO;
    }
    
    _index = index;
    
    UIImage *originalImage = [self getCurrentPhotoImage:index];
    
    if (!originalImage) {
        SNDebugLog(@"no image cache = %d", index);
        return NO;
    }
    
    self.view.top = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowWillShow:)])
    {
        [self.delegate slideshowWillShow:self];
    }
    
    _initImgRect = initRect;
    _containerView = [[UIView alloc] initWithFrame:_initImgRect];
    
    UIImageView *currentImgView = [[UIImageView alloc] initWithImage:originalImage];
    currentImgView.frame = CGRectMake(0.f, 0.f, _initImgRect.size.width, _initImgRect.size.height);
    NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
    currentImgView.alpha = [alpha floatValue];
    [_containerView addSubview:currentImgView];
    [currentImgView release];
    _containerView.clipsToBounds = YES;//用来遮挡溢出的部分
    
    [self.view addSubview:_containerView];
    [aView addSubview:self.view];
    
    CGFloat width = 0;
    CGFloat height = 0;
    if (originalImage.size.width != 0 && originalImage.size.height != 0)
    {
        if (originalImage.size.width <= [UIScreen mainScreen].bounds.size.width)
        {
            width = originalImage.size.width;
            height = originalImage.size.height;
        }
        else
        {
            width = [UIScreen mainScreen].bounds.size.width;
            height = originalImage.size.height *[UIScreen mainScreen].bounds.size.width/originalImage.size.width;
        }
        
    }
    else
    {
        if (_containerView.width <= [UIScreen mainScreen].bounds.size.width)
        {
            width = _containerView.width;
            height = _containerView.height;
        }
        else
        {
            width = [UIScreen mainScreen].bounds.size.width;
            height = _containerView.height *[UIScreen mainScreen].bounds.size.width/_containerView.width;
        }
        
    }

    float y = (height > [UIScreen mainScreen].bounds.size.height) ? 0 :((self.view.height-height)/2);
	if (animated)
    {
		self.view.userInteractionEnabled = NO;
		self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
		[UIView beginAnimations:kFadeInAnimation context:nil];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDuration:TT_TRANSITION_DURATION];//
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];

        [currentImgView setFrame:CGRectMake(0.f , 0.f, width, height)];
        
        [_containerView setFrame:CGRectMake((self.view.width -width)/2 , y, width, height)];
        
		[UIView commitAnimations];
	}
    else
    {
        [currentImgView setFrame:CGRectMake(0.f , 0.f, width, height)];
        [_containerView setFrame:CGRectMake((self.view.width -width)/2 , y, width, height)];
		self.view.userInteractionEnabled = YES;
	}
    return YES;
}

- (void)handleNewsNotification
{
    SNDebugLog(@"handleNewsNotification, hideWithAnimation");
    [self hideWithAnimation];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    //查看推送新闻时退出此看图模式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewsNotification) name:kNotifyDidReceive object:nil];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyDidReceive object:nil];

    _groupPicturesSlideshowContainerViewController.delegate = nil;
    [_groupPicturesSlideshowContainerViewController release], _groupPicturesSlideshowContainerViewController = nil;
    TT_RELEASE_SAFELY(_containerView);

    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _groupPicturesSlideshowContainerViewController.delegate = nil;
    [_groupPicturesSlideshowContainerViewController release], _groupPicturesSlideshowContainerViewController = nil;
    TT_RELEASE_SAFELY(_containerView);
    TT_RELEASE_SAFELY(_gallery);
    TT_RELEASE_SAFELY(currentNewsId);
    TT_RELEASE_SAFELY(allItems);
    TT_RELEASE_SAFELY(_newsModel);
    TT_RELEASE_SAFELY(_pubDate);
    TT_RELEASE_SAFELY(termId);

	[super dealloc];
}

- (void)openSlideshowAtNewsId:(NSString *)newsId
{
    if (!newsId)
    {
        return;
    }
    _galleryTargetType = GalleryTargetTypeNone;
    
    self.currentNewsId = newsId;
    
    SNPhotoSlideshow *slideshow = [[[SNPhotoSlideshow alloc] initWithTermId:self.termId newsId:newsId channelId:self.gallery.channelId isOnlineMode:self.gallery.isOnlineMode] autorelease];
    slideshow.typeId = self.gallery.typeId;
    slideshow.type = self.gallery.type;
    
    _loadFromRecommend = NO;
    
    [self showPhotoSlideshow:slideshow];
}

- (void)slideshowDidChangeWithGalleryId:(NSString *)gid
{
    if (_delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:galleryId:)])
    {
        [_delegate slideshowDidChange:self galleryId:gid];
    }
}
- (void)slideshowDidChangeWithTermId:(NSString *)thetermId newsId:(NSString *)newsId
{
    if (_delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:termId:newsId:)])
    {
        [_delegate slideshowDidChange:self termId:thetermId newsId:newsId];
    }
}

@end
