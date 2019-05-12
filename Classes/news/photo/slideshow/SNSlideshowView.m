//
//  SNSlideshowView.m
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSlideshowView.h"
#import "SNPhoto.h"
#import "UIImageView+WebCache.h"
#import "SNEmbededActivityIndicator.h"
#import "SNWaitingActivityView.h"
#import "SNNewAlertView.h"
#import "SNActionMenuController.h"
#import "SNNewsShareManager.h"

@interface SNSlideshowView ()<UIScrollViewDelegate, SNEmbededActivityIndicatorDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIImageView *_placeholderImageView;
    SNWaitingActivityView *_loadingActivityIndicatorView;
    SNTripletsLoadingView *_embededActivityIndicator;
    UILabel *_adLabel;
    BOOL isBeginZoom;//是否开始放大
}
@property (nonatomic, strong) SNActionMenuController* actionMenuController;
@property (nonatomic, strong) SNNewsShareManager* shareManager;
@property (nonatomic, strong) SNNewAlertView *longPressAlert;
@property (nonatomic, copy) NSString *longPressUrl;
@property (nonatomic, assign) CGPoint prePoint;//用于判断是上滑还是下滑
@end

@implementation SNSlideshowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.minimumZoomScale = .9f;
        _scrollView.maximumZoomScale = 3.5f;
        _scrollView.bouncesZoom = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        UIImage *placeholderImage = [UIImage themeImageNamed:@"app_logo_gray.png"];
        _placeholderImageView = [[UIImageView alloc] initWithImage:placeholderImage];
        _placeholderImageView.frame = CGRectMake((kAppScreenWidth - placeholderImage.size.width)/2, (kAppScreenHeight - placeholderImage.size.height)/2, placeholderImage.size.width, placeholderImage.size.height);
        [self addSubview:_placeholderImageView];
        _placeholderImageView.hidden = NO;
        
        _loadingActivityIndicatorView = [[SNWaitingActivityView alloc] initWithFrame:CGRectMake((kAppScreenWidth - 40.f)/2, _placeholderImageView.centerY + 40.f, 40.f, 40.f)];
        _loadingActivityIndicatorView.centerX = _placeholderImageView.centerX;
        
        [self addSubview:_loadingActivityIndicatorView];
        if (![SNUtility getApplicationDelegate].isNetworkReachable)
        {
            _loadingActivityIndicatorView.hidden = YES;
        }
        else
        {
            _loadingActivityIndicatorView.hidden = NO;
            [_loadingActivityIndicatorView startAnimating];
        }
        
        _imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        _imageView.multipleTouchEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.alpha = 0.f;
        [_scrollView addSubview:_imageView];
        _imageView.userInteractionEnabled =YES;
        
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturePress:)];
        [_imageView addGestureRecognizer:longPress];
        
        _adLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 18)];
        _adLabel.top = 14 + kSystemBarHeight;
        _adLabel.right = kAppScreenWidth - 14;
        _adLabel.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4].CGColor;
        _adLabel.layer.borderWidth = [[SNDevice sharedInstance] isPlus] ? 1.0/3 : 1.0/2;
        _adLabel.layer.cornerRadius =[[SNDevice sharedInstance] isPlus] ? 2.0/3 : 2.0/2;
        _adLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.05];
        _adLabel.textAlignment = NSTextAlignmentCenter;
        _adLabel.font = [UIFont systemFontOfSize:kThemeFontSizeH];
        _adLabel.textColor = SNUICOLOR(kThemeText5Color);
        _adLabel.alpha = 0.f;
        [_scrollView addSubview:_adLabel];
        
        _embededActivityIndicator = [[SNTripletsLoadingView alloc] initWithFrame:self.bounds];
        _embededActivityIndicator.delegate = self;
        _embededActivityIndicator.status = SNTripletsLoadingStatusStopped;
        _embededActivityIndicator.top = kSystemBarHeight;
        [self addSubview:_embededActivityIndicator];
    }
    return self;
}

