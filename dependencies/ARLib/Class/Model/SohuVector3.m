//
//  SohuVector3.m
//  SohuAR
//
//  Created by sun on 2016/12/5.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuVector3.h"

@implementation SohuVector3

+(SohuVector3 *)vector3x:(double)x y:(double)y z:(double)z{
    SohuVector3 *vector3=[[SohuVector3 alloc]init];
    vector3.vector3x=x;
    vector3.vector3y=y;
    vector3.vector3z=z;
    return vector3;
}

@end
