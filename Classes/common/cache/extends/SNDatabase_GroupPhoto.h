//
//  SNDatabase_GroupPhoto.h
//  sohunews
//
//  Created by ivan on 3/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"

@interface SNDatabase(GroupPhoto) 

-(BOOL)addMultiGroupPhoto:(NSArray*)aPhotoArray;
-(NSMutableArray *)getCachedGroupPhotoByPage:(int)pageNum 
                                    andType:(NSString *)aType
                                  andTypeId:(NSString *)aTypeId;

-(NSMutableArray *)getCachedGroupPhotoByTimelineIndex:(NSString *)timelineIndex 
                                              andType:(NSString *)aType
                                            andTypeId:(NSString *)aTypeId;

-(NSMutableArray *)getFirstCachedPhoto:(NSString *)timelineIndex 
                               andType:(NSString *)aType
                             andTypeId:(NSString *)aTypeId;

-(BOOL)deleteCachedPhotosByType:(NSString *)aType
                       andTypeId:(NSString *)aTypeId;

-(BOOL)updateFavoriteNum:(NSString *)favNum
                byNewsId:(NSString *)newsId 
                 andType:(NSString *)aType
               andTypeId:(NSString *)aTypeId;

-(NSString*)getMinPhotoTimelineIndexByType:(NSString *)aType
                                 andTypeId:(NSString *)aTypeId;
-(NSString*)getMaxPhotoTimelineIndexByType:(NSString *)aType
                                 andTypeId:(NSString *)aTypeId;

-(NSMutableArray *)getAllCachedPhotoByTimeline:(NSString *)timelineIndex
                                       andType:(NSString *)aType
                                     andTypeId:(NSString *)aTypeId;


-(BOOL)clearGroupPhotoList;

-(BOOL)markPhotoItemAsReadByTypeId:(NSString *)typeId newsId:(NSString *)newsId type:(NSString *)type;

-(int)checkPhotoNewsReadOrNot:(NSString *)newsId typeId:(NSString *)typeId type:(NSString *)type;

//-(BOOL)updatePhotoNewsRead:(NSString *)newsId typeId:(NSString *)typeId type:(NSString *)type flag:(int)readFlag;

@end
