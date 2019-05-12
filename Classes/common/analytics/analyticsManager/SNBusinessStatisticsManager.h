//
//  SNBusinessStatisticsManager.h
//  sohunews
//
//  Created by jialei on 14-8-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  保存统计信息的数据结构
//  - NSMutableDictionary
//         - key     <NSString *>     statType_objFrom_objFromId_objType_token
//         - value   <NSMutableSet *> {objId}    (objId的集合)
// 数据上传条件 记录第一条数据起没10分钟上传一次


#import <Foundation/Foundation.h>
#import "SNBusinessStatInfo.h"

@interface SNBusinessStatisticsManager : NSObject

+ (SNBusinessStatisticsManager *)shareInstance;

- (void)updateStatisticsInfo:(SNBusinessStatInfo *)statInfo;

- (void)upload;

@end
