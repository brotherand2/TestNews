//
//  SohuVector3.h
//  SohuAR
//
//  Created by sun on 2016/12/5.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SohuVector3 : NSObject

@property(nonatomic,assign) double vector3x;
@property(nonatomic,assign) double vector3y;
@property(nonatomic,assign) double vector3z;

+(SohuVector3 *)vector3x:(double)x y:(double)y z:(double)z;

@end
