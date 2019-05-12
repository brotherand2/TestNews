//
//  SNDatabase_WeiboHotDetail.h
//  sohunews
//
//  Created by guo yalun on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(WeiboHotDetail)

- (BOOL)saveOrUpdateWeiboHotDetail:(WeiboHotItemDetail *)weiboDetail;
- (WeiboHotItemDetail *)getWeiboItemDetailById:(NSString *)weiboId;

- (NSArray *)getWeiboCommentList:(NSString *)weiboId pageNo:(NSInteger)pageIndex;
- (BOOL)saveOrUpdateWeiboHotComments:(NSArray *)commentItems;
- (BOOL)deleteWeiboCommentByWeiboId:(NSString *)weiboId;

- (BOOL)clearWeiboHotDetail;
- (BOOL)clearWeiboComment;
@end
