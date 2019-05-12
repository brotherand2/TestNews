//
//  SNNewsDrawBoard.h
//  testDrawboard
//
//  Created by wang shun on 2017/7/10.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_UNDO_COUNT   10

//#define LSDEF_BRUSH_COLOR [UIColor colorWithRed:255 green:0 blue:0 alpha:1.0]

#define LSDEF_BRUSH_WIDTH 3

#define LSDEF_BRUSH_SHAPE SNNewsDrawShapeCurve

#import "SNNewsDrawModel.h"

//画笔形状
typedef NS_ENUM(NSInteger, SNNewsDrawShapeType)
{
    SNNewsDrawShapeCurve = 0,//曲线(默认)
    SNNewsDrawShapeLine,//直线
    SNNewsDrawShapeEllipse,//椭圆
    SNNewsDrawShapeRect,//矩形
    
};
/////////////////////////////////////////////////////////////////////

@protocol SNNewsDrawBoardDelegate;
@interface SNNewsDrawBoard : UIView
@property (nonatomic,weak) id <SNNewsDrawBoardDelegate> delegate;
//颜色
@property (strong, nonatomic) UIColor *brushColor;
//是否是橡皮擦
@property (assign, nonatomic) BOOL isEraser;
//宽度
@property (assign, nonatomic) NSInteger brushWidth;
//形状
@property (assign, nonatomic) SNNewsDrawShapeType shapeType;
//背景图
@property (assign, nonatomic) UIImage *backgroundImage;

@property (assign, nonatomic) BOOL isShowMenu;

//撤销
- (void)unDo;
//保存到相册
- (void)save;
//清除绘制
- (void)clean;

- (void)reEnterSelf;

- (void)canelClick;

- (UIImage*)getLastBrush;

@end

@protocol SNNewsDrawBoardDelegate  <NSObject>

//是否能撤销
- (void)drawBoardCanUnDo:(BOOL)can;

//点击
- (void)drawBoardClick:(id)sender;

- (void)drawBoardStartDraw:(id)sender;

- (void)drawBoartFinished:(id)sender;


@end
