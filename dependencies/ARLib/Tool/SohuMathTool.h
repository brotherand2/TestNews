//
//  SohuMathTool.h
//  SohuAR
//
//  Created by sun on 2016/12/5.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface SohuMathTool : NSObject

+(CGFloat)angleForStartPoint:(CGPoint)startPoint
                    EndPoint:(CGPoint)endPoint;

+(CGFloat)angleYForStartPoint:(CGPoint)startPoint
                     EndPoint:(CGPoint)endPoint;
+(CGFloat) distanceBetweenPointsFirst:(CGPoint)first
                               second:(CGPoint)second;

+(SCNVector3)CGPointToSCNVector3:(CGPoint )point;

+(CGPoint)SCNVector3ToCGPoint:(SCNVector3 )scNVector3;

+(CGFloat) distanceBetween3DPointsFirst:(SCNVector3 )first
                                 second:(SCNVector3 )second;

@end
