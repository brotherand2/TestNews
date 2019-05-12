//
//  SNCircleCommentEditorController.h
//  sohunews
//
//  Created by jialei on 13-7-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseEditorViewController.h"

@class SNTimelinePostService;

@interface SNCircleCommentEditorController : SNBaseEditorViewController<SNEmoticonScrollViewDelegate>
{
}

@property (nonatomic, copy) NSString *actId;
@property (nonatomic, copy) NSString *spid;
@property (nonatomic, copy) NSString *fpid;
@property (nonatomic, copy) NSString *fname;
@property (nonatomic, copy) NSString *commentId;

- (id)initWithData:(NSDictionary*)query;

@end
