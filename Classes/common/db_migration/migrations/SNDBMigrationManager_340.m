//
//  SNDBMigrationManager_340.m
//  sohunews
//
//  Created by wang yanchen on 13-4-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_340.h"

@implementation FmdbMigration(v340)

- (void)migrateUpTo3_4_0_1 {
    // 订阅中心 增加link列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_LINK columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    
    // 订阅中心 增加subShowType列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

// 搜索历史
- (void)migrateUpTo3_4_0_2 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SEARCH_HISTORY_CONTENT columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SEARCH_HISTORY_TIME columnType:@"Double"],
                        nil];
    
    [self createTable:TB_SEARCH_HISTORY withColumns:columns];
    
    [self executeSQL:@"CREATE UNIQUE INDEX tbSearchHistoryUniqueIndex ON tbSearchHistory(content)"];
}

//新闻正文增加音频支持
- (void)migrateUpTo3_4_0_3 {
    [self executeSQL:@"CREATE TABLE tbNewsAudio (ID integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,termId Varchar DEFAULT NULL,newsId Varchar,audioId Varchar DEFAULT NULL,name Varchar DEFAULT NULL,url Varchar,playTime Varchar,size Varchar)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbNewsAudioUniqueIndex ON tbNewsAudio(termId,newsId,url)"];
}

- (void)migrateUpTo3_4_0_4 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCOMMENT_IMAGEPATH columnType:@"Varchar"] forTableName:TB_NEWSCOMMENT];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCOMMENT_AUTHORIMAGE columnType:@"Varchar"] forTableName:TB_NEWSCOMMENT];
}

// 报纸添加publishTime
- (void)migrateUpTo3_4_0_5 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSPAPER_PUBLISHTIME columnType:@"Varchar"] forTableName:TB_NEWSPAPER];
}

// 即时新闻 增加音频字段
- (void)migrateUpTo3_4_0_6 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_HASAUDIO columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}

@end
