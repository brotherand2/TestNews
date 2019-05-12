//
//  SNCloudSaveRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNCloudSaveRequest : SNDefaultParamsRequest 

- (instancetype)initWithDictionary:(NSDictionary *)dict andIsCollectNews:(BOOL)isCollectNews;

@end
