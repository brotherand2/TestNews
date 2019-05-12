//
//  SNDatabase_Photo.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(Photo) 

-(NSArray*)getPhotoList;
-(NSArray*)getPhotoListWithTimeOrderOption:(ORDER_OPTION)orderOpt;
-(NSArray*)getPhotoListByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(NSArray*)getPhotoListByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;
-(PhotoItem*)getPhotoByUrl:(NSString*)url;
-(BOOL)addSinglePhoto:(PhotoItem*)photo;
-(BOOL)addSinglePhoto:(PhotoItem*)photo inDatabase:(FMDatabase *)db;
-(BOOL)addSinglePhoto:(PhotoItem*)photo updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db;
-(BOOL)addSinglePhoto:(PhotoItem*)photo updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)deletePhotoByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(BOOL)deletePhotoByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;
-(BOOL)clearPhotoList;
-(BOOL)clearPhotoListInDatabase:(FMDatabase *)db;

-(BOOL)downloadPhoto:(PhotoItem*)photo delegate:(id)delegate;
- (void)cleanupAllPhotoDownload;

//- (void)removeDelegatesForURL:(NSString *)url;
- (void)cancelPhotoDownloadByUrl:(NSString *)url;

@end
