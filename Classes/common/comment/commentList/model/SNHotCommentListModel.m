//
//  SNHotCommentListModel.m
//  sohunews
//
//  Created by jialei on 14-8-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNHotCommentListModel.h"

@implementation SNHotCommentListModel

- (id)initWithCommentModelWithNewsId:(NSString *)newsId gid:(NSString*)gid
{
    self = [super initWithCommentModelWithNewsId:newsId gid:gid];
    if (self) {
        self.isHotTab = YES;
        self.loadPageSize = kHotCommentFirstPageSize;
        self.commentType = 5;
    }
    
    return self;
}

//- (void)urlWithCursor {
//    _url = [NSString stringWithFormat:SNLinks_Path_Comment_CommentList, self.busiCode, [self sourceId],
//                [self cursorId], self.rollType, self.loadPageSize, self.requestSource, self.commentType, self.refererType];
//}

@end