- (void)longGesturePress:(UIGestureRecognizer*)gesture{
    if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer* press = (UILongPressGestureRecognizer*)gesture;
        if ([press.view isKindOfClass:[UIImageView class]]) {
            NSString* url = self.picture.url;
            if (gesture.state == UIGestureRecognizerStateBegan) {//开始的时候弹起
                [self longPress:url];
            }
            else if (gesture.state == UIGestureRecognizerStateEnded) { //要判断状态...
            }
        }
    }
}

- (void)longPress:(NSString*)url{
    //wangshun 长按大图
    self.longPressUrl = url;
    self.longPressAlert = [[SNNewAlertView alloc] initWithContentView:[self createLongPressView] cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    [self.longPressAlert show];
}

- (UIView *)createLongPressView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 90 + 8.0f * 2)];
    bgView.backgroundColor = [UIColor clearColor];
    UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [topBtn setTitle:@"分享" forState:UIControlStateNormal];
    [topBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    topBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    topBtn.backgroundColor = [UIColor clearColor];
    topBtn.frame = CGRectMake(0,8.0,kAppScreenWidth,45);
    [topBtn addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:topBtn];
    
    UIButton *midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [midBtn setTitle:@"保存" forState:UIControlStateNormal];
    [midBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    midBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    midBtn.backgroundColor = [UIColor clearColor];
    midBtn.frame = CGRectMake(0,45 + 8.0,kAppScreenWidth,45);
    [midBtn addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:midBtn];
    
    return bgView;
}

- (void)saveButtonClick {
    
    [self.longPressAlert dismiss];
    NSURL* img_url = [NSURL URLWithString:_longPressUrl];
    NSData* data = [NSData dataWithContentsOfURL:img_url];
    UIImage* saveImage = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(saveImage, self,
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [SNNewsReport reportADotGif:@"_act=download&_tp=pho&from=pics"];
}

- (void)shareButtonClick {
   [self.longPressAlert dismiss];
   [self performSelector:@selector(shareOnePic:) withObject:_longPressUrl afterDelay:0.5];
}

- (void)shareOnePic:(NSString*)imgUrl{
    SNDebugLog(@"url:::%@",imgUrl);
    
#if 1 //wangshun share test
    NSMutableDictionary* d =[self createImageShare:imgUrl];
    [self callShare:d];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    _actionMenuController.contextDic = [self createImageShare:imgUrl];
    _actionMenuController.shareSubType = ShareSubTypeQuoteText;
    _actionMenuController.shareLogType = @"pho_pics";
    _actionMenuController.delegate = self;
    _actionMenuController.disableQZoneBtn = YES;
    _actionMenuController.lastButtonType = SNActionMenuButtonTypeLoadingPage;
    _actionMenuController.timelineContentType = SNTimelineContentTypePhoto;
    _actionMenuController.disableCopyLinkBtn  = NO;
    _actionMenuController.isLoadingShare = YES;
    [_actionMenuController showActionMenu];
}

- (NSMutableDictionary*)createImageShare:(NSString*)imageUrl{
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    [dicShareInfo setObject:imageUrl forKey:kShareInfoKeyImageUrl];
    [dicShareInfo setObject:imageUrl forKey:@"url"];
    [dicShareInfo setObject:@"" forKey:kShareInfoKeyContent];
    [dicShareInfo setObject:@"0" forKey:kShareInfoKeyNewsId];
    [dicShareInfo setObject:@"qqZone,copyLink" forKey:@"disableIcons"];
    [dicShareInfo setObject:@"pho_news" forKey:@"shareLogType"];
    
    return dicShareInfo;
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

#pragma mark - UIdownloadimagebutton
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    SNDebugLog(@"照片失败%@", [error localizedDescription]);
    [[SNUtility getApplicationDelegate] image:image didFinishSavingWithError:error contextInfo:contextInfo];
}


- (void)hideError {
    _embededActivityIndicator.status = SNTripletsLoadingStatusStopped;
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    _embededActivityIndicator.status = SNTripletsLoadingStatusLoading;
    if (_delegate && [_delegate respondsToSelector:@selector(didTapRetry)])
    {
        [_delegate didTapRetry];
    }
}


- (void)dealloc
{
    _picture = nil;
    _placeholderImageView = nil;
    _loadingActivityIndicatorView = nil;
    _embededActivityIndicator.delegate = nil;
    _embededActivityIndicator = nil;
}

- (UIImage *)image
{
    return _imageView.image;
}

- (void)showEmbededActivityIndicator
{
    [self hidePlaceholder];
    _embededActivityIndicator.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)hideEmbededActivityIndicator
{
    _embededActivityIndicator = SNTripletsLoadingStatusStopped;
}

- (void)updateFrameWithFrame:(CGRect)frame
{
    self.frame = frame;
    _scrollView.frame = self.bounds;
    [self changeImageViewFrame];
}

- (void)hidePlaceholder
{
    _placeholderImageView.hidden = YES;
    [_loadingActivityIndicatorView stopAnimating];
    _loadingActivityIndicatorView.hidden = YES;
}

//加载图片
- (void)loadImage
{
    //这个adImage我看是从字典里取得，所以做下类型判断，避免crash
    if (self.adImage && [self.adImage isKindOfClass:[UIImage class]])
    {
        [self hidePlaceholder];
        _imageView.image = self.adImage;
        _imageView.alpha = themeImageAlphaValue();
        [self changeImageViewFrame];
        
        if (_adDataCarrier) {
            NSString *adText = [_adDataCarrier.filter objectForKey:@"iconText"];
            NSString *adSpaceld = _adDataCarrier.adSpaceId;
            NSString *dsp_source = [_adDataCarrier.adInfoDic objectForKey:@"dsp_source"];
            if ([adSpaceld isEqualToString:@"12233"] && ((adText && adText.length > 0) || (dsp_source && dsp_source.length > 0))) {
                _adLabel.alpha = 1.0f;
                _adLabel.text = [NSString stringWithFormat:@"%@%@", dsp_source ? : @"", adText ? : @""];
                CGSize titleSize = [_adLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeH]];
                _adLabel.width = titleSize.width + 8;
                _adLabel.right = kAppScreenWidth - 14;
            }
        }
    }
    else
    {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_picture.url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
            {
                //下载成功
                [self hidePlaceholder];
                _imageView.alpha = themeImageAlphaValue();
                [self changeImageViewFrame];
            }
            else
            {
                [_loadingActivityIndicatorView stopAnimating];
                _loadingActivityIndicatorView.hidden = YES;
            }
        }];

       /*
//        UIImage *image = [UIImage imageWithContentsOfFile:_picture.url];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_picture.url];
        if (!image) {
            image = [UIImage imageWithContentsOfFile:_picture.url];
        }
        
        if (image)
        {
            [self hidePlaceholder];
            _imageView.image = image;
            _imageView.alpha = themeImageAlphaValue();
            [self changeImageViewFrame];
        }
        else
        {
            [_imageView sd_setImageWithURL:[NSURL URLWithString:_picture.url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                {
                    //下载成功
                    [self hidePlaceholder];
                    _imageView.alpha = themeImageAlphaValue();
                    [self changeImageViewFrame];
                }
                else
                {
                    [_loadingActivityIndicatorView stopAnimating];
                    _loadingActivityIndicatorView.hidden = YES;
                }
            }];
        }*/
    }
}

