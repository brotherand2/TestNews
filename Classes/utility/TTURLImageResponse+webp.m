//
//  TTURLImageResponse+webp.m
//  sohunews
//
//  Created by guoyalun on 7/31/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "TTURLImageResponse+webp.h"
#import "UIImage+MultiFormat.h"

@implementation TTURLImageResponse (webp)

- (UIImage *)sd_imageWithData:(NSData *)data
{
    UIImage* image = [UIImage sd_imageWithData:data];
    return image;
}

@end
