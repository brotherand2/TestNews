//
//  SNCellImageView.h
//  sohunews
//
//  Created by lhp on 11/15/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNImageView.h"

@interface SNCellImageView : UIView {
    SNImageView *imageView;
    UIImageView *videoImageView;
}

- (id)initWithFrame:(CGRect)frame alpha:(CGFloat)alpha;
- (void)updateImageWithUrl:(NSString *)url
              defaultImage:(UIImage *)defaultImage
                 showVideo:(BOOL)isShow;

- (void)updateImageWithUrl1:(NSString *)url
               defaultImage:(UIImage *)defaultImage
                  showVideo:(BOOL)isShow;
- (void)setImageCoverWithImage:(UIImage *)coverImage;
- (void)setDefaultImage:(UIImage *)image;
- (void)setImageContentMode:(UIViewContentMode)contentMode;
- (void)updateTheme;
- (void)updateDefaultImage:(UIImage *)image;
- (void)layOutVideoImageView;

//AB Test
- (void)showDefaultVideoIcon:(BOOL)isShow;
- (void)hideVideoIcon;
@end
