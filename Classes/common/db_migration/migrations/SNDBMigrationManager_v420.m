//
//  SNDBMigrationManager_v420.m
//  sohunews
//
//  Created by Gao Yongyue on 14-3-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v420.h"
#import "CacheDefines.h"

@implementation FmdbMigration (v420)

- (void)migrateUpTo4_2_0_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:@"width" columnType:@"Float"] forTableName:@"tbPhoto"];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:@"height" columnType:@"Float"] forTableName:@"tbPhoto"];
}

- (void)migrateUpTo4_2_0_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SITE columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SITE2 columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_PLAYBYID columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_PLAYAD columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_ADSERVER columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo4_2_0_3
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_ISRECOM columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_TIPS columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_TIPSINTERVAL columnType:@"integer"] forTableName:TB_NEWSCHANNEL];

}

- (void)migrateUpTo4_2_0_4 {
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_DATE
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_LOCALIOC
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
}

- (void)migrateUpTo4_2_0_5 {
    //直播一级列表数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_LIVING_GAME, TB_LIVING_GAME_MEDIA_TYPE]];
}

@end
