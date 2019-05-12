//
//  SNNewCommentListModel.m
//  sohunews
//
//  Created by jialei on 14-8-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewCommentListModel.h"

@implementation SNNewCommentListModel

- (id)initWithCommentModelWithNewsId:(NSString *)newsId gid:(NSString*)gid
{
    self = [super initWithCommentModelWithNewsId:newsId gid:gid];
    if (self) {
        self.isHotTab = NO;
        self.loadPageSize = kNewCommentFirstPageSize;
        self.commentType = 3;
    }
    
    return self;
}

//- (void)urlWithCursor {
//    _url = [NSString stringWithFormat:SNLinks_Path_Comment_CommentList, self.busiCode, [self sourceId],
//                [self cursorId], self.rollType, self.loadPageSize, self.requestSource, self.commentType, self.refererType];
//}

@end
