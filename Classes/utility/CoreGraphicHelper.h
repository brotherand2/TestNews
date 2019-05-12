//
//  CoreGraphicHelper.h
//  sohunews
//
//  Created by sampan li on 13-1-17.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreGraphicHelper : NSObject
{
    
}
+ (CGPathRef)roundedPath:(CGRect)rect cornerRadius:(float)radius;
+ (void)drawRoundedMask:(CGRect)rect color:(UIColor*)color;
@end
