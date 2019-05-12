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

@interface SNSlideshowView ()<UIScrollViewDelegate, SNEmbededActivityIndicatorDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIImageView *_placeholderImageView;
    UIActivityIndicatorView *_loadingActivityIndicatorView;
    SNEmbededActivityIndicator *_embededActivityIndicator;
}
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
        [_scrollView release];
        
        UIImage *placeholderImage = [UIImage imageNamed:@"app_logo_gray.png"];
        _placeholderImageView = [[UIImageView alloc] initWithImage:placeholderImage];
        _placeholderImageView.frame = CGRectMake((kAppScreenWidth - placeholderImage.size.width)/2, (kAppScreenHeight - placeholderImage.size.height)/2, placeholderImage.size.width, placeholderImage.size.height);
        [self addSubview:_placeholderImageView];
        _placeholderImageView.hidden = NO;
        
        _loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((kAppScreenWidth - 40.f)/2, _placeholderImageView.centerY + 40.f, 40.f, 40.f)];
        _loadingActivityIndicatorView.centerX = _placeholderImageView.centerX;
        [_loadingActivityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_loadingActivityIndicatorView];
        if (![[SNUtility getApplicationDelegate] checkNetworkStatus])
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
        [_imageView release];
        
        _embededActivityIndicator = [[SNEmbededActivityIndicator alloc] initWithFrame:self.bounds andDelegate:self];
        _embededActivityIndicator.hidesWhenStopped = YES;
        [self addSubview:_embededActivityIndicator];
        [_embededActivityIndicator stopAnimating];
    }
    return self;
}

- (void)dealloc
{
    [_picture release], _picture = nil;
    [_placeholderImageView release], _placeholderImageView = nil;
    [_loadingActivityIndicatorView release], _loadingActivityIndicatorView = nil;
    _embededActivityIndicator.delegate = nil;
    [_embededActivityIndicator release], _embededActivityIndicator = nil;
    [super dealloc];
}

- (UIImage *)image
{
    return _imageView.image;
}

- (void)showEmbededActivityIndicator
{
    [self hidePlaceholder];
    [_embededActivityIndicator startAnimating];
    _embededActivityIndicator.hidesWhenStopped = NO;
    _embededActivityIndicator.alpha = .8f;
    _embededActivityIndicator.status = SNEmbededActivityIndicatorStatusStopLoading;
}

- (void)hideEmbededActivityIndicator
{
    _embededActivityIndicator.hidesWhenStopped = YES;
    [_embededActivityIndicator stopAnimating];
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
    if (_adImage)
    {
        [self hidePlaceholder];
        _imageView.image = _adImage;
        _imageView.alpha = 1.f;
        [self changeImageViewFrame];
    }
    else
    {
        UIImage *image = [UIImage imageWithContentsOfFile:_picture.url];
        if (image)
        {
            [self hidePlaceholder];
            _imageView.image = image;
            _imageView.alpha = 1.f;
            [self changeImageViewFrame];
        }
        else
        {
            [_imageView setImageWithURL:[NSURL URLWithString:_picture.url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image)
                {
                    //下载成功
                    [self hidePlaceholder];
                    _imageView.alpha = 1.f;
                    [self changeImageViewFrame];
                }
                else
                {
                    [_loadingActivityIndicatorView stopAnimating];
                    _loadingActivityIndicatorView.hidden = YES;
                }
            }];
        }
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
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2.f : 0.f;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2.f : 0.f;
    _imageView.center = CGPointMake(scrollView.contentSize.width*.5f + offsetX, scrollView.contentSize.height/2.f + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (scale < 1.f)
    {
        [_scrollView setZoomScale:1.f animated:YES];
    }
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapRetry)])
    {
        [_delegate didTapRetry];
    }
}
@end
