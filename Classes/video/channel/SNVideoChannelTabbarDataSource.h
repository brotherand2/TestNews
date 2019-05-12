//
//  SNVideoChannelTabbarDataSource.h
//  sohunews
//
//  Created by jojo on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNScrollTabBarDataSourceWrapper.h"
#import "SNVideoChannelManager.h"

@interface SNVideoChannelTabbarDataSource : SNScrollTabBarDataSourceWrapper

@property(nonatomic, strong) NSMutableArray *videoChannels;
@property(nonatomic, strong) NSMutableArray *subedChannels;
@property(nonatomic, assign) BOOL hasNew;
@property(nonatomic, assign) BOOL hasRefreshedSuccessForOnce;

- (void)sychAllVideoChannels:(NSArray *)allChannels;
- (BOOL)shouldReload;
- (void)loadFromServerInSilence; // 加载完成之后只刷新频道bar，不会触发频道下的内容刷新

@end
