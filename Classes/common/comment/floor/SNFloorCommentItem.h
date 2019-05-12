//
//  SNFloorCommentItem.h
//  sohunews
//
//  Created by qi pei on 6/18/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNNewsComment.h"

//#import "SNBaseCommentTableController.h"

@interface SNFloorCommentItem : TTTableItem {
    SNNewsComment *comment;
    
    NSIndexPath *indexPath;
    BOOL expand;
    BOOL isCommentOpen;
//    SNBaseCommentTableController *floorsCommentController;
    NSString *newsId;
    NSString *gid;
    BOOL hasDing;
}
@property(nonatomic, strong)SNNewsComment *comment;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, readwrite)BOOL expand;
//@property(nonatomic, assign)SNBaseCommentTableController *floorsCommentController;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *gid;
@property(nonatomic, assign) BOOL hasDing;
@property(nonatomic, assign) float cellHeight;                  //缓存整个cell高度
@property(nonatomic, assign) float cellContentHeight;           //缓存正文高度
@property(nonatomic, assign) float cellOffsetY;                 //item对于cell的Y坐标
@property(nonatomic, assign) BOOL isMoreDesignLine;             //保存是否需要显示更多
@property(nonatomic, assign) BOOL isAuthor;
@property(nonatomic, assign) BOOL isUsed;                       //当前item是否正在使用
@property(nonatomic, assign) SNCommentItemType commentItemType;

//commentItemType = SNCommentItemTypeNewCommentSection 时使用
@property(nonatomic, strong) NSString *sectionTitle;
@property(nonatomic, assign) BOOL isEmptyComment;

-(id)initWithComment:(SNNewsComment *)comment;

@end
