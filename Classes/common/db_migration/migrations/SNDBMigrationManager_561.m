//
//  SNDBMigrationManager_561.m
//  sohunews
//
//  Created by wangyy on 16/6/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_561.h"

@implementation  FmdbMigration (v561)

- (void)migrateUpTo5_6_1{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_SITE columnType:@"integer"]
       forTableName:TB_ROLLINGNEWSLIST];
}

@end
