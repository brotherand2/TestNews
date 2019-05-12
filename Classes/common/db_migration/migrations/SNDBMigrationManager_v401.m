//
//  SNDBMigrationManager_v401.m
//  sohunews
//
//  Created by chenhong on 14-1-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v401.h"
#import "CacheDefines.h"

@implementation FmdbMigration (v401)

- (void)migrateUpTo4_0_1_1 {
    
    //修改TB_VIDEO_CHANNEL表，加了两个字段sortable, up
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_CHANNEL_SORTABLE columnType:@"Varchar"] forTableName:TB_VIDEO_CHANNEL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_CHANNEL_UP columnType:@"Varchar"] forTableName:TB_VIDEO_CHANNEL];
    
    //Rename 'name' to 'title'
    [self dropColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEOS_DOWNLOAD_NAME columnType:@"Varchar"] forTableName:TB_VIDEOS_DOWNLOAD];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEOS_DOWNLOAD_TITLE columnType:@"Varchar"] forTableName:TB_VIDEOS_DOWNLOAD];
}

- (void)migrateUpTo4_0_1_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SMALL_PIC columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_OFFLINE_PLAY columnType:@"Boolean"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_FINISH_DOWNLOAD_TIMEINTERVAL columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_LINKURL
                                                   columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];
}

//天气增加gbcode
- (void)migrateUpTo4_0_1_3 {
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_GBCODE
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
}

@end
