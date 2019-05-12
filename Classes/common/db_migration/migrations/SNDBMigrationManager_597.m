//
//  FmdbMigration+v597.m
//  sohunews
//
//  Created by wangyy on 2017/11/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_597.h"

@implementation FmdbMigration (v597)

- (void)migrateUpTo5_9_7 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TRAINCARDID columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
  
    [self executeSQL:@"DROP INDEX tbRollingNewsUniqueIndex"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbRollingNewsUniqueIndex    ON tbRollingNewsList(channelId,newsId,trainCardId)"];
}

@end
