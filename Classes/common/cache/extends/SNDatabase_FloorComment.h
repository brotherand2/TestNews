//
//  SNDatabase_FloorComment.h
//  sohunews
//
//  Created by qi pei on 7/1/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(FloorComment)

-(BOOL)addMultiFloorComment:(NSArray*)commentList;

-(BOOL)updateCommentDigNumByNewsId:(NSString *)newsId
                      andCommentId:(NSString *)commId
                       andNewsType:(NSString *)newsType;

-(NSMutableArray *)getHadDingFloorComment:(NSString *)type
                                andNewsId:(NSString *)newsId
                              andNewsType:(NSString *)newsType;

-(NSMutableArray *)getFirstCachedFloorComment:(NSString *)type
                                    andNewsId:(NSString *)newsId     
                                  andNewsType:(NSString *)newsType;

-(NSMutableArray *)loadNextPageCommentBy:(NSString *)type 
                               andNewsId:(NSString *)newsId
                             andNewsType:(NSString *)newsType
                                andCtime:(double)ctime;

-(BOOL)clearCommentJson;

@end
