//
//  SNDBMigrationManager_315.m
//  sohunews
//
//  Created by wang yanchen on 12-10-31.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager_315.h"
#import "CacheDefines.h"

@implementation FmdbMigration(v315)

- (void)migrateUpTo3_1_5_1 {
    // add new table for votes
    [self createTable:TB_VOTES_INFO withColumns:[NSArray arrayWithObjects:
                                                 [FmdbMigrationColumn columnWithColumnName:TB_VOTES_NEWS_ID columnType:@"TEXT"],
                                                 [FmdbMigrationColumn columnWithColumnName:TB_VOTES_TOPIC_ID columnType:@"TEXT"],
                                                 [FmdbMigrationColumn columnWithColumnName:TB_VOTES_IS_VOTED columnType:@"TEXT"],
                                                 [FmdbMigrationColumn columnWithColumnName:TB_VOTES_XML_STR columnType:@"TEXT"],
                                                 nil]];
}

- (void)migrateUpTo3_1_5_2 {
    // add hasVote to table tbRollingNewsList
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_HASVOTE columnType:@"TEXT"] forTableName:TB_ROLLINGNEWSLIST];
}

- (void)migrateUpTo3_1_5_3 {
    // add isOver to table tbVotesInfo
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_VOTES_IS_OVER columnType:@"TEXT"] forTableName:TB_VOTES_INFO];
}

- (void)migrateUpTo3_1_5_4 {
    // add hasVideo to table tbSpecialNewsList
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SPECIALNEWSLIST_HAS_VIDEO columnType:@"TEXT"] forTableName:TB_SPECIALNEWSLIST];
}
@end
