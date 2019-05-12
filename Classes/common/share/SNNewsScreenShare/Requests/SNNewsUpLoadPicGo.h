//
//  SNNewsUpLoadPicGo.h
//  sohunews
//
//  Created by wang shun on 2017/8/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNNewsUpLoadPicGo : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict WithFile:(NSData*)file;

@end
