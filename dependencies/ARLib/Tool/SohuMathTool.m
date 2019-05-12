//
//  SohuMathTool.m
//  SohuAR
//
//  Created by sun on 2016/12/5.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuMathTool.h"
#import "SohuARMacro.h"

@implementation SohuMathTool

+(CGFloat)angleForStartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint{
    CGFloat a = endPoint.x - startPoint.x;
    CGFloat b = endPoint.y - startPoint.y;
    CGFloat rads= (M_PI_2-atan2(b, a));
    return rads;
}

+(CGFloat)angleYForStartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint{
    CGFloat a = endPoint.x - startPoint.x;
    CGFloat b = endPoint.y - startPoint.y;
    CGFloat rads= (atan2(b, a)+M_PI_2);
    return rads;
}

+(CGFloat) distanceBetweenPointsFirst:(CGPoint)first second:(CGPoint)second{
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};

+(SCNVector3)CGPointToSCNVector3:(CGPoint )point{
    CGFloat x=point.x-kscreenWidth/2;
    CGFloat y=kscreenHeight/2-point.y;
    return SCNVector3Make(x, y, 0);
}

+(CGPoint)SCNVector3ToCGPoint:(SCNVector3 )scNVector3{
    CGFloat x=kscreenWidth/2+ scNVector3.x;
    CGFloat y=kscreenHeight/2-scNVector3.y;
    return CGPointMake(x, y);
}

+(CGFloat) distanceBetween3DPointsFirst:(SCNVector3 )first second:(SCNVector3 )second{
    CGFloat px=pow(first.x-second.x, 2);
    CGFloat py=pow(first.y-second.y, 2);
    CGFloat pz=pow(first.z-second.z, 2);
    return sqrt(px+py+pz);
}

@end