- (void)prepareForReuse
{
    _imageView.image = nil;
    _placeholderImageView.hidden = NO;
    [_loadingActivityIndicatorView startAnimating];
    _loadingActivityIndicatorView.hidden = NO;
}

- (void)resetImageScale
{
    if (self.adImage) {
        return;
    }
    [_scrollView setZoomScale:1.f animated:YES];
}

//根据图片和屏幕尺寸的宽高来决定_imageView的宽和高
- (void)changeImageViewFrame
{
    if (!_imageView.image)
    {
        return;
    }
    
	CGRect pictureRect = _imageView.frame;
	pictureRect.size = _imageView.image.size;
	
	if (_imageView.image.size.height <= _scrollView.frame.size.height && _imageView.image.size.width <= _scrollView.frame.size.width)
	{
		_imageView.frame = pictureRect;
		_imageView.center = CGPointMake(_scrollView.width/2.f, _scrollView.height/2.f);
		_scrollView.contentSize = _imageView.frame.size;
	}
	else if (_imageView.image.size.height > _scrollView.frame.size.height && _imageView.image.size.width <= _scrollView.frame.size.width)
	{
		int image_x = (_scrollView.frame.size.width -_imageView.image.size.width)/2.f;
		pictureRect.origin.x = 0.f + image_x;
		pictureRect.origin.y = 0.f;
		_imageView.frame = pictureRect;
		_scrollView.contentSize =_imageView.image.size;
		_scrollView.contentOffset = CGPointMake(0.f, 0.f);
		
	}
	else if (_imageView.image.size.height <= _scrollView.frame.size.height && _imageView.image.size.width > _scrollView.frame.size.width)
	{
		pictureRect.size.width = _scrollView.frame.size.width;
		pictureRect.size.height = pictureRect.size.width * _imageView.image.size.height / _imageView.image.size.width;
		_imageView.frame = pictureRect;
		_imageView.center = CGPointMake(_scrollView.width/2.f, _scrollView.height/2.f);
	}
	else
	{
		pictureRect.origin.x = 0.f;
		pictureRect.origin.y = 0.f;
		pictureRect.size.width = _scrollView.frame.size.width ;
		pictureRect.size.height = pictureRect.size.width * _imageView.image.size.height / _imageView.image.size.width;
		_imageView.frame = pictureRect;
		
		if (pictureRect.size.height < _scrollView.frame.size.height)
		{
            _imageView.center = CGPointMake(_scrollView.width/2.f, _scrollView.height/2.f);
		}
		
		_scrollView.contentSize = _imageView.frame.size;
		_scrollView.contentOffset = CGPointMake(0.f, 0.f);
	}
    self.prePoint = _scrollView.contentOffset;
}

