//
//  FmdbMigration+v530.m
//  sohunews
//
//  Created by ZhaoQing on 15/8/28.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_530.h"

@implementation FmdbMigration (v530)

- (void)migrateUpTo5_3_0 {
    // 订阅频道刊物提醒
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_UN_READ_COUNT columnType:@"Varchar"]
       forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    
    // 正文页下面相关股票
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_STOCKS columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];
    
    //天气详情相关
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEATHER_MORELINK columnType:@"Varchar"] forTableName:TB_WEATHER];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEATHER_COPYWRITING columnType:@"Varchar"] forTableName:TB_WEATHER];
}

@end
