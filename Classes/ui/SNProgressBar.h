//
//  SNProgressBar.h
//  sohunews
//
//  Created by weibin cheng on 14-10-9.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNProgressBar : UIView
{
    UIView*     _progressView;
}

//进度为1.0时进度条会以动画形式停止显示
@property (nonatomic, assign) CGFloat curProgress;
@property (nonatomic, strong) NSTimer* timer;


/**
 *  开始进度条，进度条自动显示进度直到0.9
 */
- (void)startProgress;

/**
 *  停止显示进度条
 */
- (void)resetProgress;

/**
 *  切换日夜间模式
 */
- (void)updateTheme;

@end
