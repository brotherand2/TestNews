//
//  SNFollowingViewController.h
//  sohunews
//
//  Created by weibin cheng on 13-12-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//


#import "SNTableHeaderDragRefreshView.h"
#import "SNEmbededActivityIndicator.h"
#import "SNFollowUserModel.h"

@interface SNFollowingViewController : SNBaseViewController<UITableViewDataSource, UITableViewDelegate,
                                        SNFollowUserModelDelegate, SNEmbededActivityIndicatorDelegate>
{
    SNTableHeaderDragRefreshView*   _dragView;
    UITableView*                    _tableView;
    SNEmbededActivityIndicator*     _loadingView;
    SNFollowUserModel*              _model;
    
    NSString*                       _pid;
    UIImageView*                    _emptyView;
}

-(void)showEmptyView;
-(void)updateEmptyView;
-(void)hideEmptyView;
-(UITableViewCell*)createNoMoreCell;
-(CGFloat)noMoreCellHeight;
@end
