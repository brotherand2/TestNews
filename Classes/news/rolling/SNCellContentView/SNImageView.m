//
//  SNImageView.m
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNImageView.h"

@interface SNImageView ()
@end

#define kImageCoverClose        (0)  //关闭遮罩
#define kImageLoadClose         (0)  //图片请求开关 (方便查看默认图)

@implementation SNImageView
@synthesize defaultImage;
@synthesize imageUrl;
@synthesize ignorePictureMode;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
    }
    return self;
}

- (void)setImageCoverWithImage:(UIImage *)coverImage {
    if (kImageCoverClose || !coverImage) {
        return;
    }
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, self.width, self.height);
    maskLayer.contents = (id)coverImage.CGImage;
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

- (void)loadImageWithUrl:(NSString *)url defaultImage:(UIImage *)newImage {
    [self sd_cancelCurrentImageLoad];
    if (self.defaultImage != newImage) {
        self.defaultImage = newImage;
    }
    
    if (!url || [url isEqualToString:@""] || [url isEqualToString:@"null"]) {
        self.image = self.defaultImage;
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger nonePictureMode = [[userDefaults objectForKey:kNonePictureModeKey] intValue];
    BOOL showPicture = YES;
    if (nonePictureMode == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        showPicture = NO;
    }
    
    self.imageUrl = url;
    NSURL *URL = [NSURL URLWithString:url];
    
    BOOL isCached = [[SDWebImageManager sharedManager] cachedImageExistsForURL:URL];
    if (isCached) {
        [self sd_setImageWithURL:URL placeholderImage:newImage];
    } else if(showPicture == YES || ignorePictureMode){
        if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually || ignorePictureMode) {
            [self sd_setImageWithURL:URL placeholderImage:newImage];
        } else {
            self.image = self.defaultImage;
        }
    } else {
        self.image = self.defaultImage;
    }
    
    self.contentMode = UIViewContentModeScaleToFill;
}

- (void)loadBySystemRequest:(NSString *)url defaultImage:(UIImage *)newImage {
    // 已经发现问题，不会修改，把代码还回去。
    return [self loadImageWithUrl:url defaultImage:newImage];
}

- (void)loadImage {
    if (kImageLoadClose) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageKey = self.imageUrl;
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageKey];
        
    //为了使得无图模式下显示占位图，强制置空；bug40097，清空后，仍然显示缩略图，有可能是更新SDWebImage引起
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger nonePictureMode = [[userDefaults objectForKey:kNonePictureModeKey] intValue];
        BOOL showPicture = YES;
        if (nonePictureMode == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable) {
            showPicture = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cacheImage) {
                if (self.imageUrl && imageKey && [imageKey isEqualToString:self.imageUrl]) {
                    self.image = cacheImage;
                    imageLoaded = YES;
                }
            }
            else if(showPicture == YES || ignorePictureMode){
               if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually || ignorePictureMode) {
                    [self sd_setImageWithURL:[NSURL URLWithString:self.imageUrl]
                            placeholderImage:defaultImage
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                       if (image) {
                                           imageLoaded = YES;
                                       }
                                   }];
               }
            }
            self.contentMode = UIViewContentModeScaleToFill;
        });
    });
}

- (void)updateDefaultImage:(UIImage *)image {
    [self loadImageWithUrl:self.imageUrl defaultImage:image];
}

- (void)dealloc {
    [self sd_cancelCurrentImageLoad];
}

@end
