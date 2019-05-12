//
//  SNDBMigrationManager_314.m
//  sohunews
//
//  Created by handy wang on 9/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager_314.h"
#import "CacheDefines.h"

@implementation FmdbMigration(v314)

- (void)migrateUpTo3_1_4_1 {

    [self createTable:TB_RECOMMEND_NEWS withColumns:[NSArray arrayWithObjects:
                                                     [FmdbMigrationColumn columnWithColumnName:TB_NEWS_TITLE columnType:@"Varchar"],
                                                     [FmdbMigrationColumn columnWithColumnName:TB_NEWS_LINK columnType:@"Varchar"],
                                                     [FmdbMigrationColumn columnWithColumnName:TB_RELATED_NEWSID columnType:@"Varchar"],
                                                     nil]
     ];

}

@end