//
//  SNGalleryPhotoCell.m
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryPhotoCell.h"
#import "SNGalleryConst.h"
#import "UIImageView+WebCache.h"
#import "SNRingSpinnerView.h"
#import "SNWaitingActivityView.h"

#define kMaxZoom        2.5
#define kMinZoom        1

@interface SNGalleryPhotoCell()<UIScrollViewDelegate>
{
    CGFloat _currentScale;
    BOOL _isDoubleTapingForZoom;
    CGFloat _touchX;
    CGFloat _touchY;
}

@property (nonatomic, strong) UIView * maskView;

@property (nonatomic, strong) SNWaitingActivityView * ringSpinner;

@end

@implementation SNGalleryPhotoCell

#pragma mark - public

- (void)resetZoomingScale {
    if (self.scrollView.zoomScale != kMinZoom) {
        self.scrollView.zoomScale = kMinZoom;
        _currentScale = kMinZoom;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCellDidResetZoom)]) {
        [self.delegate photoCellDidResetZoom];
    }
}

- (void)loadImageWithUrl:(NSString *)urlString {
    if (![urlString isKindOfClass:[NSString class]] || urlString.length <= 0) {
        return;
    }
    /// 没有网的时候不让cell频繁刷图片
    if (self.photoView.image && ![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        return;
    }
    _isLoadingImage = YES;
    if (!self.ringSpinner) {
        self.ringSpinner = [[SNWaitingActivityView alloc] initWithFrame:CGRectMake(0, 0, 32.5, 32.5)];
        [_photoView addSubview:self.ringSpinner];
    }
    
    _photoView.frame = CGRectMake(0, 0, self.width*2/3.f, self.height*2/3.f);
    _photoView.center = CGPointMake(_scrollView.frame.size.width/2.f, _scrollView.frame.size.height/2.f);
    self.ringSpinner.centerX = self.photoView.width/2.f;
    self.ringSpinner.centerY = self.photoView.height*2/3.f;
    self.ringSpinner.hidden = NO;
    [self.ringSpinner startAnimating];
//    UIImage * cache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
//    if (cache) {
//        [self.ringSpinner stopAnimating];
//        self.ringSpinner.hidden = YES;
//        _photoView.image = cache;
//        [self changeImageViewFrame];
//        _isLoadingImage = NO;
//        return;
//    }else{
        _photoView.image = [UIImage themeImageNamed:@"app_logo_gray.png"];
//    }

    NSURL *url = [NSURL URLWithString:urlString];
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [self.ringSpinner stopAnimating];
            self.ringSpinner.hidden = YES;
            self.photoView.image = image;
            [self changeImageViewFrame];
            _isLoadingImage = NO;
        }
    }];

}

#pragma mark - private

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initContent];
        [self addGestureRecognizer];
    }
    return self;
}

- (void)initContent {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.maximumZoomScale = kMaxZoom;
    self.scrollView.minimumZoomScale = kMinZoom;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftOffset, 0, self.bounds.size.width - 2 * kLeftOffset, self.bounds.size.height)];
    self.photoView.backgroundColor = [UIColor clearColor];
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.photoView];
    
    self.scrollView.frame = CGRectMake(kLeftOffset, 0, self.bounds.size.width - 2 * kLeftOffset, self.bounds.size.height);
    self.photoView.frame = self.scrollView.bounds;
    
    self.placeholderImage = [UIImage themeImageNamed:@"app_logo_gray.png"];
    
    BOOL night = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (night) {
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.photoView addSubview:self.maskView];
    }
}

- (void)addGestureRecognizer {
    //双击放大缩小
    UITapGestureRecognizer * twiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twiceTapping:)];
    twiceTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:twiceTap];
    
    //单击事件
    UITapGestureRecognizer * onceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onceTapping:)];
    onceTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:onceTap];
    [onceTap requireGestureRecognizerToFail:twiceTap];
}

