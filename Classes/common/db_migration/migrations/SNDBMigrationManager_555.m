//
//  FmdbMigration+v555.m
//  sohunews
//
//  Created by wangyy on 16/3/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_555.h"

@implementation FmdbMigration (v555)

- (void)migrateUpTo5_5_5 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_REDPACKETTITLE columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_REDPACKETBGPIC columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_REDPACKETSPONSORICON columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_REDPACKETBID columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GROUPPHOTO_SUBLINK columnType:@"Varchar"]
       forTableName:TB_GROUPPHOTO];
}

@end
