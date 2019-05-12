//
//  SNMyMessageTableController.h
//  sohunews
//
//  Created by jialei on 13-7-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNCommentListModel.h"
#import "SNMyMessageTable.h"
#import "SNPostCommentService.h"
#import "SNCommentMessageCell.h"

@class SNMyMessage;
@class SNMyMessageTable;

@interface SNMyMessageTableController : SNThemeViewController<SNPostCommentControllerDelegate, UITableViewDataSource,
UITableViewDelegate, SNCommentListModelDelegate, SNCommentTableEventDelegate, SNCommentListCellDelegate>
{
    NSString *_pid;
    NSString *_topicId;
    
    SNMyMessage* replyMessage;  //回复的消息
//    SNEmbededActivityIndicator *_myLoadingView;
}

@property (nonatomic, strong)NSString *newsId;
@property (nonatomic, strong)NSString *gId;
@property (nonatomic, strong)NSString *subId;
@property (nonatomic, assign)BOOL isAuthor;
@property (nonatomic, strong)SNMyMessageTable *tableView;

- (id)initWithQuery:(NSMutableDictionary *)query;
- (void)createModel;

- (void)replyComment:(SNNewsComment *)comment;
- (void)replyFloorComment:(SNNewsComment *)comment;
- (void)expandFloorComment:(int)subFloorIndex indexPathRow:(int)rowIndex;
- (void)expandSocialComment:(NSString *)messageId;
- (void)expandSocialFloorComment:(NSString *)messageId;
//- (void)showEmpty:(BOOL)show;


@end
