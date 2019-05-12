//
//  SNDatabase_NewsComment.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"

@interface SNDatabase(NewsComment)

-(NSArray*)getNewsCommentByNewsId:(NSString*)newsId;
-(BOOL)addSingleNewsComment:(NewsCommentItem*)newsComment;

-(BOOL)updateMyCommentDigNumById:(NSInteger)cid;
-(BOOL)updateMyCommentUserComtId:(NSString *)userComtId By:(NSString *)ctime;
-(BOOL)clearNewsComment;
-(BOOL)deleteNewsCommentByctime:(NSString*)ctime;




/*-(BOOL)addOrUpdateSingleNewsComment:(NewsCommentItem*)newsComment;
-(BOOL)addMultiNewsComment:(NSArray*)newsCommentList;
-(BOOL)deleteNewsCommentByNewsId:(NSString*)newsId;

-(BOOL)updateNewsCommentByNewsId:(NSString*)newsId commentId:(NSString *)commentId withValuePairs:(NSDictionary*)valuePairs;
 */
@end
