//
//  SNDBMigrationManager_350.m
//  sohunews
//
//  Created by weibin cheng on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_350.h"

@implementation FmdbMigration(v350)
- (void)migrateUpTo3_5_0_0
{
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_PID  columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_ALERT columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_TYPE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_MSGID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_DATA_PID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_NICK_NAME columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_HEAD_URL columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_NOTIFICATION_TIME columnType:@"Varchar"],
                        nil];
    
    [self createTable:TB_NOTIFICATION withColumns:columns];
}

- (void)migrateUpTo3_5_0_1 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_SHARE_READ_CIRCLE_TYPE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SHARE_READ_CIRCLE_CONTENT_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_SHARE_READ_CIRCLE_JSON columnType:@"Varchar"],
                        nil];
    
    [self createTable:TB_SHARE_READ_CIRCLE withColumns:columns];
    NSString *sqlStr = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex   ON %@(%@,%@)",
                        TB_SHARE_READ_CIRCLE,
                        TB_SHARE_READ_CIRCLE,
                        TB_SHARE_READ_CIRCLE_TYPE,
                        TB_SHARE_READ_CIRCLE_CONTENT_ID];
    [self executeSQL:sqlStr];
}

- (void)migrateUpTo3_5_0_2 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_READCIRCLE_TIMELINE_SHARE_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_READCIRCLE_TIMELINE_TYPE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_READCIRCLE_TIMELINE_PID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_READCIRCLE_TIMELINE_JSON columnType:@"Varchar"],
                        nil];
    
    [self createTable:TB_READCIRCLE_TIMELINE withColumns:columns];
    NSString *sqlStr = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex   ON %@(%@,%@,%@)",
                        TB_READCIRCLE_TIMELINE,
                        TB_READCIRCLE_TIMELINE,
                        TB_READCIRCLE_TIMELINE_SHARE_ID,
                        TB_READCIRCLE_TIMELINE_TYPE,
                        TB_READCIRCLE_TIMELINE_PID];
    
    [self executeSQL:sqlStr];
}

- (void)migrateUpTo3_5_0_3 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCOMMENT_AUDIOPATH columnType:@"Varchar"] forTableName:TB_NEWSCOMMENT];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCOMMENT_AUDIODUR columnType:@"Varchar"] forTableName:TB_NEWSCOMMENT];
}

- (void)migrateUpTo3_5_0_4 {
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_PAPER_READFLAG_LINK2 columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_PAPER_READFLAG_READ columnType:@"Boolean"],
                        [FmdbMigrationColumn columnWithColumnName:TB_PAPER_READFLAG_CREATE columnType:@"Integer"],
                        nil];
    [self createTable:TB_PAPER_READFLAG withColumns:columns];
    NSString *sqlStr = [NSString stringWithFormat:@"CREATE UNIQUE INDEX %@UniqueIndex   ON %@(%@)",
                        TB_PAPER_READFLAG,
                        TB_PAPER_READFLAG,
                        TB_PAPER_READFLAG_LINK2];
    [self executeSQL:sqlStr];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCOMMENT_USER_CID columnType:@"Varchar"] forTableName:TB_NEWSCOMMENT];
}

- (void)migrateUpTo3_5_0_5 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSIMAGE_WIDTH columnType:@"Integer"] forTableName:TB_NEWSIMAGE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSIMAGE_HEIGHT columnType:@"Integer"] forTableName:TB_NEWSIMAGE];
}

- (void)migrateUpTo3_5_0_6 {
    // 订阅中心 增加link列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_STICKTOP columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    
    // 订阅中心 增加subShowType列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_BUTTONTXT columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

@end
