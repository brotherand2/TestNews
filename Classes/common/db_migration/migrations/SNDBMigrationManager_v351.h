//
//  SNDBMigrationManager_v351.h
//  sohunews
//
//  Created by jojo on 13-8-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v351)

// 订阅中心 增加needLogin列
- (void)migrateUpTo3_5_1_0;

// 订阅中心 增加 canOffline列
- (void)migrateUpTo3_5_1_1;

- (void)migrateUpTo3_5_1_3;

- (void)migrateUpTo3_5_1_4;

// article表添加updateTime字段
- (void)migrateUpTo3_5_1_5;

@end
