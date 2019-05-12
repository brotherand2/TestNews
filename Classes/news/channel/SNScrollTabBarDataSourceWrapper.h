//
//  SNScrollTabBarDataSourceWrapper.h
//  sohunews
//
//  Created by wang yanchen on 13-1-5.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNChannelScrollTabBar.h"

@interface SNScrollTabBarDataSourceWrapper : NSObject<SNScrollTabBarDataSource> {
    SNChannelScrollTabBar *__weak _tabBar;
}

@property(nonatomic, weak) SNChannelScrollTabBar *tabBar;

// datasource 
- (NSUInteger)numberOfItemsForTabBar:(SNChannelScrollTabBar *)tabBar;
- (SNChannelScrollTabItem *)tabBar:(SNChannelScrollTabBar *)tabBar tabBarItemForIndex:(NSUInteger)index;

- (void)loadFromCache;
- (void)loadFromServer;

@end
