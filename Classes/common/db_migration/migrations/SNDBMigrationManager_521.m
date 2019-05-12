//
//  FmdbMigration+v521.m
//  sohunews
//
//  Created by yangln on 15/7/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_521.h"

@implementation FmdbMigration (v521)

- (void)migrateUpTo5_2_1 {
    // 分享列表openId
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SHARE_OPENID columnType:@"Varchar"]
       forTableName:TB_SHARE_LIST];
}

@end
