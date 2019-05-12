//
//  SNDBMigrationManager_330.m
//  sohunews
//
//  Created by wang yanchen on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager_330.h"
#import "CacheDefines.h"

@implementation FmdbMigration(v330)

- (void)migrateUpTo3_3_0_1 {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // create table for weibo hot channel
//    NSArray *weiboChannelCols = [NSArray arrayWithObjects:
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_ID columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELNAME columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELID columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELICON columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELTYPE columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_IS_SUBED columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELPOSITION columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELTOP columnType:@"Varchar"],
//                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOTCHANNEL_CHANNELTOPTIME columnType:@"Varchar"],
//                                 nil];
//    [self createTable:TB_WEIBOHOTCHANNEL withColumns:weiboChannelCols];
    
    // add in bundle weibohot channel data
//    [self executeSQL:@"INSERT INTO tbWeiboHotChannel (ID,name,channelID,channelType,isChannelSubed) VALUES (NULL,'微观点','32','3','1')"];
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // create table for weibo hot item
    NSArray *weiboHotItemColums = [NSArray arrayWithObjects:
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_ID columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_NICK columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_HEAD_URL columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_IS_VIP columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_TIME columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_TITLE columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_TYPE columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_COMMENT_NUM columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_CONTENT columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_ABSTRACT columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_FOCUS_PIC columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_WEIGHT columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_USER_JSON columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_PAGENO columnType:@"Varchar"],
                                   [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_ITEM_READ_MARK columnType:@"Varchar"],
                                   nil];
    [self createTable:TB_WEIBOHOT_ITEM withColumns:weiboHotItemColums];
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // create cloud save table
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_USERID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_TITLE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_LINK columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_COLLECTTIME columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_MYFAVOURITEREFER columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_CONTENTLEVELONEID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_CLOUDSAVES_CONTENTLEVELTWOID columnType:@"Varchar"],
                        nil];
    [self createTable:TB_CLOUDSAVES withColumns:columns];
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // create local channel save table
    /*
    NSArray *localchannnel = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_LOCALCHANNEL_USERID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_LOCALCHANNEL_TYPE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_LOCALCHANNEL_TIMESTAMP columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_LOCALCHANNEL_CONTENT columnType:@"Varchar"],
                        nil];
    
    [self createTable:TB_LOCALCHANNEL withColumns:localchannnel];*/
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 给新闻频道列表增加最近更新字段
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_LAST_MODIFY columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_CATEGORY_LAST_MODIFY columnType:@"Varchar"] forTableName:TB_CATEGORY];
   
    // 专题列表添加termName列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SPECIALNEWSLIST_TERMNAME columnType:@"Varchar"] forTableName:TB_SPECIALNEWSLIST];
}

