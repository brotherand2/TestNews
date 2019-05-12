//
//  SNDBMigrationManager_v370.m
//  sohunews
//
//  Created by handy wang on 9/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v370.h"

@implementation FmdbMigration(v370)

- (void)migrateUpTo3_7_0_0 {
    //添加视频下载表
    NSString *sqlOfCreatingDownloadedVideosTable = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                                                    %@ integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL, \
                                                    %@ Varchar DEFAULT NULL, \
                                                    %@ Varchar DEFAULT NULL, \
                                                    %@ Varchar DEFAULT NULL, \
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL,\
                                                    %@ Varchar DEFAULT NULL)",
                                                    TB_VIDEOS_DOWNLOAD,
                                                    TB_VIDEOS_DOWNLOAD_ID,
                                                    TB_VIDEOS_DOWNLOAD_VID,
                                                    TB_VIDEOS_DOWNLOAD_NAME,
                                                    TB_VIDEOS_DOWNLOAD_POSTER,
                                                    TB_VIDEOS_DOWNLOAD_VIDEO_SOURCES,
                                                    TB_VIDEOS_DOWNLOAD_DOWNLOADURL,
                                                    TB_VIDEOS_DOWNLOAD_VIDEOTYPE,
                                                    TB_VIDEOS_DOWNLOAD_LOCAL_RELATIVEPATH,
                                                    TB_VIDEOS_DOWNLOAD_LOCAL_M3U8URL,
                                                    TB_VIDEOS_DOWNLOAD_STATE,
                                                    TB_VIDEOS_DOWNLOAD_TOTALBYTES,
                                                    TB_VIDEOS_DOWNLOAD_BEGIN_DOWNLOAD_TIMEINTERVAL,
                                                    TB_VIDEOS_DOWNLOAD_FINISH_DOWNLOAD_TIMEINTERVAL];
    [self executeSQL:sqlOfCreatingDownloadedVideosTable];
    
    //添加视频下载进度表
    [self executeSQL:@"CREATE TABLE tbVideosDownload_segments (id INTEGER  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,segmentOrder INTEGER DEFAULT NULL,urlString Varchar DEFAULT NULL,duration INTEGER DEFAULT NULL,downloadBytes Varchar DEFAULT NULL,totalBytes Varchar DEFAULT NULL,state Varchar DEFAULT NULL,videoType Varchar DEFAULT NULL,vid Varchar);"];
}

- (void)migrateUpTo3_7_0_1 {
    // 添加视频频道timeline表
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ integer DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ integer DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL)",
                     TB_VIDEO_TIMELINE,
                     TB_VIDEO_TIMELINE_INDEX,
                     TB_VIDEO_TIMELINE_CHANNELID,
                     TB_VIDEO_TIMELINE_ID,
                     TB_VIDEO_TIMELINE_VID,
                     TB_VIDEO_TIMELINE_COLUMN_ID,
                     TB_VIDEO_TIMELINE_COLUMN_NAME,
                     TB_VIDEO_TIMELINE_PIC,
                     TB_VIDEO_TIMELINE_URL,
                     TB_VIDEO_TIMELINE_TITLE,
                     TB_VIDEO_TIMELINE_PLAYURL_MP4S,
                     TB_VIDEO_TIMELINE_PLAYURL_MP4,
                     TB_VIDEO_TIMELINE_PLAYURL_M3U8,
                     TB_VIDEO_TIMELINE_AUTHOR_NAME,
                     TB_VIDEO_TIMELINE_AUTHOR_ID,
                     TB_VIDEO_TIMELINE_AUTHOR_TYPE,
                     TB_VIDEO_TIMELINE_AUTHOR_ICON,
                     TB_VIDEO_TIMELINE_SITE_NAME,
                     TB_VIDEO_TIMELINE_LINK2];
    [self executeSQL:sql];
}

- (void)migrateUpTo3_7_0_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_DOWNLOAD columnType:@"integer"] forTableName:TB_VIDEO_TIMELINE];
}

