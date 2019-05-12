//
//  SNDBMigrationManager_560.m
//  sohunews
//
//  Created by cuiliangliang on 16/5/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_560.h"

@implementation  FmdbMigration (v560)
- (void)migrateUpTo5_6_0{

    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TVPLAYNUM columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TVPLAYTIME columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_VID columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_TVURL columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_SOURCENAME columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];

}
@end
