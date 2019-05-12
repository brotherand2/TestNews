//
//  SNDBMigrationManager_350.h
//  sohunews
//
//  Created by weibin cheng on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v350)

- (void)migrateUpTo3_5_0_0;

// 创建阅读圈  share read 数据表
- (void)migrateUpTo3_5_0_1;

// 创建阅读圈 timeline 数据表
- (void)migrateUpTo3_5_0_2;

// 评论缓存表增加音频字段
- (void)migrateUpTo3_5_0_3;

- (void)migrateUpTo3_5_0_4;

- (void)migrateUpTo3_5_0_5;

@end
