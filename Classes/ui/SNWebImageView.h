//
//  SNWebImageView.h
//  sohunews
//
//  Created by chenhong on 13-9-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

// A wrapper class for UIImageView (WebCache)
typedef void(^SNWebImageCompletedBlock)();
typedef void(^SNWebImageCompleteBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType);
typedef void(^SNSplashImageCompleteBlock)(NSData *imageData);


@interface SNWebImageView : UIImageView {
    UIImageView     *_maskImageView;
    UIImage         *_defaultImage;
}

@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, assign) BOOL showFade;
@property (nonatomic, assign) BOOL hasLoaded;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoaded;

// 忽略图片模式设置，2/3G下也加载
@property (nonatomic, assign) BOOL ignorePicMode;
@property (nonatomic, strong) UIImageView *maskImageView;

- (void)unsetImage;
- (void)setImage:(UIImage *)image animated:(BOOL) animated;

// 是否下载与网络环境有关
- (void)setUrlPath:(NSString *)urlPath;

- (void)setUrlPath:(NSString *)urlPath
         completed:(SNWebImageCompleteBlock)completedBlock;

// 下载图片，无论网络环境
- (void)loadUrlPath:(NSString *)urlPath;

- (void)loadUrlPath:(NSString *)urlPath
          completed:(SNWebImageCompleteBlock)completedBlock;

- (void)setDefaultImageMode:(UIImage *)image;

@end
