//
//  SNNewVideosTabExtended.h
//  sohunews
//
//  Created by tt on 15/12/16.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetCommentSuccess)(_Nullable id responseObject);
typedef void(^GetCommentFailure)(_Nullable id responseObject);
typedef void(^PostCommentSuccess)(_Nullable id responseObject);
typedef void(^PostCommentFailure)(NSError* _Nullable error);


@interface SNNewVideosTabExtended : NSObject

+ (void)postCommentWithTopicId:(long long)topicId
                  commentText:(NSString* _Nullable )commentText
                      success:(_Nullable PostCommentSuccess)success
                      failure:(_Nullable PostCommentFailure)failure;

+ (void)getCommentWithTopicVid:(long long)vid
                           cid:(long)cid
                          site:(long)site
                 lastCommentId:(NSNumber *_Nullable)lastCommentId
                          more:(BOOL)more
                       success:(_Nullable GetCommentSuccess)success
                       failure:(_Nullable GetCommentFailure)failure;

+ (NSMutableDictionary* _Nonnull)returnCommentListDic:(NSDictionary* _Nonnull)response;
@end
