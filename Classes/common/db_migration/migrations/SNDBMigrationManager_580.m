//
//  FmdbMigration+v576.m
//  sohunews
//
//  Created by sohu on 16/11/14.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_580.h"

@implementation FmdbMigration (v580)

- (void)migrateUpTo5_8_0{
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_RECOMREASONS columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_RECOMTIME columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_BLUETITLE columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
}

@end
