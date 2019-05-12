//
//  SNDBMigrationManager_315.h
//  sohunews
//
//  Created by wang yanchen on 12-10-31.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v315)

- (void)migrateUpTo3_1_5_1;
- (void)migrateUpTo3_1_5_2;
- (void)migrateUpTo3_1_5_3;
- (void)migrateUpTo3_1_5_4;

@end
