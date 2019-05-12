//
//  FmdbMigration+v581.m
//  sohunews
//
//  Created by yangln on 2016/12/13.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_581.h"

@implementation FmdbMigration (v581)
- (void)migrateUpTo5_8_1 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_NEWSTYPETEXT columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}
@end
