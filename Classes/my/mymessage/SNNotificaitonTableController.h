//
//  SNNotificaitonTableController.h
//  sohunews
//
//  Created by weibin cheng on 13-6-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNotificationModel.h"
#import "SNTableHeaderDragRefreshView.h"

@interface SNNotificaitonTableController : SNThemeViewController<UITableViewDataSource, UITableViewDelegate, SNNotificationModelDelegate, SNEmbededActivityIndicatorDelegate>
{
    SNTableHeaderDragRefreshView* _headerView;
    UITableView* _tableView;
    UIImageView* _noneNotificationView;
    UIView *_noneNotificationViewBack;
    CGFloat kHeaderVisibleHeight;
    CGFloat kRefreshDeltaY;
    SNEmbededActivityIndicator *_loadingView;
    SNNotificationModel *_notificationModel;
}
@property(nonatomic, strong) UITableView* tableView;

-(void)firstRefresh;
@end
