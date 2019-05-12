//
//  AnimView.h
//  Test
//
//  Created by Xiang Wei Jia on 4/10/15.
//  Copyright (c) 2015 Xiang Wei Jia. All rights reserved.
//

#import <UIKit/UIKit.h>

// 动画固定是63x63的区域，无法改变宽高，只能改变位置。
// 就算设置了宽高也没用的...... 我把它写死了
@interface SNCenterLinesAnimView : UIView

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, assign) BOOL isFullScreenMode;

@property (nonatomic) NSTimeInterval duration;

- (void)startAnimating;

// 回复到初始状态。（三根杠的状态）
// arrow: YES. 设置为箭头状态
//        NO.  设置位三根杠状态
- (void)reset:(BOOL)arrow;

//动态换肤，重新设置颜色
- (void)resetLineNormalColor:(BOOL)isNormal;

//全屏模式 根据scrollview滚动变化颜色
- (void)setLineColorWithRatio:(CGFloat)ratio;

@end
