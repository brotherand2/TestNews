//
//  SohuScreenShotTool.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuScreenShotTool.h"

@implementation SohuScreenShotTool

+(UIImage *)screenShotForView:(UIView *)view{
    if (view==nil) {
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        view=window;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil,nil);
    return screenshot;
}

+ (UIImage *)addImage1:(UIImage *)imageName1 withImage1:(UIImage *)imageName2 {
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    UIImage *image1 = imageName1;
    UIImage *image2 =imageName2;
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0);
    [image1 drawInRect:window.frame];
    [image2 drawInRect:window.frame];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+(UIImage *)screenShotForView:(UIView *)view image:(UIImage *)image{
    if (view==nil) {
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        view=window;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil,nil);
    return screenshot;
}

@end
