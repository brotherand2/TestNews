//
//  SohuScreenShotTool.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SohuScreenShotTool : NSObject

+(UIImage *)screenShotForView:(UIView *)view;

+(UIImage *)addImage1:(UIImage *)imageName1 withImage1:(UIImage *)imageName2;

@end
