//
//  SNDBMigrationManager_v431.m
//  sohunews
//
//  Created by chenhong on 14-6-18.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v431.h"

@implementation SNDBMigrationManager (v431)

- (void)migrateUpTo4_3_1_1
{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_POSITION columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEATHER_PM25 columnType:@"Varchar"] forTableName:TB_WEATHER];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEATHER_QUALITY columnType:@"Varchar"] forTableName:TB_WEATHER];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_PM25 columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_QUALITY columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}

- (void)migrateUpTo4_3_1_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_STATSTYPE columnType:@"integer"] forTableName:TB_ROLLINGNEWSLIST];
}

@end