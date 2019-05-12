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
    //修改 _4.3.2_组图：清除缓存后，组图新闻图片不能进入组图大图
    if ([SNAPI isWebURL:urlPath] && [[TTURLCache sharedCache] imageForURL:urlPath]) {
        cache = [[TTURLCache sharedCache] imageForURL:urlPath];
    }
    else if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath]) {
        cache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath];
    }
    else {
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

- (void)refreshStatusbar
{
    if (_groupPicturesSlideshowContainerViewController && [_groupPicturesSlideshowContainerViewController respondsToSelector:@selector(refreshStatusbar)])
    {
        [_groupPicturesSlideshowContainerViewController refreshStatusbar];
    }
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
    _groupPicturesSlideshowContainerViewController.supportContinuousReadingNext = self.supportContinuousReadingNext;
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
            
            
            UIImageView *currentImgView = [[UIImageView alloc] initWithImage:originalImage];
            currentImgView.alpha = themeImageAlphaValue();
            _containerView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width -width)/2 , y, width, height)];
            [currentImgView setFrame:CGRectMake(0.f , 0.f, width, height)];
            
            _containerView.backgroundColor = [UIColor blackColor];
            [_containerView addSubview:currentImgView];
            _containerView.clipsToBounds = YES;
            [_stageView addSubview:_containerView];
            [_groupPicturesSlideshowContainerViewController.view removeFromSuperview];
            
            _index = [_groupPicturesSlideshowContainerViewController currentSlideshowIndex];
            if ([self.gallery hasPrevMoreRecommends] || [self.gallery hasLastPhotoOfPrevGroup])
            {
                _index -= 1;
            }
            CGRect rect = [self.delegate slideshowPhotoFrameShouldReturn:self photoIndex:_index];
            
			self.view.userInteractionEnabled = NO;
			[UIView beginAnimations:kFadeOutAnimation context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			
			[UIView setAnimationDuration:TT_TRANSITION_DURATION];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			self.view.backgroundColor = [UIColor clearColor];
            
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
            
//            SNPhotoSlideshow *currentSlideshow = _groupPicturesSlideshowContainerViewController.currentSlideshows;
//            PhotoItem *currentPhoto = currentSlideshow.photoList.gallerySubItems[_groupPicturesSlideshowContainerViewController.currentSlideshowIndex];
//            if (currentPhoto.height == 0 || currentPhoto.width == 0)
//            {
//                CGRect frameFitScreen = [SNUtility calculateFrameToFitScreenBySize:originalImage.size
//                                                                       defaultSize:CGSizeMake(kAppScreenWidth, kAppScreenHeight)];
//                CGRect overflowRect   = [originalImage getOverflowRectByFillingRect:frameFitScreen byAnimation:kFadeOutAnimation];
//                [currentImgView setFrame:CGRectMake(-kImageLeftMargin, overflowRect.origin.y, overflowRect.size.width, overflowRect.size.height)];
//            }
//            else
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
    else if (_loadFromAdjacentNews && _delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:termId:newsId:slideToNextGroup:)])
    {
        _loadFromAdjacentNews = NO;
        [_delegate slideshowDidChange:self termId:slideshow.termId newsId:slideshow.newsId slideToNextGroup:NO];
    }
    
    if (self.gallery.channelId && ![self.gallery.termId isEqualToString:kDftSingleGalleryTermId])
    {
        [self.newsModel setNewsAsRead:self.gallery.newsId];
    } 

}

#pragma mark SNGroupPicturesSlideshowViewControllerDelegate
- (void)photoDidMoveToIndex:(NSInteger)index
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

    if (!originalImage) {//三端正文h5化，拿不到缓存直接下载图片
        SNPhoto *photo = [self.gallery.photos objectAtIndex:index];
        NSString *urlPath = [photo URLForVersion:TTPhotoVersionLarge];
        //if cached image, load from filesystem directly
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:urlPath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:urlPath toDisk:YES];
            [self renderPhotoByIndex:index fromRect:initRect inView:aView animated:animated image:image];
            
        }];
        
    }else {
        //2017-02-08 wangchuanwen 下滑退出图集弹框提示 update begin
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if (![userDefault objectForKey:@"gallerySlidePicsCount"] || [[userDefault objectForKey:@"gallerySlidePicsCount"] isEqualToString:@"0"]) {
            
            [self addTipView];
            [userDefault setObject:@"1" forKey:@"gallerySlidePicsCount"];
            
        }
        //2017-02-08 wangchuanwen update end
        
        return [self renderPhotoByIndex:index fromRect:initRect inView:aView animated:animated image:originalImage];
    }

    //2017-02-08 wangchuanwen 下滑退出图集弹框提示 update begin
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (![userDefault objectForKey:@"gallerySlidePicsCount"] || [[userDefault objectForKey:@"gallerySlidePicsCount"] isEqualToString:@"0"]) {
        
        [self addTipView];
        [userDefault setObject:@"1" forKey:@"gallerySlidePicsCount"];
        
    }
    //2017-02-08 wangchuanwen update end
    
    return YES;
}

