//
//  FmdbMigration+v541.m
//  sohunews
//
//  Created by wangyy on 15/1/6.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_541.h"

@implementation FmdbMigration (v541)

- (void)migrateUpTo5_4_1 {
    // 天气模版字段
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_WEAK columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    // 天气模版字段
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_LIVETEMPERTURE columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
}

@end
