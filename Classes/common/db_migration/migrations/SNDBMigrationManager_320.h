//
//  SNDBMigrationManager_320.h
//  sohunews
//
//  Created by wang yanchen on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v320)

// create table for all subscribe
- (void)migrateUpTo3_2_0_1;

// create table for sub type list
- (void)migrateUpTo3_2_0_2;

// create relation table for all sub and sub types
- (void)migrateUpTo3_2_0_3;

// create table for sub home ad list
- (void)migrateUpTo3_2_0_4;

// create table for sub comment list
- (void)migrateUpTo3_2_0_5;

@end
