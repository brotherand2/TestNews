//
//  SNVideosTableViewController.h
//  sohunews
//
//  Created by chenhong on 13-8-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNTripletsLoadingView.h"
#import "SNVideosModel.h"

@interface SNVideosTableViewController : SNThemeViewController<
UITableViewDataSource,
UITableViewDelegate,
SNVideosModelDelegate,
SNTripletsLoadingViewDelegate> {
    UITableView *_tableView;
    NSString *_channelId;
}

@property(nonatomic,weak)id delegate;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,copy)NSString *channelId;
@property(nonatomic,assign)BOOL canBeReusable;
@property(nonatomic,strong)NSString *reuseIdentifier;

- (id)initWithIdentifier:(NSString *)aIdentifier;
//iOS 6.0以下此方法会被回调
- (void)didEndDisplayingCell:(UITableViewCell *)cell;
    
- (void)setChannelId:(NSString *)channelId;
- (void)updateTheme;
- (void)scrollToTop;
- (void)addTableHeader:(float)height;
- (void)removeTableHeader;
- (void)refreshIfNeeded;
- (BOOL)isLoading;
- (BOOL)shouldReload;

- (void)startPlayTimelineVideo;
- (void)startPlayTimelineVideoIn2G3G;

- (BOOL)doesNeedRefresh;

@end

@protocol SNVideosTableViewControllerDelegate
- (void)videosDidFinishLoadFromTableViewController:(SNVideosTableViewController *)tableViewController isMore:(BOOL)isMore;
@end
