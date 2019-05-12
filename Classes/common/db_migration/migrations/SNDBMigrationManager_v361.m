//
//  SNDBMigrationManager_v361.m
//  sohunews
//
//  Created by Dan Cong on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v361.h"

@implementation FmdbMigration(v361)

- (void)migrateUpTo3_6_1_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_MEDIA columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}

@end