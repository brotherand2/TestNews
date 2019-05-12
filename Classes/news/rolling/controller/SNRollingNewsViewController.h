//
//  SNRollingNewsViewController.h
//  sohunews
//
//  Created by Chen Hong on 12-8-8.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNThemeViewController.h"
#import "SNChannelScrollTabBar.h"
#import "SNChannelScrollTabBarDataSource.h"
#import "SNCloudSaveService.h"
#import "SNRefreshMessageView.h"
#import "SNSaveChannelListService.h"
#import "SNRollingNewsTableController.h"
#import "SNHomeScrollView.h"

@interface SNRollingNewsViewController : SNThemeViewController <SNChannelScrollTabBarDelegate, UIScrollViewDelegate, SNCloudSaveDelegate> {
    SNHomeScrollView *_rollingNewsScrollView;
    
    SNChannelScrollTabBar *tabBar;
    SNChannelScrollTabBarDataSource *_channelDatasource;
    
    NSString *_selectedChannelId;
    
    BOOL isViewReleased;
    BOOL isViewAppearedFromTabSelected;
    
    NSMutableArray *_channelTableViewControllerArray;
    
    //更新频道信息
    SNCloudSaveService *_cloudSaveService;
    SNSaveChannelListService *saveChannelService;
    UIImageView *_tipImageView;
    SNRefreshMessageView *_messageView;
    NSTimeInterval _channelActionDate;
    
    NSInteger _preOffsetX;
}

@property (nonatomic, strong) NSString *selectedChannelId;
@property (nonatomic, strong) SNChannelScrollTabBar *tabBar;
@property (nonatomic, strong) SNChannelScrollTabBarDataSource *channelDatasource;
//更新频道信息
@property (nonatomic, strong) SNCloudSaveService *cloudSaveService;
@property (nonatomic, assign, readonly) NSInteger curIndex;

/**
 初始化主界面的view并加载数据，延迟调用
 */
- (void)initContent;

- (int)addAndSelectExternalChannel:(NewsChannelItem *)selectedItem;
- (BOOL)isHomePage;

- (SNRollingNewsTableController *)getCurrentTableController;
- (void)hideChannelManageView;
//要闻改版
- (void)hideAnimationLoading;
- (void)setRedPacketShow;
@end