-(void)addTipView
{
    UIImageView *tipImageView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    tipImageView.image = [[UIImage imageNamed:@"icoprompt_bg_v5.9.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(1, 4, 1, 2) resizingMode:UIImageResizingModeStretch];
    tipImageView.userInteractionEnabled = YES;
    [SNUtility getApplicationDelegate].window.windowLevel = UIWindowLevelStatusBar;
    [[SNUtility getApplicationDelegate].window addSubview:tipImageView];
    
    UIImage *picsImage = [UIImage imageNamed:@"icoprompt_arrows_v5.png"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((tipImageView.width - picsImage.size.width - 16)/2.0, -(picsImage.size.height), picsImage.size.width+16, picsImage.size.height)];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"下滑退出图集" forState:UIControlStateNormal];
    [button setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;//换行模式自动换行
    button.titleLabel.numberOfLines = 0;
    [button setImage:picsImage forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
    [tipImageView addSubview:button];
    [UIView animateWithDuration:0.6 animations:^{
        button.frame = CGRectMake((tipImageView.width - picsImage.size.width - 16)/2.0, 0, picsImage.size.width+16, picsImage.size.height);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2 animations:^{
            button.frame = CGRectMake((tipImageView.width - picsImage.size.width - 16)/2.0, -(picsImage.size.height), picsImage.size.width+16, picsImage.size.height);
            tipImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [SNUtility getApplicationDelegate].window.windowLevel = 0;
            [tipImageView removeFromSuperview];
        }];
    }];
}

- (BOOL)renderPhotoByIndex:(int)index fromRect:(CGRect)initRect inView:(UIView *)aView animated:(BOOL)animated image:(UIImage *)originalImage
{
    self.view.top = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowWillShow:)])
    {
        [self.delegate slideshowWillShow:self];
    }
    
    _initImgRect = initRect;
    _containerView = [[UIView alloc] initWithFrame:_initImgRect];
    
    UIImageView *currentImgView = [[UIImageView alloc] initWithImage:originalImage];
    currentImgView.frame = CGRectMake(0.f, 0.f, _initImgRect.size.width, _initImgRect.size.height);
    currentImgView.alpha = themeImageAlphaValue();
    _containerView.backgroundColor = [UIColor blackColor];
    [_containerView addSubview:currentImgView];
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
        self.view.backgroundColor = [UIColor clearColor];
        
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
    [SNNotificationManager addObserver:self selector:@selector(handleNewsNotification) name:kNotifyDidReceive object:nil];
    
}

- (void)viewDidUnload
{
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];

    _groupPicturesSlideshowContainerViewController.delegate = nil;
    _groupPicturesSlideshowContainerViewController = nil;

    [super viewDidUnload];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    _groupPicturesSlideshowContainerViewController.delegate = nil;
    _groupPicturesSlideshowContainerViewController = nil;

}

- (void)openSlideshowAtNewsId:(NSString *)newsId
{
    if (!newsId)
    {
        return;
    }
    _galleryTargetType = GalleryTargetTypeNone;
    
    self.currentNewsId = newsId;
    
    SNPhotoSlideshow *slideshow = [[SNPhotoSlideshow alloc] initWithTermId:self.termId newsId:newsId channelId:self.gallery.channelId isOnlineMode:self.gallery.isOnlineMode];
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
- (void)slideshowDidChangeWithTermId:(NSString *)thetermId newsId:(NSString *)newsId slideToNextGroup:(BOOL)isNextGroup
{
    if (_delegate && [_delegate respondsToSelector:@selector(slideshowDidChange:termId:newsId:slideToNextGroup:)])
    {
        [_delegate slideshowDidChange:self termId:thetermId newsId:newsId slideToNextGroup:isNextGroup];
    }
}

- (void)slideshowDidTapRetry
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowDidTapRetry)]) {
        [self.delegate slideshowDidTapRetry];
    }
}

- (void)refreshAd:(SNAdDataCarrier *)ad12238 ad13371:(SNAdDataCarrier *)ad13371 ad12233:(SNAdDataCarrier *)ad12233
{
    if (nil != _groupPicturesSlideshowContainerViewController)
    {
        [_groupPicturesSlideshowContainerViewController refreshAd:ad12238 ad13371:ad13371 ad12233:ad12233];
    }
}

@end
