//
//  SNUserInfoRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/19.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNUserInfoRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andIsSelf:(BOOL)isSelf;

@end
