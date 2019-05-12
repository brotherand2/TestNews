//
//  FmdbMigration+v531.m
//  sohunews
//
//  Created by 赵青 on 15/11/30.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_531.h"

@implementation FmdbMigration (v531)

- (void)migrateUpTo5_3_1 {
    // 图文正文页原标题
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_ORIGINTITLE columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];

}

@end
