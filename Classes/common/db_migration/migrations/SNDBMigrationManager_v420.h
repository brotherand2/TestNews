//
//  SNDBMigrationManager_v420.h
//  sohunews
//
//  Created by Gao Yongyue on 14-3-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration (v420)

- (void)migrateUpTo4_2_0_1;
- (void)migrateUpTo4_2_0_2;
- (void)migrateUpTo4_2_0_3;
- (void)migrateUpTo4_2_0_4;

@end