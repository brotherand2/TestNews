//
//  SNLocationRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNLocationRequest : SNDefaultParamsRequest

- (instancetype)initWithLocation:(CGPoint)location;

@end
