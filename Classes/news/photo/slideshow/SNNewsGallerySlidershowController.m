//
//  SNNewsGallerySlidershowControllerViewController.m
//  sohunews
//
//  Created by qi pei on 5/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNNewsGallerySlidershowController.h"
#import "SDImageCache.h"
#import "SNUtility.h"

@implementation SNNewsGallerySlidershowController
{
    BOOL _isFirst;
}

@synthesize gallery, beginIndex, sliderShowController, delegate, newsId;
@synthesize sdkAdDataLastPic = _sdkAdDataLastPic;

- (id)initWithGallery:(SNPhotoSlideshow *)ds
{
	if (self=[super init])
    {
		self.gallery = ds;
        transitionView = [[SNWebImageView alloc] init];
        transitionView.contentMode = UIViewContentModeScaleAspectFit;
        transitionView.hidden = NO;
        [self.view addSubview:transitionView];
	}
	return self;
}

- (BOOL)showPhotoByIndex:(int)index
                  inView:(UIView *)aView
                  newsId:(NSString *)aNewsId
                    from:(CGRect)rect
{
    
    if (nil == self.gallery || index < 0 || index >= self.gallery.photos.count)
    {
        SNDebugLog(@"invalid index = %d", index);
        return NO;
    }
    
    self.beginIndex = index;
    self.newsId = aNewsId;
    self.view.frame = CGRectMake(0, 0, aView.width, aView.height);
    [aView addSubview:self.view];
    [self showPhotoSlideshow];
    
    _isFirst = YES;
    if (CGRectIsNull(rect))
    {
        alphaAnimate = YES;
        self.view.userInteractionEnabled = NO;
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        [UIView beginAnimations:kFadeInAnimation context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.6];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        sliderShowController.view.alpha = 1;
        [UIView commitAnimations];
    }
    else
    {
        SNPhoto *photo = [self.gallery.photos objectAtIndex:index];
        CGFloat alphaToShow = themeImageAlphaValue();
        transitionView.alpha = alphaToShow;
        transitionView.frame = rect;
        [transitionView loadUrlPath:photo.url];
        self.view.userInteractionEnabled = NO;
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.url];
        
        CGFloat width = 0;
        CGFloat height = 0;
        if (image.size.width != 0 && image.size.height != 0)
        {
            if (image.size.width <= [UIScreen mainScreen].bounds.size.width)
            {
                width = image.size.width;
                height = image.size.height;
            }
            else
            {
                width = [UIScreen mainScreen].bounds.size.width;
                height = image.size.height *[UIScreen mainScreen].bounds.size.width/image.size.width;
            }
        }
        else
        {
            width = [UIScreen mainScreen].bounds.size.width;
            height = transitionView.height *[UIScreen mainScreen].bounds.size.width/transitionView.width;
        }
        
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        sliderShowController.view.alpha = 0;
        [UIView beginAnimations:kFadeInAnimation context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        float y = (height > [UIScreen mainScreen].bounds.size.height) ? 0 :((self.view.height-height)/2);
        transitionView.frame = CGRectMake((self.view.width -width)/2 , y, width, height);
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [UIView commitAnimations];
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

-(void)tipViewRemove:(UIView *)tipView
{
    
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (alphaAnimate)
    {
        self.view.userInteractionEnabled = YES;
        if ([animationID isEqualToString:kFadeInAnimation])
        {
            if (delegate && [delegate respondsToSelector:@selector(sliderShowDidShow)])
            {
                [delegate sliderShowDidShow];
            }
        }
        else
        {
            alphaAnimate = NO;
            sliderShowController.delegate = nil;
            [sliderShowController.view removeFromSuperview];
            
            if (delegate && [delegate respondsToSelector:@selector(sliderShowDidClose)])
            {
                [delegate sliderShowDidClose];
            }
        }
        
    }
    else
    {
        SNPhoto *photo = [self.gallery.photos objectAtIndex:sliderShowController.slideshowIndex];
        if ([photo isKindOfClass:[NSDictionary class]])
        {
            photo = [self.gallery.photos objectAtIndex:sliderShowController.slideshowIndex - 1];
            [self.gallery.photos removeLastObject];
        }
        else
        {
            if (!_isFirst)
            {
                if ([[self.gallery.photos lastObject] isKindOfClass:[NSDictionary class]])
                {
                    [self.gallery.photos removeLastObject];
                }
            }
        }
        if ([animationID isEqualToString:kFadeInAnimation])
        {
            self.view.userInteractionEnabled = YES;
            sliderShowController.view.alpha = 1;
            if ([delegate respondsToSelector:@selector(showImageForUrl:)])
            {
                [delegate showImageForUrl:photo.url];
            }
            
            if (delegate && [delegate respondsToSelector:@selector(sliderShowDidShow)])
            {
                [delegate sliderShowDidShow];
            }
            
        }
        else
        {
            if ([delegate respondsToSelector:@selector(showImageForUrl:)])
            {
                [delegate showImageForUrl:photo.url];
            }
            double delayInSeconds = .15f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                transitionView.hidden = YES;
                sliderShowController.delegate = nil;
                [sliderShowController.view removeFromSuperview];
                
                if (delegate && [delegate respondsToSelector:@selector(sliderShowDidClose)])
                {
                    [delegate sliderShowDidClose];
                }

            });
//            [UIView animateWithDuration:.3 animations:^{
//                transitionView.alpha = 0;
//            } completion:^(BOOL finished) {
//                transitionView.hidden = YES;
//            }];
//            sliderShowController.delegate = nil;
//            [sliderShowController.view removeFromSuperview];
//             //(sliderShowController);
//            
//            if (delegate && [delegate respondsToSelector:@selector(sliderShowDidClose)])
//            {
//                [delegate sliderShowDidClose];
//            }
        }
    }
}

