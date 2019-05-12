//
//  SNDBMigrationManager_v401.h
//  sohunews
//
//  Created by chenhong on 14-1-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration (v401)

- (void)migrateUpTo4_0_1_1;
- (void)migrateUpTo4_0_1_2;
- (void)migrateUpTo4_0_1_3;
@end
