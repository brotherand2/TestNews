//
//  SNDBMigrationManager_v500.m
//  sohunews
//
//  Created by weibin cheng on 14-9-25.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v500.h"

@implementation FmdbMigration (v500)

- (void)migrateUpTo5_0_0_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_FAVICON columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo5_0_0_2
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_H5LINK columnType:@"Varchar"] forTableName:TB_GALLERY];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_FAVICON columnType:@"Varchar"] forTableName:TB_GALLERY];
}

- (void)migrateUpTo5_0_0_3
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_MOREPAGENUM columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_HASSPONSORSHIPS columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ICONTEXT columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_SPONSORSHIPS columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_CURSOR columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}

- (void)migrateUpTo5_0_0_4
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOPNEWS columnType:@"Varchar"]
       forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

- (void)migrateUpTo5_0_0_5
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_MEDIANAME columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_MEDIALINK columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo5_0_0_6
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_MEDIANAME columnType:@"Varchar"] forTableName:TB_GALLERY];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_MEDIALINK columnType:@"Varchar"] forTableName:TB_GALLERY];
}

- (void)migrateUpTo5_0_0_7
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_OPTIMIZEREAD columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
}
@end
