//
//  SNDBMigrationManager_320.m
//  sohunews
//
//  Created by wang yanchen on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager_320.h"
#import "CacheDefines.h"

@implementation FmdbMigration(v320)

- (void)migrateUpTo3_2_0_1 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_DEFAULT_SUB columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SUB_ID columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SUB_NAME columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SUB_ICON columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SUB_INFO columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_MORE_INFO columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_PUB_IDS columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TERM_ID columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_LAST_TERM_LINK columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_IS_PUSH columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_DEFAULT_PUSH columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_PERSON_COUNT columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOP_NEWS columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOP_NEWS2 columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_IS_DOWNLOADED columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_IS_TOP columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TOP_TIME columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_INDEX_VALUE columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_GRADE_LEVEL columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_COMMENT_COUNT columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_OPEN_TIMES columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_BACK_PROMOTION columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_TEMPLATE_TYPE columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_IS_ON_RANK columnType:@"Varchar" defaultValue:@""],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_STATUS columnType:@"Varchar" defaultValue:@""],
                        nil];
    
    [self createTable:TB_SUB_CENTER_ALL_SUBSCRIBE withColumns:columns];
}

- (void)migrateUpTo3_2_0_2 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_TYPES_TYPE_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_TYPES_TYPE_NAME columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_TYPES_TYPE_ICON columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_TYPES_SUB_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_TYPES_SUB_NAME columnType:@"Varchar"],
                        nil];
    
    [self createTable:TB_SUB_CENTER_SUB_TYPES withColumns:columns];
}

- (void)migrateUpTo3_2_0_3 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_RELATION_TYPE_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_RELATION_SUB_ID columnType:@"Varchar"],
                        nil];
    
    [self createTable:TB_SUB_CENTER_RELATION_SUB_TYPE withColumns:columns];
}

- (void)migrateUpTo3_2_0_4 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_AD_NAME columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_AD_IMG columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_AD_TYPE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_REF_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_REF_TEXT columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_REF_LINK columnType:@"Varchar"],
                        nil];
    [self createTable:TB_SUB_CENTER_AD_LIST withColumns:columns];
}

// create table for sub comment list
- (void)migrateUpTo3_2_0_5 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_SUB_COMMENT_SUB_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_SUB_COMMENT_AUTHOR columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_SUB_COMMENT_CTIME columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_SUB_COMMENT_CONTENT columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_SUB_COMMENT_STAR_GRADE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_SUB_COMMENT_CITY columnType:@"Varchar"],
                        nil];
    [self createTable:TB_SUB_CENTER_SUB_COMMENT withColumns:columns];
}

@end
