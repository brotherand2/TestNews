//
//  SNDBMigrationManager_v360.m
//  sohunews
//
//  Created by Dan Cong on 9/11/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v360.h"

@implementation FmdbMigration(v360)

- (void)migrateUpTo3_6_0_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_ACTION columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_IS_PUBLISH columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_EDIT_LINK columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo3_6_0_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SHOW_COMMENT columnType:@"Varchar"]
       forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SHOW_RECOMMEND_SUB columnType:@"Varchar"]
       forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

- (void)migrateUpTo3_6_0_3
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_OPERATORS columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
}

@end
