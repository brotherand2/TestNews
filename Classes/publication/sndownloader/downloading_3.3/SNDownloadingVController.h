//
//  SNDownloadingVController.h
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//


#import "SNChannelModel.h"
#import "SNDownloadingSectionHeaderView.h"
#import "SNDownloadScheduler.h"
#import "DACircularProgressView.h"

#define kDownloadingTableViewInsetTop                                   (38)
#define kDownloadingTableViewInsetBottom                                (44)

typedef enum {
    SNDownloadingCellOrder_Unknown = -1,
    SNDownloadingCellOrder_OnlyOne = 0,
    SNDownloadingCellOrder_First = 1,
    SNDownloadingCellOrder_Middle = 2,
    SNDownloadingCellOrder_Last = 3
} SNDownloadingCellOrder;

@class SNDownloadingProgressBall;
@class SNDownloadingExViewController;
@interface SNDownloadingVController : SNBaseViewController<UITableViewDataSource, UITableViewDelegate,SNDownloadSchedulerDelegate> {
    id _delegate;
    
    UITableView *_tableView;
    NSMutableArray *_toBeDownloadedItems;//二维数组:第一个元素是待下载的刊物，第二个元素是待下载的频道;
    NSMutableArray *_toBeDownloadedItemsRow; //一维数组，上面数组合并
    //NSMutableDictionary *_toBeDownloadedItemsRowDic;
    NSMutableArray *_cellArray;
    
    //UIImageView *_emptyDownloadingBg;
    UIButton *_onekeyDownloadMySubsAndNewsBtn;
    DACircularProgressView* __weak _progressBar;
    SNDownloadingExViewController* __weak _downloadingExViewController;
    //SNDownloadingSectionHeaderView *_subSectionHeaderView;
    //SNDownloadingSectionHeaderView *_newsSectionHeaderView;
}

- (id)initWithIDelegate:(id)delegateParam;
- (void)enableOrDisableRightBtn;
- (void)oneKeyDownloadMySubsAndNews;

@property(nonatomic,weak) DACircularProgressView* progressBar;
@property(nonatomic,weak) SNDownloadingExViewController* downloadingExViewController;
@end
