//
//  FmdbMigration+v552.m
//  sohunews
//
//  Created by Scarlett on 16/4/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_552.h"

@implementation FmdbMigration (v552)

- (void)migrateUpTo5_5_2 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_CATEGORY_NAME columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_CATEGORY_ID columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_ICON_FLAG columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
}

@end
