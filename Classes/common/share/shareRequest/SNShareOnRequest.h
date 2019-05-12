//
//  SNShareOnRequest.h
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/22.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNShareOnRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andShareOnUrl:(NSString *)shareOnUrl;

@end
