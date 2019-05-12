//
//  SNPhotolistDataSource.h
//  sohunews
//
//  Created by jialei on 14-3-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTimelineConfigs.h"
#import "SNCommentListManager.h"
#import "SNNewsComment.h"

typedef void (^TableViewCellConfigureBlock)(id cell, id item);
typedef void (^PLTableViewScrollDidScrollBlock)(UIScrollView *scrollView);
typedef void (^PLTableViewCellDisplayBlock)(UITableViewCell *cell);
typedef void (^PLTableViewImageClickBlock)(id sender);
typedef void (^PLTableViewReload)();
typedef void (^PLTableViewCellReplyComment)(SNNewsComment* comment, SNCommentSendType type);
typedef void (^PLTableViewCellShareComment)(SNNewsComment* comment);
typedef void (^PLTableViewCellClickComtImage)(NSString *urlPath);

typedef NS_ENUM(NSInteger, SNPTTableSectionType)
{
    SNPLTableSectionPhoto = 0,
    SNPLTableSectionSub   = 1,
    SNPLTableSectionRecommendTitle = 2,
    SNPLTableSectionRecommend      = 3,
    SNPLTableSectionCommentTitle   = 4,
    SNPLTableSectionComment        = 5
};

@interface SNPhotolistDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

//组图正文数据
@property (nonatomic, retain)NSArray *photoItems;
@property (nonatomic, assign)int photoCount;

//订阅数据
@property (nonatomic, retain)NSString *subId;
@property (nonatomic, retain)SCSubscribeObject *subscribe;
@property (nonatomic, assign)int subScribeCount;

//相关推荐数据
@property (nonatomic, assign)int recmdTitleCount;
@property (nonatomic, assign)CGFloat recmdTitleHeight;
@property (nonatomic, retain)NSArray *recommendItems;
@property (nonatomic, assign)int recmdCount;
@property (nonatomic, assign)int sdkAdState;

//评论数据
@property (nonatomic, assign)CGFloat commentTitleHeight;
@property (nonatomic, retain)NSArray *commentItems;
@property (nonatomic, assign)int cmtCount;

@property (nonatomic, assign)SNMoreCellState moreCellState;

//block
@property (nonatomic, copy)PLTableViewScrollDidScrollBlock scrollBlock;
@property (nonatomic, copy)PLTableViewCellDisplayBlock cellDisplayBlock;
@property (nonatomic, copy)PLTableViewImageClickBlock imageClickBlock;
@property (nonatomic, copy)PLTableViewReload tableReload;
@property (nonatomic, copy)PLTableViewCellReplyComment replyComment;
@property (nonatomic, copy)PLTableViewCellShareComment shareComment;
@property (nonatomic, copy)PLTableViewCellClickComtImage showComtImage;

//commentManager
@property (nonatomic, retain)SNCommentListManager *commentlistManager;
@property (nonatomic, assign)int refer;

- (void)setMoreCellState:(SNMoreCellState)moreCellState tableView:(UITableView *)tableView;
- (id)initWithCommentId:(NSString *)cmtReqId requestType:(SNCommentRequestType)type;

@end
