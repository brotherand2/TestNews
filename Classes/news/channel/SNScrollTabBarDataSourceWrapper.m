//
//  SNScrollTabBarDataSourceWrapper.m
//  sohunews
//
//  Created by wang yanchen on 13-1-5.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNScrollTabBarDataSourceWrapper.h"

@implementation SNScrollTabBarDataSourceWrapper
@synthesize tabBar = _tabBar;

//- (void)dealloc {
//    self.tabBar = nil;
//}

- (NSUInteger)numberOfItemsForTabBar:(SNChannelScrollTabBar *)tabBar {
    return 0;
}

- (SNChannelScrollTabItem *)tabBar:(SNChannelScrollTabBar *)tabBar tabBarItemForIndex:(NSUInteger)index {
    return nil;
}

- (void)loadFromCache {
    
}

- (void)loadFromServer {
    
}

- (void)setTabBar:(SNChannelScrollTabBar *)tabBar {
    _tabBar = tabBar;
    if (_tabBar) {
        _tabBar.dataSource = self;
    }
}

@end
