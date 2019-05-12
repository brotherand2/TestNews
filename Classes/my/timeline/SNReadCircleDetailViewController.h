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

@interface SNReadCircleDetailViewController : SNBaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
SNTrendCmtsViewDelegate>

@property (nonatomic, strong)NSString *pid;
@property (nonatomic, strong)NSString *actId;
@property (nonatomic, assign)BOOL     isTop;
@property (nonatomic, assign)int approvalNum;
@property (nonatomic, assign)int indexPath;

@end
