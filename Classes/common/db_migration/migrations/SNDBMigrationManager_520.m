//
//  SNDBMigrationManager_520.m
//  sohunews
//
//  Created by Xiang Wei Jia on 4/17/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_520.h"

@implementation FmdbMigration (v520)

- (void)migrateUpTo5_2_0
{
    // 增加新闻列表的gbcode
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_GBCODE columnType:@"Varchar"]
       forTableName:TB_NEWSCHANNEL];
    
    // 直播列表的判断独家字段
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_LIVING_GAME_PUB_TYPE columnType:@"Varchar"]
       forTableName:TB_LIVING_GAME];
    
    // 图文正文页独家字段
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_NEWSMARK columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];

    // 图文正文页来源
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_ORIGINFROM columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];
    
    // 正文页下面频道推广位
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSARTICLE_TAGCHANNELS columnType:@"Varchar"]
       forTableName:TB_NEWSARTICLE];

    //新闻列表页 每个news加subid 为SNS分享视频的需求加的  
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_SUBID columnType:@"Varchar"]
       forTableName:TB_ROLLINGNEWSLIST];
    
    // 组图新闻正文页独家字段
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_NEWSMARK columnType:@"Varchar"]
       forTableName:TB_GALLERY];
    
    // 组图新闻正文页来源
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_ORIGINFROM columnType:@"Varchar"]
       forTableName:TB_GALLERY];

}

@end
