//
//  SNDatabase_SpecialNewsList.h
//  sohunews
//
//  Created by handy wang on 7/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"
#import "SNSpecialNews.h"

@interface SNDatabase(SpecialNewsList)

#pragma mark - Add methods implementation
- (BOOL)addMultiSpecialNewsList:(NSArray*)newsList updateIfExist:(BOOL)bUpdateIfExist;
- (BOOL)addSingleSpecialNewsListItem:(SNSpecialNews *)news;
- (BOOL)addSingleSpecialNewsListItem:(SNSpecialNews *)news updateIfExist:(BOOL)bUpdateIfExist;

#pragma mark - Delete methods implementation
- (BOOL)clearSpecialHeadlineNewsByTermId:(NSString *)termId;
- (BOOL)deleteSpecialNewsByTermId:(NSString *)termId newsId:(NSString *)newsId;
- (BOOL)clearSpecialNewsByTermId:(NSString *)termId;
- (BOOL)clearSpecialNewsList;

#pragma mark - Update methods implementation
- (BOOL)markSpecialNewsAsReadByTermId:(NSString*)termId newsId:(NSString*)newsId;
- (BOOL)markSpecialNewsListItemAsNotExpiredByTermId:(NSString*)termId newsId:(NSString*)newsId;
- (BOOL)markSpecialNewsListItemAsReadAndNotExpiredByTermId:(NSString *)termId newsId:(NSString *)newsId;
- (BOOL)updateSpecialNewsListByTermId:(NSString*)termId newsId:(NSString*)newsId withValuePairs:(NSDictionary*)valuePairs;

#pragma mark - Query methods implementation
- (BOOL)checkSpecialNewsReadOrNotByTermId:(NSString *)termId newsId:(NSString*)newsId;
- (SNSpecialNews *)getSpecialNewsByTermId:(NSString *)termId newsId:(NSString*)newsId;
- (NSArray *)getSpecialHeadlineNewsListByTermId:(NSString *)termId;
- (NSArray *)getSpecialNormalNewsListByTermId:(NSString *)termId;

@end