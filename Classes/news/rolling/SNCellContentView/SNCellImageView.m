//
//  SNCellImageView.m
//  sohunews
//
//  Created by lhp on 11/15/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNCellImageView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "NSCellLayout.h"

@implementation SNCellImageView

- (id)initWithFrame:(CGRect)frame alpha:(CGFloat)alpha {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.alpha = alpha;
        
        imageView = [[SNImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        
        UIImage *videoImage = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
        videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,0,VIDEO_ICON_WIDTH, VIDEO_ICON_WIDTH)];
        videoImageView.image = videoImage;
        videoImageView.bottom = frame.size.height - 5;
        videoImageView.hidden = YES;
        [self addSubview:videoImageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.alpha = themeImageAlphaValue();

        imageView = [[SNImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        
        UIImage *videoImage = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
        videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,0,VIDEO_ICON_WIDTH, VIDEO_ICON_WIDTH)];
        videoImageView.image = videoImage;
        videoImageView.bottom = frame.size.height - 5;
        videoImageView.hidden = YES;
        [self addSubview:videoImageView];
    }
    return self;
}

- (void)setWidth:(CGFloat)width {
    imageView.height = width;
}

- (void)setHeight:(CGFloat)height {
    imageView.height = height;
}

- (void)setImageContentMode:(UIViewContentMode)contentMode {
    imageView.contentMode = contentMode;
}

- (void)setDefaultImage:(UIImage *)image {
    if (image) {
        imageView.image = image;
    }
}

- (void)setImageCoverWithImage:(UIImage *)coverImage {
    [imageView setImageCoverWithImage:coverImage];
}

- (void)updateImageWithUrl1:(NSString *)url
               defaultImage:(UIImage *)defaultImage
                  showVideo:(BOOL)isShow {
    videoImageView.hidden = isShow ? NO : YES;
    NSURL *imgUrl = [NSURL URLWithString:url];
    [imageView sd_setImageWithURL:imgUrl placeholderImage:defaultImage options:0];
}

- (void)updateImageWithUrl:(NSString *)url
              defaultImage:(UIImage *)defaultImage
                 showVideo:(BOOL)isShow {
    videoImageView.hidden = isShow ? NO : YES;
    [imageView loadBySystemRequest:url defaultImage:defaultImage];
}

- (void)showDefaultVideoIcon:(BOOL)isShow {
    videoImageView.hidden = isShow ? NO : YES;
}

- (void)hideVideoIcon {
    videoImageView.hidden = YES;
}

- (void)sd_cancelCurrentImageLoad {
    [imageView sd_cancelCurrentImageLoad];
}

- (void)updateTheme {
    self.alpha = themeImageAlphaValue();
}

- (void)updateDefaultImage:(UIImage *)image {
    [imageView updateDefaultImage:image];
}

- (void)dealloc {
    [imageView sd_cancelCurrentImageLoad];
    
    imageView = nil;
    videoImageView = nil;
}

- (void)layOutVideoImageView {
    videoImageView.bottom = self.size.height - 5;
}

@end
