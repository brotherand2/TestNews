//
//  SNDBMigrationManager_330.h
//  sohunews
//
//  Created by wang yanchen on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v330)

- (void)migrateUpTo3_3_0_1; // create table for weibo hot channel
- (void)migrateUpTo3_3_0_2; //

//给订阅中心表tbSubscribeCenterAllSubscribe加isSelected字段，给新闻频道表tbNewsChannel表加isSelected字段
- (void)migrateUpTo3_3_0_3;

- (void)migrateUpTo3_3_0_4;

@end
