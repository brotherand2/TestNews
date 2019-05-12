//
//  SNRefreshTableViewController.h
//  sohunews
//
//  Created by lhp on 6/24/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableHeaderDragRefreshView.h"
#import "SNEmbededActivityIndicator.h"

@interface SNRefreshTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    SNTableHeaderDragRefreshView *_headerView;
    SNEmbededActivityIndicatorEx *_loadingView;
    int _topHeight,_bottomHeight;
}

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) SNTableHeaderDragRefreshView *headerView;
@property(nonatomic,assign) BOOL isLoading;

- (void)showRefreshHeaderView;
- (void)hideRefreshHeaderView;
- (void)refresh;
@end