- (void)migrateUpTo3_7_0_3 {
    // 添加视频频道表
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL)",
                     TB_VIDEO_CHANNEL,
                     TB_VIDEO_CHANNEL_INDEX,
                     TB_VIDEO_CHANNEL_ID,
                     TB_VIDEO_CHANNEL_STATUS,
                     TB_VIDEO_CHANNEL_SORT,
                     TB_VIDEO_CHANNEL_TITLE,
                     TB_VIDEO_CHANNEL_CTIME,
                     TB_VIDEO_CHANNEL_UTIME,
                     TB_VIDEO_CHANNEL_DESCN];
    
    [self executeSQL:sql];
    
    //插入"热播"频道
    sql = [NSString stringWithFormat:@"INSERT INTO %@ (\
                     %@,%@,%@,%@,%@,%@,%@,%@ \
                     ) VALUES (NULL,?,?,?,?,?,?,?)",
                     TB_VIDEO_CHANNEL,
                     TB_VIDEO_CHANNEL_INDEX,
                     TB_VIDEO_CHANNEL_ID,
                     TB_VIDEO_CHANNEL_STATUS,
                     TB_VIDEO_CHANNEL_SORT,
                     TB_VIDEO_CHANNEL_TITLE,
                     TB_VIDEO_CHANNEL_CTIME,
                     TB_VIDEO_CHANNEL_UTIME,
                     TB_VIDEO_CHANNEL_DESCN
                     ];
    
    [self.db executeUpdate:sql, @"1", @"0", @"0", @"热播", @"0", @"0", @"热播"];
    [self.db executeUpdate:sql, @"13", @"0", @"0", @"搞笑", @"0", @"0", @"搞笑内容"];
    [self.db executeUpdate:sql, @"12", @"0", @"0", @"娱乐", @"0", @"0", @"娱乐、综艺、八卦"];
    [self.db executeUpdate:sql, @"15", @"0", @"0", @"体育", @"0", @"0", @"各类竞技项目"];
    [self.db executeUpdate:sql, @"18", @"0", @"0", @"剧集", @"0", @"0", @"电视热播剧"];
    [self.db executeUpdate:sql, @"20", @"0", @"0", @"美剧", @"0", @"0", @"精彩美剧"];
    [self.db executeUpdate:sql, @"22", @"0", @"0", @"电影", @"0", @"0", @"高清电影大片"];
    [self.db executeUpdate:sql, @"16", @"0", @"0", @"原创", @"0", @"0", @"自媒体、自制节目"];
    [self.db executeUpdate:sql, @"21", @"0", @"0", @"综艺", @"0", @"0", @"综艺娱乐"];
    [self.db executeUpdate:sql, @"19", @"0", @"0", @"游戏", @"0", @"0", @"游戏"];
    
    if ([self.db hadError]) {
        SNDebugLog(@"migrateUpTo3_7_0_3 : executeUpdate error: %d, %@",
                   [self.db lastErrorCode],
                   [self.db lastErrorMessage]);
    }
}

//组图进频道，添加打开用的二代协议sublink
- (void)migrateUpTo3_7_0_4 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GROUPPHOTO_SUBLINK columnType:@"Varchar"] forTableName:TB_GROUPPHOTO];
}

// 视频timeline添加分享数据
- (void)migrateUpTo3_7_0_5 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SHARE_CONTENT columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VIDEO_TIMELINE_SHARE_H5URL columnType:@"Varchar"] forTableName:TB_VIDEO_TIMELINE];
}

// 添加热播栏目
- (void)migrateUpTo3_7_0_6 {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                     %@ integer PRIMARY KEY AUTOINCREMENT DEFAULT NULL, \
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL,\
                     %@ Varchar DEFAULT NULL)",
                     TB_VIDEO_COLUMN,
                     TB_VIDEO_COLUMN_INDEX,
                     TB_VIDEO_COLUMN_ID,
                     TB_VIDEO_COLUMN_TITLE,
                     TB_VIDEO_COLUMN_READ_COUNT,
                     TB_VIDEO_COLUMN_IS_SUB];
    
    [self executeSQL:sql];
    
    sql = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex   ON %@(%@)",
                        TB_VIDEO_COLUMN,
                        TB_VIDEO_COLUMN,
                        TB_VIDEO_COLUMN_ID];
    [self executeSQL:sql];
}

//新闻正文推荐增加推广信息字段
- (void)migrateUpTo3_7_0_7
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWS_TYPE columnType:@"Varchar"] forTableName:TB_RECOMMEND_NEWS];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWS_ICON columnType:@"Varchar"] forTableName:TB_RECOMMEND_NEWS];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWS_ICON_NIGHT columnType:@"Varchar"] forTableName:TB_RECOMMEND_NEWS];
}

@end