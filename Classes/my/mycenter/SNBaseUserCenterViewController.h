//
//  SNBaseUserCenterViewController.h
//  sohunews
//
//  Created by weibin cheng on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBadgeView.h"
#import "SNCenterViewDefaultCell.h"

#define kUserCenterHeadViewTag 100
#define kUserCenterNameTag (kUserCenterHeadViewTag+1)
#define kUserCenterBadgeTag (kUserCenterHeadViewTag+2)
#define kUserCenterGenderTag (kUserCenterHeadViewTag+3)
#define kUserCenterWeiboTag (kUserCenterHeadViewTag+4)
#define kUserCenterCityTag (kUserCenterHeadViewTag+5)
#define kUserCenterButtonTag (kUserCenterHeadViewTag+6)
#define kUserCenterMoreActionTag (kUserCenterHeadViewTag+7)
#define kUserCenterDeleteActionTag (kUserCenterHeadViewTag+8)
#define kUserCenterFollowingTag (kUserCenterHeadViewTag+50)
#define kUserCenterFollowingCountTag (kUserCenterFollowingTag+1)
#define kUserCenterFollowingBadgeTag (kUserCenterFollowingTag+2)
#define kUserCenterFollowLineTag (kUserCenterFollowingTag+3)
#define kUserCenterFollowedTag (kUserCenterHeadViewTag+100)
#define kUserCenterFollowedCountTag (kUserCenterFollowedTag+1)
#define kUserCenterFollowedBadgeTag (kUserCenterFollowedTag+2)

#define kBaseInfoViewHeight 104

@class SNWeiboDetailMoreCell;

@interface SNBaseUserCenterViewController : SNBaseViewController<SNUserinfoServiceGetUserinfoDelegate,UITableViewDataSource,
UITableViewDelegate, SNBadgeViewDelegate, SNCommentTableEventDelegate>
{
    UIView*                         _baseInfoView;
    SNTableHeaderDragRefreshView*   _dragHeaderView;
    SNUserinfoService*               _model;
    UITableView*                    _tableView;
    SNCenterViewDefaultCell*        _dfCell;
    NSString*                       _pid;
    SNWeiboDetailMoreCell *_moreCell;
    BOOL _shouldUpdateRefreshTime;
    BOOL _isLoading;
    BOOL _isLoadingMore;
    BOOL _isCommentLoading;
    BOOL _isShowNetWork;
    CGFloat  _lastOffsetY;
}
@property(nonatomic, strong)    UITableView* tableView;
@property(nonatomic, strong)    SNUserinfoService* model;
@property(nonatomic, copy)      NSString* pid;

-(void)createTableView;

-(void)createBaseInfoView;

-(void)updateBaseInfoView;

-(void)onClickHead;

-(void)onClickFollowing;

-(void)onClickFollowed;

-(void)refresh;

-(void)addDragRefreshHeader;

-(void)removeDragRefreshHeader;

//检测网络连接并提示
- (BOOL)checkNetworkIsEnableAndTell;
//设置morecell模式
- (void)setMoreCellState:(SNMoreCellState)state;
@end