- (void)setScrollViewZoom
{
    if (_scrollView.zoomScale == 1.f)
    {
        //放大
        [_scrollView setZoomScale:2.3f animated:YES];
    }
    else
    {
        //还原
        [_scrollView setZoomScale:1.f animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.adImage) {//大图浏览模式下，最后一帧关闭缩放能力。
        return nil;
    }
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    isBeginZoom = YES;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2.f : 0.f;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2.f : 0.f;
    _imageView.center = CGPointMake(scrollView.contentSize.width*.5f + offsetX, scrollView.contentSize.height/2.f + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale <= 1.f)
    {
        isBeginZoom = NO;
        [_scrollView setZoomScale:1.f animated:YES];
    }
    self.prePoint = _scrollView.contentOffset;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ((_imageView.image.size.height > _scrollView.frame.size.height) && !isBeginZoom) {
        
        dispatch_async(dispatch_queue_create("slidePicsCount", DISPATCH_QUEUE_CONCURRENT), ^{
            
            if (scrollView.contentOffset.y > self.prePoint.y) {//上滑退出图集
                [SNNewsReport reportADotGif:@"_act=cc&fun=101&mode=1"];
            } else {//下滑退出图集
                [SNNewsReport reportADotGif:@"_act=cc&fun=101&mode=0"];
            }
        });
        [SNNotificationManager postNotificationName:GallerySliderPicturesNotification object:nil];
    }
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry
{
    _embededActivityIndicator.status = SNEmbededActivityIndicatorStatusStartLoading;
    if (_delegate && [_delegate respondsToSelector:@selector(didTapRetry)])
    {
        [_delegate didTapRetry];
    }
}
@end
