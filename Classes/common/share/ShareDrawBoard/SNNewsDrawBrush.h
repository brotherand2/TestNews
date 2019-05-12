//
//  SNNewsDrawBrush.h
//  testDrawboard
//
//  Created by wang shun on 2017/7/10.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SNNewsDrawBoard.h"
@interface SNNewsDrawBrush : NSObject

//画笔颜色
@property (nonatomic, strong) UIColor *brushColor;

//画笔宽度
@property (nonatomic, assign) NSInteger brushWidth;

//是否是橡皮擦
@property (nonatomic, assign) BOOL isEraser;

//形状
@property (nonatomic, assign) SNNewsDrawShapeType shapeType;

//路径
@property (nonatomic, strong) UIBezierPath *bezierPath;

//起点
@property (nonatomic, assign) CGPoint beginPoint;
//终点
@property (nonatomic, assign) CGPoint endPoint;


@end
