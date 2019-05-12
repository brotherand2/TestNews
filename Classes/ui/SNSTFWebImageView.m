//
//  SNSTFWebImageView.m
//  sohunews
//
//  Created by wangyy on 15/9/22.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSTFWebImageView.h"

@implementation SNSTFWebImageView

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
    
    if (_defaultImage.size.width > self.width ||
        _defaultImage.size.height > self.height) {
        self.contentMode = UIViewContentModeScaleAspectFill;
    } else if (_defaultImage.size.width < self.width ||
               _defaultImage.size.height < self.height){
        self.contentMode = UIViewContentModeScaleToFill;
    } else {
        self.contentMode = UIViewContentModeCenter;
    }
}

@end
