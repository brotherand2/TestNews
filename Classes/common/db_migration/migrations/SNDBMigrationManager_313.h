//
//  SNDBMigrationManager_313.h
//  sohunews
//
//  Created by handy wang on 8/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"

@interface FmdbMigration(v313)

- (void)migrateUpTo3_1_3_1;

- (void)migrateUpTo3_1_3_2;

- (void)migrateUpTo3_1_3_3;

@end