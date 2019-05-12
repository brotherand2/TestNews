//
//  SNHotCommentListModel.h
//  sohunews
//
//  Created by jialei on 14-8-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentListModel.h"

@interface SNHotCommentListModel : SNCommentListModel

- (id)initWithCommentModelWithNewsId:(NSString *)newsId gid:(NSString*)gid;

@end