- (void)showPhotoSlideshow
{
    [sliderShowController.view removeFromSuperview];
    sliderShowController = [[SNPicturesSlideshowViewController alloc] initWithSlideshows:self.gallery index:self.beginIndex];
    if (self.sdkAdDataLastPic.dataState == SNAdDataStateReady) {
        if ([self.sdkAdDataLastPic adImage] && self.sdkAdDataLastPic) {
            [self.gallery.photos addObject:@{@"image" : [self.sdkAdDataLastPic adImage], @"adData" : self.sdkAdDataLastPic}];
        }
        
        //进入文章article正文大图模式上报大图最后一帧加载
        [self.sdkAdDataLastPic reportForLoadTrack];
    }
    sliderShowController.delegate = self;
    sliderShowController.view.alpha = 0;
    [self.view addSubview:sliderShowController.view];
}

#pragma - SNPicturesSlideshowViewControllerDelegate methods

-(void)photoViewDidClose
{
    _isFirst = NO;
    SNPhoto *photo = [self.gallery.photos objectAtIndex:sliderShowController.slideshowIndex];
    if ([photo isKindOfClass:[NSDictionary class]])
    {
        photo = [self.gallery.photos objectAtIndex:sliderShowController.slideshowIndex - 1];
    }
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.url];
    if (alphaAnimate || image.size.height == 0 || image.size.width == 0 || image.size.width == NAN|| image.size.height == NAN)
    {
        self.view.userInteractionEnabled = NO;
        [UIView beginAnimations:kFadeOutAnimation context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.3];//TT_TRANSITION_DURATION
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.view.alpha = 0;
        [UIView commitAnimations];
    }
    else
    {
        CGRect rect = CGRectZero;
        if ([delegate respondsToSelector:@selector(rectForImageUrl:)])
        {
            rect = [delegate rectForImageUrl:photo.url];
        }
        if ([delegate respondsToSelector:@selector(hiddenImageForUrl:)])
        {
            [delegate hiddenImageForUrl:photo.url];
        }
        
        CGFloat width = 0;
        CGFloat height = 0;
        
        if (image.size.width <= self.view.width)
        {
            width = image.size.width;
            height = image.size.height;
        }
        else
        {
            width = self.view.width;
            height = image.size.height *self.view.width/image.size.width;
        }
        
        
        transitionView.urlPath = photo.url;
        float y = (height > self.view.height) ? 0 :((self.view.height-height)/2);
        transitionView.frame = CGRectMake((self.view.width-width)/2, y, width, height);
        
        self.view.userInteractionEnabled = NO;
        self.view.backgroundColor = [UIColor clearColor];
        sliderShowController.view.alpha = 0;
        [UIView beginAnimations:kFadeOutAnimation context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        transitionView.frame = rect;
        [UIView commitAnimations];
    }
    
}

- (void)photoViewComment
{
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginAction)])
    {
        [self.delegate performSelector:@selector(textFieldDidBeginAction)];
    }
}

- (void)photoViewWillShare:(int)index
{
    if ([self.delegate respondsToSelector:@selector(sliderShowWillShare:)])
    {
        [self.delegate sliderShowWillShare:index];
    }
}

- (void)photoViewWantShowCommentList
{
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:NO];
    if ([self.delegate respondsToSelector:@selector(sliderShowWantToShowCommentList)])
    {
        [self.delegate sliderShowWantToShowCommentList];
    }
}

- (NSString *)photoViewWantsCommentNumber
{
    if ([self.delegate respondsToSelector:@selector(sliderShowWantsCommentNum)])
    {
        return [self.delegate sliderShowWantsCommentNum];
    }
    return nil;
}

-(void)dealloc
{
    sliderShowController.delegate = nil;
    [sliderShowController.view removeFromSuperview];
    transitionView = nil;
    _sdkAdDataLastPic.delegate = nil;
}


- (void)viewDidUnload
{
    sliderShowController.delegate = nil;
    [sliderShowController.view removeFromSuperview];
    
    [super viewDidUnload];
}
@end
