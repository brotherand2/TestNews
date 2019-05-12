//
//  SNImageView.h
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SNImageView : UIImageView {
    UIImage *defaultImage;
    NSString *imageUrl;
    
    BOOL ignorePictureMode;         //忽视无图模式
    BOOL imageLoaded;               //图片是否已加载
}

@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL ignorePictureMode;

- (void)setImageCoverWithImage:(UIImage *)coverImage;
- (void)loadImageWithUrl:(NSString *)url defaultImage:(UIImage *)newImage;
- (void)loadBySystemRequest:(NSString *)url defaultImage:(UIImage *)newImage;
- (void)updateDefaultImage:(UIImage *)image;

@end
