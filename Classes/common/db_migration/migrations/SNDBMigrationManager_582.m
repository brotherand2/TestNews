//
//  FmdbMigration+v582.m
//  sohunews
//
//  Created by yangln on 2016/12/23.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_582.h"

@implementation FmdbMigration (v582)

- (void)migrateUpTo5_8_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_SHOWTYPE columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
}

@end
