//
//  SNDatabase_RecommendGallery.h
//  sohunews
//
//  Created by 雪 李 on 11-12-21.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"

@interface SNDatabase(RecommendGallery)
-(NSArray*)getRecommendGallery;
-(NSArray*)getRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId;
-(NSArray*)getRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId inDatabase:(FMDatabase *)db;
-(NSString*)getRecommendGalleryIconPathByUrl:(NSString *)iconUrl;
-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem;
-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem inDatabase:(FMDatabase *)db;
-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)addMultiRecommendGallery:(NSArray*)recommendGallery;
-(BOOL)deleteRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId;
-(BOOL)deleteRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId inDatabase:(FMDatabase *)db;
-(BOOL)clearRecommendGallery;
-(BOOL)clearRecommendGalleryInDatabase:(FMDatabase *)db;

-(BOOL)downloadRecommendGallery:(RecommendGallery *)recommendGallery delegate:(id)delegate;

@end