- (void)twiceTapping:(UIGestureRecognizer *)getsure {
    if ([getsure isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer * tap = (UITapGestureRecognizer *)getsure;
        _touchX = [tap locationInView:self.scrollView].x;
        _touchY = [tap locationInView:self.scrollView].y;
        _isDoubleTapingForZoom = YES;
        if (_currentScale > kMinZoom) {
            [self.scrollView setZoomScale:kMinZoom animated:YES];
            _currentScale = kMinZoom;
        }else{
            [self.scrollView setZoomScale:kMaxZoom animated:YES];
            SNDebugLog(@"touchX:%f, touchY:%f",_touchX,_touchY);
            _currentScale = kMaxZoom;
        }
    }
    _isDoubleTapingForZoom = NO;
}

- (void)onceTapping:(UITapGestureRecognizer *)getsure {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCellDidTap)]) {
        [self.delegate photoCellDidTap];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - scrollerView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoCellDidZommingNotification object:self.indexPath];
    if (scale < kMinZoom) {
        [scrollView setZoomScale:kMinZoom animated:YES];
        _currentScale = kMinZoom;
    }else{
        _currentScale = scale;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCellDidZoom:)]) {
        [self.delegate photoCellDidZoom:_currentScale > kMinZoom];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2.f : 0.f;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2.f : 0.f;
    _photoView.center = CGPointMake(scrollView.contentSize.width*.5f + offsetX, scrollView.contentSize.height/2.f + offsetY);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    SNDebugLog(@"content off set X : %f , Y : %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    if ([self.delegate respondsToSelector:@selector(photoDidScroll:)]) {
        [self.delegate photoDidScroll:scrollView];
    }
}

#pragma mark - tool
//根据图片和屏幕尺寸的宽高来决定_photoView的宽和高
- (void)changeImageViewFrame
{
    if (!_photoView.image)
    {
        return;
    }
    
    CGRect pictureRect = _photoView.frame;
    pictureRect.size = _photoView.image.size;
    
    if (_photoView.image.size.height <= _scrollView.frame.size.height && _photoView.image.size.width <= _scrollView.frame.size.width)
    {
        _photoView.frame = pictureRect;
        _photoView.center = CGPointMake(_scrollView.frame.size.width/2.f, _scrollView.frame.size.height/2.f);
        _scrollView.contentSize = _photoView.frame.size;
    }
    else if (_photoView.image.size.height > _scrollView.frame.size.height && _photoView.image.size.width <= _scrollView.frame.size.width)
    {
        int image_x = (_scrollView.frame.size.width -_photoView.image.size.width)/2.f;
        pictureRect.origin.x = 0.f + image_x;
        pictureRect.origin.y = 0.f;
        _photoView.frame = pictureRect;
        _scrollView.contentSize =_photoView.image.size;
        _scrollView.contentOffset = CGPointMake(0.f, 0.f);
        
    }
    else if (_photoView.image.size.height <= _scrollView.frame.size.height && _photoView.image.size.width > _scrollView.frame.size.width)
    {
        pictureRect.size.width = _scrollView.frame.size.width;
        pictureRect.size.height = pictureRect.size.width * _photoView.image.size.height / _photoView.image.size.width;
        _photoView.frame = pictureRect;
        _photoView.center = CGPointMake(_scrollView.frame.size.width/2.f, _scrollView.frame.size.height/2.f);
    }
    else
    {
        pictureRect.origin.x = 0.f;
        pictureRect.origin.y = 0.f;
        pictureRect.size.width = _scrollView.frame.size.width ;
        pictureRect.size.height = pictureRect.size.width * _photoView.image.size.height / _photoView.image.size.width;
        _photoView.frame = pictureRect;
        
        if (pictureRect.size.height < _scrollView.frame.size.height)
        {
            _photoView.center = CGPointMake(_scrollView.frame.size.width/2.f, _scrollView.frame.size.height/2.f);
        }
        
        _scrollView.contentSize = _photoView.frame.size;
        _scrollView.contentOffset = CGPointMake(0.f, 0.f);
    }
}


@end
