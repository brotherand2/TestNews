//
//  SNFavoriteDataSource.m
//  sohunews
//
//  Created by 李腾 on 2016/11/4.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//  收藏上方可滚动tab（切换收藏夹）数据源

#import "SNFavoriteDataSource.h"
#import "SNCorpusChannelTopBarItem.h"

@implementation SNFavoriteDataSource


- (NSUInteger)numberOfItemsForTabBar:(SNCorpusChannelTopBar *)tabBar {
    return self.channelsArrayM.count;
}

- (SNCorpusChannelTopBarItem *)tabBar:(SNCorpusChannelTopBar *)tabBar tabBarItemForIndex:(NSUInteger)index {
    
    SNCorpusChannelTopBarItem *item = [[SNCorpusChannelTopBarItem alloc] initWithTitle:self.channelsArrayM[index]];
    
    return item;
}

- (NSMutableArray *)channelsArrayM {
    if (!_channelsArrayM) {
        _channelsArrayM = [NSMutableArray array];
    }
    return _channelsArrayM;
}

- (void)setTabBar:(SNCorpusChannelTopBar *)tabBar {
    _tabBar = tabBar;
    if (_tabBar) {
        _tabBar.dataSource = self;
    }
}

@end
