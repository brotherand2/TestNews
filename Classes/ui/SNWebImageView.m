//
//  SNWebImageView.m
//  sohunews
//
//  Created by chenhong on 13-9-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNWebImageView.h"

@implementation SNWebImageView

@synthesize maskImageView = _maskImageView;
@synthesize defaultImage = _defaultImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        _maskImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _maskImageView.contentMode = self.contentMode;
        _maskImageView.backgroundColor = [UIColor clearColor];
        _maskImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _showFade = YES;
        _hasLoaded = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _maskImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setDefaultImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    if (_defaultImage != image) {
        _defaultImage = image;
    }
    
    if (!self.hasLoaded) {
        self.image = _defaultImage;
    }
}

- (void)setDefaultImageMode:(UIImage *)image {
    self.defaultImage = image;
    self.image = self.defaultImage;
    if (self.defaultImage.size.width > self.width ||
        self.defaultImage.size.height > self.height) {
        self.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.contentMode = UIViewContentModeCenter;
    }
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    if (image != self.defaultImage) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        if (image) {
            _hasLoaded = YES;
        }
    }
    if (!image) {
        _hasLoaded = NO;
    }
}

- (void)setImage:(UIImage *)image animated:(BOOL) animated {
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:nil];
    }
    [self setImage:image];
}

- (void)unsetImage {
    [self setUrlPath:nil];
}

// 是否下载与网络环境有关
- (void)setUrlPath:(NSString *)urlPath {
    _urlPath = urlPath;
    [self setUrlPath:urlPath completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
    }];
}

// 下载图片，无论网络环境
- (void)loadUrlPath:(NSString *)urlPath {
    [self loadUrlPath:urlPath completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
    }];
}

//---Added by handy
- (void)setUrlPath:(NSString *)urlPath
         completed:(SNWebImageCompleteBlock)completedBlock {
    self.isLoading = YES;
    self.isLoaded = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger nonePictureMode = [[userDefaults objectForKey:kNonePictureModeKey] intValue];
    BOOL showPicture = YES;
    if (nonePictureMode == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        showPicture = NO;
    }
    
    if (urlPath == nil) {
        [self sd_setImageWithURL:nil
             placeholderImage:_defaultImage
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        self.isLoaded = YES;
                        self.isLoading = NO;
                        completedBlock(image, error, cacheType);
        }];
        _hasLoaded = NO;
    } else if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlPath]) {
        [self sd_setImageWithURL:[NSURL URLWithString:urlPath]
             placeholderImage:_defaultImage
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        self.isLoaded = YES;
                        self.isLoading = NO;
                        completedBlock(image, error, cacheType);
        }];
        _hasLoaded = YES;
    } else if(showPicture == YES || _ignorePicMode) {
        if (_ignorePicMode || ![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
            [self loadUrlPath:urlPath completed:completedBlock];
            self.isLoaded = YES;
            self.isLoading = NO;
        } else {
            [self sd_setImageWithURL:nil
                 placeholderImage:_defaultImage
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            self.isLoaded = YES;
                            self.isLoading = NO;
                            completedBlock(image, error, cacheType);
            }];
            _hasLoaded = NO;
        }
    } else {
        [self sd_setImageWithURL:nil
                placeholderImage:_defaultImage
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           self.isLoaded = YES;
                           self.isLoading = NO;
                           completedBlock(image, error, cacheType);
                       }];
        _hasLoaded = NO;
    }
}

- (void)loadUrlPath:(NSString *)urlPath
          completed:(SNWebImageCompleteBlock)completedBlock {
    if (_urlPath != urlPath) {
        _urlPath = urlPath;
    }

    __weak SNWebImageView *blockSelf = self;
    self.isLoading = YES;
    self.isLoaded = NO;
    [self sd_setImageWithURL:[NSURL URLWithString:urlPath] placeholderImage:_defaultImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.isLoaded = YES;
        self.isLoading = NO;
        if (image) {
            _hasLoaded = YES;
            
            completedBlock(image, error, cacheType);
            
            if (blockSelf.showFade) {
                _maskImageView.image = blockSelf.defaultImage;
                _maskImageView.alpha = 1;
                [blockSelf addSubview:_maskImageView];
                
                // Fade动画
                [UIView animateWithDuration:0.3 animations:^{
                    _maskImageView.alpha = 0;
                } completion:^(BOOL finished) {
                    [_maskImageView removeFromSuperview];
                }];
            }
        } else {
            completedBlock(image, error, SDImageCacheTypeNone);
        }
    }];
}

@end
