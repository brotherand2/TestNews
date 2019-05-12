//
//  SNDBMigrationManager_v371.h
//  sohunews
//
//  Created by chenhong on 13-11-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration (v371)

- (void)migrateUpTo3_7_1_1;
- (void)migrateUpTo3_7_1_2;
- (void)migrateUpTo3_7_1_3;
- (void)migrateUpTo3_7_1_4;
- (void)migrateUpTo3_7_1_5;
- (void)migrateUpTo3_7_1_6;

@end