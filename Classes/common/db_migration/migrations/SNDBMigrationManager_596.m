//
//  FmdbMigration+v596.m
//  sohunews
//
//  Created by wangyy on 2017/9/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_596.h"

@implementation FmdbMigration (v596)

- (void)migrateUpTo5_9_6 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_RECOMINFO columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_ISMIXSTREAM columnType:@"integer"] forTableName:TB_NEWSCHANNEL];
}

@end
