//
//  SNDBMigrationManager+v420.m
//  sohunews
//
//  Created by jialei on 14-4-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v430.h"
#import "CacheDefines.h"

@implementation FmdbMigration (v430)

- (void)migrateUpTo4_3_0_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTREAD columnType:@"integer"] forTableName:TB_GALLERY];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTREAD columnType:@"integer"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo4_3_0_2 {
    // 1 sub ad list + type
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_TYPE columnType:@"Varchar"] forTableName:TB_SUB_CENTER_AD_LIST];
    
    // 2 sub table + topNewsAbstract & topNewsLink & topNewsPicsString & sortIndex
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_ABSTRACT columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_LINK columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOP_NEWS_PICS columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}
- (void)migrateUpTo4_3_0_3
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TEMPLATEID columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TEMPLATETYPE columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_PLAYTIME columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_LIVETYPE columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ISFLASH columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TOKEN columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_DATASTRING columnType:@"TEXT"] forTableName:TB_ROLLINGNEWSLIST];
}

@end
