//
//  SNDBMigrationManager+v432.m
//  sohunews
//
//  Created by jialei on 14-7-28.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v432.h"

@implementation FmdbMigration (v432)

- (void)migrateUpTo4_3_2_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SHARE_UGCWORDLIMIT columnType:@"integer"] forTableName:TB_VIDEO_TIMELINE];
    
}

- (void)migrateUpTo4_3_2_2
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_FAVOUR columnType:@"integer"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo4_3_2_3
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADTYPE columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADABPOSITION columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADPOSITION columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADREFRESHCOUNT columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADLOADMORECOUNT columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADSCOP columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADAPPCHANNEL columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADNEWSCHANNEL columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}

- (void)migrateUpTo4_3_2_4
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_LINK columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
}

- (void)migrateUpTo4_3_2_5
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_NEWSTYPE columnType:@"integer"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_H5LINK columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo4_3_2_6
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_OPENTYPE columnType:@"integer"] forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo4_3_2_7
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_AD_LIST_ADID columnType:@"Varchar"]
       forTableName:TB_SUB_CENTER_AD_LIST];
}

- (void)migrateUpTo4_3_2_8
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEATHER_SHARECONTENT columnType:@"Varchar"] forTableName:TB_WEATHER];

}

- (void)migrateUpTo4_3_2_9
{
     [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_UNINTERINST columnType:@"integer"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_BANNER_DATA columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_ENTRY_DATA columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo4_3_2_10 {
    NSString *updateNewsChannelTableDefaultData = @"update tbNewsChannel set name='首页' where channelID='1'";
    [self executeSQL:updateNewsChannelTableDefaultData];
}

@end
