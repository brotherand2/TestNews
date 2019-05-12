//
//  SNNewsDrawCanvas.m
//  testDrawboard
//
//  Created by wang shun on 2017/7/10.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import "SNNewsDrawCanvas.h"

@implementation SNNewsDrawCanvas

+ (Class)layerClass
{
    return ([CAShapeLayer class]);
}

- (void)setBrush:(SNNewsDrawBrush *)brush
{
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    
    shapeLayer.strokeColor = brush.brushColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineWidth = brush.brushWidth;
    
    if (!brush.isEraser)
    {
        ((CAShapeLayer *)self.layer).path = brush.bezierPath.CGPath;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
