//
//  CacheMgr_NewsImage.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "CacheObjects.h"
#import "SNDatabase.h"

@interface SNDatabase(NewsImage) 

-(NSArray*)getNewsImageList;
-(NSArray*)getNewsImageListWithTimeOrderOption:(ORDER_OPTION)orderOpt;
//-(NSArray*)getNewsImageByNewsId:(NSString*)newsId;
-(NSArray*)getNewsImageByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(NSArray*)getNewsImageByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;
-(NSArray*)getNewsShareImageListByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(NSArray*)getNewsShareImageListByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;
-(NewsImageItem*)getNewsImageByUrl:(NSString*)url;
-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage;
-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage inDatabase:(FMDatabase *)db;
-(BOOL)addMultiNewsImage:(NSArray*)newsImageList inDatabase:(FMDatabase *)db;
-(BOOL)addMultiNewsImage:(NSArray*)newsImageList;
-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db;
-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)addMultiNewsImage:(NSArray*)newsImageList updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)deleteNewsImageByUrl:(NSString*)url;
-(BOOL)deleteNewsImageByNewsId:(NSString*)newsId;
-(BOOL)deleteNewsImageByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;
-(BOOL)clearNewsImageList;

@end
