//
//  SNGalleryPhotoView.h
//  sohunews
//
//  Created by chenhong on 14-4-23.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNGalleryPhotoView : UIView

- (void)loadImageWithUrlPath:(NSString *)urlPath;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *downloadBtn;  // 下载按钮
@end