- (void)migrateUpTo3_3_0_2; // add index 
{
    NSArray *weibo_detail_columns = [NSArray arrayWithObjects:
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_ID columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_NICK columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_IS_VIP columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_HEAD_URL columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_HOME_URL columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_TITLE columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_TIME columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_TYPE columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_COMMENT_NUM columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_CONTENT columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_NEWSID columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_WAP_URL columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_RESOURCE_JSON columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_SHARE columnType:@"Varchar"],
                                 [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_HEIGHT columnType:@"Float"],
                                     nil];
    [self createTable:TB_WEIBOHOT_DETAIL withColumns:weibo_detail_columns];
    
    
    NSArray *columns = [NSArray arrayWithObjects:
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_ID columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_NICK columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_IS_VIP columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_HEAD_URL columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_TYPE columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_HOME_URL columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_TIME columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_CONTENT columnType:@"Varchar"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_HEIGHT columnType:@"Float"],
                        [FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_DETAIL_ID columnType:@"Varchar"],
                        nil];
    [self createTable:TB_WEIBOHOT_Comment withColumns:columns];
    
    
    [self executeSQL:@"DROP TABLE tbAllSubscribe"];
    [self executeSQL:@"DROP TABLE tbSubscribe"];
    [self executeSQL:@"DROP TABLE tbSubscribeHomeImage"];
    [self executeSQL:@"DROP TABLE tbHomeV3SubscribeHomeAllSubscribe"];
    [self executeSQL:@"DROP TABLE tbHomeV3SubscribeHomeInitialAllSubscribe"];
    [self executeSQL:@"DROP TABLE tbHomeV3SubscribeHomeInitialMySubscribe"];
    [self executeSQL:@"DROP TABLE tbHomeV3SubscribeHomeMySubscribe"];
    [self executeSQL:@"DROP TABLE tbAnalyticsEvent"];
    
    [self executeSQL:@"CREATE UNIQUE INDEX tbWeatherReportsUniqueIndex ON tbWeatherReports(cityGbcode,weatherIndex)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbCloudSavesUniqueIndex     ON tbCloudSaves(userid,link)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbMyFavouritesUniqueIndex   ON tbMyFavourites(myFavouriteRefer,contentLeveloneID,contentLeveltwoID)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbLivingGameUniqueIndex     ON tbLivingGame(liveId,isFocus)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbNewspaperUniqueIndex      ON tbNewspaper(subId,pubId,termId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbNewsArticleUniqueIndex    ON tbNewsArticle(channelId,pubId,termId,newsId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbRecommendNewsUniqueIndex  ON tbRecommendNews(link,relatedNewsID)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbNewsImageUniqueIndex      ON tbNewsImage(newsId,link)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbVotesInfoUniqueIndex      ON tbVotesInfo(newsID)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbGalleryUniqueIndex        ON tbGallery(termId,newsId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbPhotoUniqueIndex          ON tbPhoto(termId,newsId,url)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbRecGalleryUniqueIndex     ON tbRecommendGallery(rTermId,rNewsId,termId,newsId)"];
//    [self executeSQL:@"CREATE UNIQUE INDEX tbNewsCommentUniqueIndex    ON tbNewsComment(newsID)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbRollingNewsUniqueIndex    ON tbRollingNewsList(channelId,newsId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbGroupPhotoUniqueIndex     ON tbGroupPhoto(newsId,typeId,type)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbTagUniqueIndex            ON tbTag(tagId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbAllSubUniqueIndex         ON tbSubscribeCenterAllSubscribe(subId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbCommentJsonUniqueIndex    ON tbCommentJson(newsId,commentId,type,newsType)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbSpecialNewsUniqueIndex    ON tbSpecialNewsList(termId,newsId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbNickNameUniqueIndex       ON tbNickName(nickName)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbWeiboHotItemUniqueIndex   ON tbWeiboHotItem(weiboId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbSubCenterTypesUniqueIndex ON tbSubscribeCenterSubTypes(typeId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbSubTypeRelaUniqueIndex    ON tbSubscribeCenterSubTypeRelation(typeId,subId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbCategoryUniqueIndex       ON tbCategory(categoryId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbGroupPhotoUrlUniqueIndex  ON tbGroupPhotoUrl(url,newsId,typeId,type)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbWeiboHotDetailUniqueIndex ON tbWeiboHotDetail(weiboId)"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbWeiboCommentUniqueIndex   ON tbWeiboHotComment(commentId)"];


    
}



//给订阅中心表tbSubscribeCenterAllSubscribe加isSelected字段，给新闻频道表tbNewsChannel表加isSelected字段
- (void)migrateUpTo3_3_0_3 {
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_ISSELECTED columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNEL_ISSELECTED columnType:@"Varchar"] forTableName:TB_NEWSCHANNEL];
}

- (void)migrateUpTo3_3_0_4 {
    [self executeSQL:@"DROP INDEX IF EXISTS tbNewspaperUniqueIndex"];
    [self executeSQL:@"CREATE UNIQUE INDEX tbNewspaperUniqueIndex ON tbNewspaper(subId,termId)"];
}

@end
