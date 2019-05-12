//
//  SNCheckAnimationMoveLayer.h
//  WebViewZoomDemo
//
//  Created by Scarlett on 16/8/23.
//  Copyright © 2016年 Scalett. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define kLineWidth  2

@interface SNCheckAnimationMoveLayer : CALayer

@property (nonatomic, assign) CGFloat progress; // 参数
@property (nonatomic, assign) BOOL isSuccess;

@end
