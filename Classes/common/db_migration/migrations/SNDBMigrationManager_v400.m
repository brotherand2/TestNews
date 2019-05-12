//
//  SNDBMigrationManager_v400.m
//  sohunews
//
//  Created by Gao Yongyue on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v400.h"
#import "CacheDefines.h"

@implementation FmdbMigration (v400)
- (void)migrateUpTo4_0_0_1
{
    //添加断点续播的表
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ Varchar PRIMARY KEY, \
                     %@ Double DEFAULT NULL,\
                     %@ Double DEFAULT NULL,\
                     %@ integer DEFAULT NULL)",
                     TB_VIDEO_BREAKPOINT,
                     TB_VIDEO_BREAKPOINT_VID,
                     TB_VIDEO_BREAKPOINT_BREAKPOINT,
                     TB_VIDEO_BREAKPOINT_CREATE,
                     TB_VIDEO_BREAKPOINT_CONTEXT];
    
    [self executeSQL:sql];
    
    NSString *sqlStr = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex ON %@(%@)",
                        TB_VIDEO_BREAKPOINT,
                        TB_VIDEO_BREAKPOINT,
                        TB_VIDEO_BREAKPOINT_VID];
    [self executeSQL:sqlStr];
}

- (void)migrateUpTo4_0_0_2 {
    
    //修改tbNewsChannel表，加了两个字段；
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_CURRPOSITION columnType:@"TEXT"] forTableName:TB_NEWSCHANNEL];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_LOCALTYPE columnType:@"TEXT"] forTableName:TB_NEWSCHANNEL];
    
}

// 创建广告数据表
- (void)migrateUpTo4_0_0_3 {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL)",
                     TB_AD_INFO_TABLE,
                     TB_AD_INFO_ID,
                     TB_AD_INFO_TYPE,
                     TB_AD_INFO_DATA_ID,
                     TB_AD_INFO_CATEGORY_ID,
                     TB_AD_INFO_JSON_STRING];
    
    [self executeSQL:sql];
    
    sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex   ON %@(%@,%@,%@)",
           TB_AD_INFO_TABLE,
           TB_AD_INFO_TABLE,
           TB_AD_INFO_TYPE,
           TB_AD_INFO_DATA_ID,
           TB_AD_INFO_CATEGORY_ID];
    
    [self executeSQL:sql];
}

- (void)migrateUpTo4_0_0_4 {
    //视频Tab Timeline缓存mediaLink
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_MEDIALINK columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo4_0_0_5 {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     id integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL)",
                     
                     TB_VIDEO_PLAYINOFFLINE,
                     
                     CL_VIDEO_PLAYINOFFLINE_VID,
                     CL_VIDEO_PLAYINOFFLINE_CHANNEL_ID,
                     CL_VIDEO_PLAYINOFFLINE_MESSAGE_ID,
                     CL_VIDEO_PLAYINOFFLINE_TITLE,
                     CL_VIDEO_PLAYINOFFLINE_SUBTITLE,
                     CL_VIDEO_PLAYINOFFLINE_COLUMN_NAME,
                     CL_VIDEO_PLAYINOFFLINE_AUTHOR_TYPE,
                     CL_VIDEO_PLAYINOFFLINE_AUTHOR_NAME,
                     CL_VIDEO_PLAYINOFFLINE_SITE_NAME,
                     CL_VIDEO_PLAYINOFFLINE_POSTER,
                     CL_VIDEO_PLAYINOFFLINE_VIDEO_LINK2,
                     CL_VIDEO_PLAYINOFFLINE_PLAY_TYPE,
                     CL_VIDEO_PLAYINOFFLINE_VIDEO_URL_FOR_PLAYING_IN_NATIVE_PLAYER,
                     CL_VIDEO_PLAYINOFFLINE_VIDEO_URL_FOR_PLAYING_IN_INNER_WEB,
                     CL_VIDEO_PLAYINOFFLINE_MEDIA_LINK,
                     CL_VIDEO_PLAYINOFFLINE_CONTENT_FOR_SHARING_SHOW,
                     CL_VIDEO_PLAYINOFFLINE_CONTENT_FOR_SHARING_TO,
                     CL_VIDEO_PLAYINOFFLINE_H5_URL_FOR_SHARING_TO
                     ];
    [self executeSQL:sql];
}

// 创建直播邀请表
- (void)migrateUpTo4_0_0_6 {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ integer DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ integer DEFAULT NULL)",
                     TB_LIVE_INVITE,
                     TB_LIVE_INDEX,
                     TB_LIVE_INVITE_LIVEID,
                     TB_LIVE_INVITE_PASSPORT,
                     TB_LIVE_INVITE_STATUS,
                     TB_LIVE_INVITE_SHOWMSG,
                     TB_LIVE_INVITE_CREATE];
    
    [self executeSQL:sql];
    
    sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex   ON %@(%@,%@)",
           TB_LIVE_INVITE,
           TB_LIVE_INVITE,
           TB_LIVE_INVITE_LIVEID,
           TB_LIVE_INVITE_PASSPORT];
    
    [self executeSQL:sql];
}

- (void)migrateUpTo4_0_0_7 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SITE_ID columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

//增加信息流天气信息字段
- (void)migrateUpTo4_0_0_8 {
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ISWEATHER
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_CITY
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TEMPHIGH
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TEMPLOW
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_WEATHER
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_WEATHERIOC
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ISRECOM
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_RECOMTYPE
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_LIVESTATUS
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_LOCAL
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_WIND
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_THIRDPARTURL
                                                   columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
}

//article增加外网logo
- (void)migrateUpTo4_0_0_9 {
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_LOGOURL
                                                   columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];
}

- (void)migrateUpTo4_0_0_10 {
    //---视频Timeline App换量相关
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_APPCONTENT columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

@end
