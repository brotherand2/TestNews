//
//  SNDBMigrationManager_v331.m
//  sohunews
//
//  Created by Chen Hong on 13-2-26.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager_v331.h"
#import "CacheDefines.h"

@implementation FmdbMigration(v331)

- (void)migrateUpTo3_3_1_1 {
    // 专题列表添加updateTime列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SPECIALNEWSLIST_UPDATETIME columnType:@"Varchar"] forTableName:TB_SPECIALNEWSLIST];

    // 专题列表添加expired列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SPECIALNEWSLIST_EXPIRED columnType:@"Varchar"] forTableName:TB_SPECIALNEWSLIST];
}

- (void)migrateUpTo3_3_1_2 {
    // 报纸表添加logourl
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSPAPER_NORMALLOGO columnType:@"Varchar"] forTableName:TB_NEWSPAPER];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSPAPER_NIGHTLOGO columnType:@"Varchar"] forTableName:TB_NEWSPAPER];
}

- (void)migrateUpTo3_3_1_3 {
    //除了给表tbNewsArticle、tbNewsImage、tbGallery、tbRecommendGallery、tbPhoto、tbRollingNewsList、tbGroupPhoto、tbGroupPhotoUrl分别加一个creatAt字段
    //还要分别给表tbVotesInfo、 tbRecommendNews、tbSpecialNewsList、tbCommentJson、tbLivingGame、tbWeiboHotItem、tbWeiboHotDetail、tbWeiboHotComment加一个createAt字段
    
    //投票信息数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_VOTES_INFO, TB_CREATEAT_COLUMN]];
    
    //相关推荐新闻数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_RECOMMEND_NEWS, TB_CREATEAT_COLUMN]];
    
    //专题新闻列表数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_SPECIALNEWSLIST, TB_CREATEAT_COLUMN]];
    
    //服务器端获取的所有评论数据表（与tbNewsComment表区分开，tbNewsComment表是存放用户自己评论的数据，程序每次冷启动时都会清空tbNewsComment数据表）
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_COMMENTJSON, TB_CREATEAT_COLUMN]];
    
    //直播一级列表数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_LIVING_GAME, TB_CREATEAT_COLUMN]];
    
    //微闻一级列表数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_WEIBOHOT_ITEM, TB_CREATEAT_COLUMN]];
    
    //微闻二级中的详情内容数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_WEIBOHOT_DETAIL, TB_CREATEAT_COLUMN]];
    
    //微闻二级中的评论列表数据表
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_WEIBOHOT_Comment, TB_CREATEAT_COLUMN]];
}

- (void)migrateUpTo3_3_1_4 {
    // 微热议列表 增加icon列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_ICON columnType:@"Varchar"] forTableName:TB_WEIBOHOT_ITEM];
    // 微热议详情 增加source列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_SOURCE columnType:@"Varchar"] forTableName:TB_WEIBOHOT_DETAIL];
}

- (void)migrateUpTo3_3_1_5{
    //收藏页添加用户名字段，用于存储那个用户想删除但是还没有云同步到服务器的数据
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_MYFAVOURITES_USERID columnType:@"Varchar"] forTableName:TB_MYFAVOURITES];
}

- (void)migrateUpTo3_3_1_6{
    //文章内容增加nextNewsLink字段 用于报纸里连续阅读过程中记录下条信息
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_NEXTNEWSLINK columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_NEXTNEWSLINK2 columnType:@"Varchar"] forTableName:TB_NEWSARTICLE];
    //组图内容增加nextNewsLink字段 用于报纸里连续阅读过程中记录下条信息
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_NEXTNEWSLINK columnType:@"Varchar"] forTableName:TB_GALLERY];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_GALLERY_NEXTNEWSLINK2 columnType:@"Varchar"] forTableName:TB_GALLERY];
}

@end
