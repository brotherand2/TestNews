//
//  SNRollingNewsDragRefreshDelegate.h
//  sohunews
//
//  Created by Cong Dan on 3/22/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTableViewDragRefreshDelegate.h"

@interface SNNewsTableViewDelegate : SNTableViewDragRefreshDelegate

@property(nonatomic,assign)BOOL enablePreload; // 预加载开关（默认开）

- (BOOL)shouldReload;
- (BOOL)shouldReSetLoad;
- (BOOL)reloadChannelNews;

// 优化：减少不必要的reload local
- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId;
- (BOOL)shouldRequestNetwork;
- (void)loadLocal;
- (void)loadNetwork;
- (void)autoRefresh;
- (void)startFetchDataInWifi;
- (BOOL)hasNoCache;
- (void)onlyRefresh;

@end
