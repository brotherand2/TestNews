//
//  SNReadCircleDetailViewController.h
//  sohunews
//
//  Created by jialei on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDragRefreshTableViewController.h"
#import "SNTrendCommentsView.h"
#import "SNTimelineTrendCell.h"

#define kCircleDetailKeyPid     (@"kCircleDetailKeyPid")
#define kCircleDetailKeyActId   (@"actId")
#define kCircleDetailKeyAvlNum  (@"kCircleDetailKeyAvlNum")
#define kCircleDetailKeyIndex   (@"kCircleDetailKeyIndex")

@interface SNReadCircleDetailViewController : SNBaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
SNTrendCmtsViewDelegate>

@property (nonatomic, retain)NSString *pid;
@property (nonatomic, retain)NSString *actId;
@property (nonatomic, assign)BOOL     isTop;
@property (nonatomic, assign)int approvalNum;
@property (nonatomic, assign)int indexPath;

@end
