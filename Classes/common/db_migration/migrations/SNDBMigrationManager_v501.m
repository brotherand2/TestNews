//
//  SNDBMigrationManager_v501.m
//  sohunews
//
//  Created by yangln on 14-12-22.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v501.h"

@implementation FmdbMigration (v501)

- (void)migrateUpTo5_1_0_1 {
    //5.1增加新列统计累计阅读数或累计播放数
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_COUNT_SHOW_TEXT columnType:@"Varchar"]
       forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    
    // 增加广告曝光记录
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ADREPORTSTATE columnType:@"integer"]
       forTableName:TB_ROLLINGNEWSLIST];
}

@end
