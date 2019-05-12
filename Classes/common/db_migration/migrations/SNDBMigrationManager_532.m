//
//  FmdbMigration+v532.m
//  sohunews
//
//  Created by wangyy on 15/12/3.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_532.h"

@implementation FmdbMigration (v532)

- (void)migrateUpTo5_3_2 {
    // 增加置顶新闻标记
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TOPNEWS columnType:@"integer"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    // 流式频道最新新闻标志
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_LATEST columnType:@"integer"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    //新增频道接口版本号
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_SERVERVERSION columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
}

@end
