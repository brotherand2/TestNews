//
//  SNDBMigrationManager_v371.m
//  sohunews
//
//  Created by chenhong on 13-11-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v371.h"

@implementation FmdbMigration (v371)

- (void)migrateUpTo3_7_1_1 {
    // 添加直播分类表
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ Varchar PRIMARY KEY DEFAULT NULL, \
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL)",
                     TB_LIVE_CATEGORY,
                     //TB_LIVE_CATEGORY_INDEX,
                     TB_LIVE_CATEGORY_SUBID,
                     TB_LIVE_CATEGORY_NAME,
                     TB_LIVE_CATEGORY_LINK];
    
    [self executeSQL:sql];
    
    if ([self.db hadError]) {
        SNDebugLog(@"migrateUpTo3_7_1_1 : executeUpdate error: %d, %@",
                   [self.db lastErrorCode],
                   [self.db lastErrorMessage]);
    }
}

- (void)migrateUpTo3_7_1_2
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTHINT columnType:@"Varchar"] forTableName:TB_GALLERY];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTSTATUS columnType:@"Varchar"] forTableName:TB_GALLERY];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTHINT columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTSTATUS columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTHINT columnType:@"Varchar"] forTableName:TB_WEIBOHOT_DETAIL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_CMTSTATUS columnType:@"Varchar"] forTableName:TB_WEIBOHOT_DETAIL];
}

- (void)migrateUpTo3_7_1_3 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_DURATION columnType:@"integer"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo3_7_1_4 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_MULTIPLETYPE columnType:@"integer"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_TEMPLATEPIC columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_PIC_4_3 columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo3_7_1_5 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_CONTENT columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo3_7_1_6 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_PLAYTYPE columnType:@"integer"] forTableName:TB_VIDEO_TIMELINE];
}

@end