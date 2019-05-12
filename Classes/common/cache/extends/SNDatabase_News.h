//
//  SNDatabase_News.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(News) 

//-(NSArray*)getNewsArticle;
//-(NSArray*)getNewsArticleListWithTimeOrderOption:(ORDER_OPTION)orderOpt;
-(NewsArticleItem*)getNewsArticelByTermId:(NSString*)termId newsId:(NSString*)newsId;

-(BOOL)addSingleNewsArticleOrUpdate:(NewsArticleItem*)newsArtcile;
-(BOOL)addSingleNewsArticleIfNotExist:(NewsArticleItem*)newsArtcile;
-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList;
-(BOOL)addSingleNewsArticle:(NewsArticleItem*)newsArtcile updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList updateIfExist:(BOOL)bUpdateIfExist;

-(BOOL)addSingleNewsArticleOrUpdate:(NewsArticleItem*)newsArtcile withOption:(ADDNEWSARTICLE_OPTION)option;
-(BOOL)addSingleNewsArticleIfNotExist:(NewsArticleItem*)newsArtcile withOption:(ADDNEWSARTICLE_OPTION)option;
-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList withOption:(ADDNEWSARTICLE_OPTION)option;
-(BOOL)addSingleNewsArticle:(NewsArticleItem*)newsArtcile updateIfExist:(BOOL)bUpdateIfExist withOption:(ADDNEWSARTICLE_OPTION)option;
-(BOOL)addMultiNewsArticle:(NSArray*)newsArticleList updateIfExist:(BOOL)bUpdateIfExist withOption:(ADDNEWSARTICLE_OPTION)option;
- (BOOL)updateNewsCmtReadByChannelId:(NSString*)channelId newsId:(NSString*)newsId hasRead:(BOOL)hasRead;
//仅内部使用
-(NSArray*)getNewsArticleFromResultSet:(FMResultSet*)rs inDatabase:(FMDatabase *)db;
-(BOOL)addNewsArticle:(NewsArticleItem *)newsArticle;

//刊物订阅
-(BOOL)updateNewsArticleByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs;
-(BOOL)updateNewsArticleByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist;

//滚动新闻
-(BOOL)updateNewsArticleByChannelId:(NSString*)cId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs;
-(BOOL)updateNewsArticleByChannelId:(NSString*)cId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist;

-(BOOL)deleteNewsArticlebyTermId:(NSString*)termId newsId:(NSString*)newsId;
-(BOOL)deleteNewsArticlebyChannelId:(NSString*)cId newsId:(NSString*)newsId;

-(BOOL)clearNewsArticleList;

-(NSArray*)getImageUrlFromNewsContent:(NSString*)newsContent;
-(NSArray*)getThumbnailUrlFromNewsContent:(NSString*)newsContent;

- (BOOL)updateNewsArticleFavourByChannelId:(NSString*)cId newsId:(NSString*)newsId;
- (BOOL)updateNewsArticleFavourByTermId:(NSString*)termId newsId:(NSString*)newsId;

@end
