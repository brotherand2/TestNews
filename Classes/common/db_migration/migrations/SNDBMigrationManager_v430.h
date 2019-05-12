//
//  SNDBMigrationManager_v430.h
//  sohunews
//
//  Created by jialei on 14-4-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration (v430)

- (void)migrateUpTo4_3_0_1;
- (void)migrateUpTo4_3_0_2;
- (void)migrateUpTo4_3_0_3;

@end
