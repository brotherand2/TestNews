//
//  SNDBMigrationManager_341.m
//  sohunews
//
//  Created by wang yanchen on 13-6-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_341.h"

@implementation FmdbMigration(v341)

// 正文 组图新闻 增加column subId
- (void)migrateUpTo3_4_1_1 {
    FmdbMigrationColumn *clm = [FmdbMigrationColumn columnWithColumnName:@"subId" columnType:@"Varchar"];
    [self addColumn:clm forTableName:TB_NEWSARTICLE];
    [self addColumn:clm forTableName:TB_GALLERY];
}

@end
