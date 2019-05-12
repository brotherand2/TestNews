//
//  SNDatabase_Newspaper.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"
#import "CacheObjects.h"

@interface SNDatabase(Newspaper)

-(NSArray*)getNewspaperList;
//ORDER BY SUBID ASC
-(NSArray*)getNewspaperListBySubId:(NSString*)subId;
-(NSArray*)getNewspaperListByPubId:(NSString*)pubId;
-(NSArray*)getNewspaperListWithTimeOrderOption:(ORDER_OPTION)orderOpt;
-(NSArray*)getNewspaperDownloadedList;
-(NSArray*)getNewspaperDownloadedListWithTimeOrderOption:(ORDER_OPTION)orderOpt;
-(NSArray*)getNewspaperDownloadedListByPubId:(NSString*)pubId;
-(NSArray*)getNewspaperDownloadedListBySubId:(NSString*)subId;
-(NSArray*)getNewspaperDownloadedListBySubId:(NSString*)subId withTimeOrderOption:(ORDER_OPTION)orderOpt;
-(NewspaperItem*)getNewspaperByTermId:(NSString*)termId;
-(BOOL)setNewspaperList:(NSArray*)newspaperList;
-(BOOL)addSingleNewspaper:(NewspaperItem*)newspaper;
-(BOOL)addMultiNewspaper:(NSArray*)newspaperList;
-(BOOL)addSingleNewspaper:(NewspaperItem*)newspaper updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)addMultiNewspaper:(NSArray*)newspaperList updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)updateNewspaperByTermId:(NSString*)termId withValuePairs:(NSDictionary*)valuePairs;
-(BOOL)updateNewspaperByTermId:(NSString*)termId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist;
-(BOOL)updateNewspaperBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs;
-(BOOL)updateNewspaperBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist;
-(BOOL)deleteNewspaperByTermId:(NSString*)termId;
-(BOOL)deleteNewspaperByTermId:(NSString *)termId deleteFromTable:(BOOL)bDelFromTable;
-(BOOL)deleteNewspaperBySubId:(NSString*)subId;
-(BOOL)deleteNewspaperBySubId:(NSString*)subId deleteFromTable:(BOOL)bDelFromTable;
-(BOOL)clearNewspaperlist;
-(BOOL)clearNewspaperlist:(BOOL)bDelFromTable;
//默认重试3次，异步下载，请在主线程中调用
-(BOOL)downloadNewspaperZip:(NewspaperItem*)newspaper delegate:(id)delegate;
-(BOOL)downloadNewspaperZipById:(NSString *)newspaperId delegate:(id)delegate;

-(NSString*)getNewsPaperFolderByTermId:(NSString*)tId;

@end
